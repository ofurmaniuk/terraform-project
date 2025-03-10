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

# Get environment from first argument or use production as default
ENVIRONMENT=${1:-production}
log "Starting deployment to environment: ${ENVIRONMENT}"

# Connecting to EKS Cluster
log "Looking for EKS cluster..."
CLUSTER_NAME=$(aws eks list-clusters --region us-east-2 --query "clusters[?contains(@, '${ENVIRONMENT}')]|[0]" --output text)
if [ -z "$CLUSTER_NAME" ]; then
    log "Error: Cluster not found for environment ${ENVIRONMENT}!"
    exit 1
fi
log "Connecting to cluster: ${CLUSTER_NAME}"
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# Create namespaces if needed
log "Ensuring required namespaces exist..."
for ns in argocd production monitoring ingress-nginx vault; do
    kubectl get namespace $ns &>/dev/null || kubectl create namespace $ns
done

# Build Helm dependencies
log "Building Helm dependencies..."
cd helm/charts/aws-ebs-csi-driver && helm dependency build && cd ../../..
cd helm/charts/monitoring && helm dependency build && cd ../../..
cd helm/charts/ingress-nginx && helm dependency build && cd ../../..
cd helm/charts/metrics-server && helm dependency build && cd ../../..
cd helm/charts/vault && helm dependency build && cd ../../..

# Function to wait for deployment
wait_for_deployment() {
    local namespace=$1
    local label=$2
    local timeout=${3:-300}
    local interval=10
    local elapsed=0

    log "Waiting for deployment in namespace ${namespace} with label ${label}..."
    sleep 30 # Give ArgoCD time to start the sync

    while [ $elapsed -lt $timeout ]; do
        if kubectl -n "${namespace}" get deployment -l "${label}" &>/dev/null; then
            if kubectl wait --for=condition=Available deployment -n "${namespace}" -l "${label}" --timeout=30s &>/dev/null; then
                log "Deployment is ready!"
                return 0
            fi
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
    kubectl get pods -n "${namespace}" -l "${label}" -o wide
    return 1
}

# Deploy applications in exact order
log "Deploying applications in order..."

# AWS EBS CSI Driver
log "Deploying AWS EBS CSI Driver..."
kubectl apply -f k8s/argocd/applications/main/aws-ebs-csi-driver.yaml
wait_for_deployment "kube-system" "app.kubernetes.io/name=aws-ebs-csi-driver" 300

# Monitoring
log "Deploying Monitoring..."
kubectl apply -f k8s/argocd/applications/main/monitoring.yaml
wait_for_deployment "monitoring" "app.kubernetes.io/name=prometheus" 300

# Ingress Nginx
log "Deploying Ingress Nginx..."
kubectl apply -f k8s/argocd/applications/main/ingress-nginx.yaml
wait_for_deployment "ingress-nginx" "app.kubernetes.io/name=ingress-nginx" 300

# Metrics Server
log "Deploying Metrics Server..."
kubectl apply -f k8s/argocd/applications/main/metrics-server.yaml
wait_for_deployment "kube-system" "app.kubernetes.io/name=metrics-server" 300

# Vault
log "Deploying Vault..."
kubectl apply -f k8s/argocd/applications/main/vault.yaml
log "Not waiting for Vault deployment as it may take longer"

# API and Web (commented out as in your example)
# log "Deploying API..."
# kubectl apply -f k8s/argocd/applications/main/api.yaml
# wait_for_deployment "production" "app=api" 300

# log "Deploying Web..."
# kubectl apply -f k8s/argocd/applications/main/web.yaml
# wait_for_deployment "production" "app=web" 300

# Check final sync status
log "Checking ArgoCD application sync status..."
sleep 15  # Final wait to ensure status is updated
SYNC_STATUS=$(kubectl get applications -n argocd -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.sync.status}{"\n"}{end}')
log "Application sync status:"
log "$SYNC_STATUS"
log "Deployment completed successfully!"