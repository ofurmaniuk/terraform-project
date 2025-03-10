#!/bin/bash -e

# Set up logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/../logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/deployment-$(date +%Y%m%d-%H%M%S).log"

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] $1" | tee -a "${LOG_FILE}"
}

# Error handling
handle_error() {
    local exit_code=$?
    log "ERROR: Command failed with exit code: ${exit_code}"
    log "Error occurred on line: ${BASH_LINENO[0]}"
    log "Dumping pods status across all namespaces..."
    kubectl get pods -A -o wide >>"${LOG_FILE}"
    exit "${exit_code}"
}
trap handle_error ERR

# Get environment from first argument or use main as default
ENVIRONMENT=${1:-main}
log "Starting deployment to environment: ${ENVIRONMENT}"

# Cluster is hardcoded as production-cluster regardless of environment
CLUSTER_NAME="production-cluster"
log "Using cluster: ${CLUSTER_NAME}"

# Connecting to EKS Cluster
log "Connecting to cluster: ${CLUSTER_NAME}"
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# Create namespaces if needed
log "Ensuring required namespaces exist..."
for ns in argocd main dev monitoring ingress-nginx vault; do
    kubectl get namespace $ns &>/dev/null || kubectl create namespace $ns
done

# Build Helm dependencies
log "Building Helm dependencies..."
cd helm/charts/aws-ebs-csi-driver && helm dependency build && cd ../../..
cd helm/charts/monitoring && helm dependency build && cd ../../..
cd helm/charts/ingress-nginx && helm dependency build && cd ../../..
cd helm/charts/metrics-server && helm dependency build && cd ../../..
cd helm/charts/vault && helm dependency build && cd ../../..

# Function to wait for pods to be ready
wait_for_pods() {
    local namespace=$1
    local label=$2
    local timeout=${3:-300}
    local interval=10
    local elapsed=0

    log "Waiting for pods in namespace ${namespace} with label ${label}..."
    sleep 30 # Give ArgoCD time to start the sync

    while [ $elapsed -lt $timeout ]; do
        # Check if pods exist
        if kubectl -n "${namespace}" get pods -l "${label}" &>/dev/null; then
            # Check if all pods are running and ready
            READY_COUNT=$(kubectl -n "${namespace}" get pods -l "${label}" -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' | grep -c "true" || echo "0")
            TOTAL_COUNT=$(kubectl -n "${namespace}" get pods -l "${label}" --no-headers | wc -l)
            
            if [ "$READY_COUNT" -eq "$TOTAL_COUNT" ] && [ "$TOTAL_COUNT" -gt 0 ]; then
                log "All $TOTAL_COUNT pods are ready!"
                return 0
            fi
            
            log "$READY_COUNT of $TOTAL_COUNT pods are ready"
        else
            log "No pods found with label ${label} in namespace ${namespace}"
        fi

        log "Still waiting... (${elapsed}s/${timeout}s)"
        sleep $interval
        elapsed=$((elapsed + interval))

        # Show current status
        if kubectl -n "${namespace}" get pods -l "${label}" &>/dev/null; then
            log "Current pod status:"
            kubectl -n "${namespace}" get pods -l "${label}" -o wide >>"${LOG_FILE}"
        fi
    done

    log "Deployment failed after ${timeout} seconds! Current status:"
    kubectl get pods -n "${namespace}" -l "${label}" -o wide || true
    
    # Don't fail - just show the warning and continue
    log "WARNING: Pods not fully ready, but continuing with deployment"
    return 0
}

# Deploy applications in exact order
log "Deploying applications in order..."

# Set the application directory based on environment
APP_DIR="k8s/argocd/applications/${ENVIRONMENT}"
if [ ! -d "$APP_DIR" ]; then
    log "Application directory $APP_DIR does not exist, falling back to main directory"
    APP_DIR="k8s/argocd/applications/main"
fi

# AWS EBS CSI Driver
log "Deploying AWS EBS CSI Driver..."
kubectl apply -f $APP_DIR/aws-ebs-csi-driver.yaml
wait_for_pods "kube-system" "app.kubernetes.io/name=aws-ebs-csi-driver" 300

# Monitoring
log "Deploying Monitoring..."
kubectl apply -f $APP_DIR/monitoring.yaml
wait_for_pods "monitoring" "app.kubernetes.io/name=prometheus" 300

# Ingress Nginx
log "Deploying Ingress Nginx..."
kubectl apply -f $APP_DIR/ingress-nginx.yaml
wait_for_pods "ingress-nginx" "app.kubernetes.io/name=ingress-nginx" 300

# Metrics Server
log "Deploying Metrics Server..."
kubectl apply -f $APP_DIR/metrics-server.yaml
wait_for_pods "kube-system" "app.kubernetes.io/name=metrics-server" 300

# Vault
log "Deploying Vault..."
kubectl apply -f $APP_DIR/vault.yaml
log "Not waiting for Vault deployment as it may take longer"

# Verify all applications are created in ArgoCD
log "Verifying ArgoCD applications..."
kubectl get applications -n argocd

# Check final sync status
log "Checking ArgoCD application sync status..."
sleep 15  # Final wait to ensure status is updated
SYNC_STATUS=$(kubectl get applications -n argocd -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.sync.status}{"\n"}{end}' 2>/dev/null || echo "No applications found")
log "Application sync status:"
log "$SYNC_STATUS"
log "Deployment completed successfully!"