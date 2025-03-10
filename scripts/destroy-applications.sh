#!/bin/bash -e

# Set up logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/../logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/destroy-$(date +%Y%m%d-%H%M%S).log"

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
    log "Dumping remaining resources..."
    kubectl get applications -n argocd -o wide >>"${LOG_FILE}" 2>/dev/null || true
    exit "${exit_code}"
}
trap handle_error ERR

# Get environment from first argument or use main as default
ENVIRONMENT=${1:-main}
log "Starting deletion for environment: ${ENVIRONMENT}"

# Confirm destruction
if [ -z "$FORCE_DESTROY" ]; then
    if [ -z "$CI" ]; then
        echo -n "Are you sure you want to destroy all applications for ${ENVIRONMENT}? (y/N): "
        read -r confirmation
        if [[ ! "$confirmation" =~ ^[yY]$ ]]; then
            log "Destruction cancelled by user"
            exit 0
        fi
    else
        log "Running in CI mode, confirmation skipped with FORCE_DESTROY=$FORCE_DESTROY"
    fi
fi

# Cluster is hardcoded as production-cluster regardless of environment
CLUSTER_NAME="production-cluster"
log "Using cluster: ${CLUSTER_NAME}"

# Connecting to EKS Cluster
log "Connecting to cluster: ${CLUSTER_NAME}"
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# Set the application directory based on environment
APP_DIR="k8s/argocd/applications/${ENVIRONMENT}"
if [ ! -d "$APP_DIR" ]; then
    log "Application directory $APP_DIR does not exist, falling back to main directory"
    APP_DIR="k8s/argocd/applications/main"
fi

# Destroy applications in reverse order
log "Destroying applications in reverse order..."

# First, list all applications
log "Current ArgoCD applications:"
kubectl get applications -n argocd -o name >>"${LOG_FILE}" 2>/dev/null || log "No applications found"

# The order is reversed from the deployment order
# Vault
log "Destroying Vault..."
kubectl delete -f $APP_DIR/vault.yaml --wait=false 2>/dev/null || log "Vault was not found"
sleep 10

# Metrics Server
log "Destroying Metrics Server..."
kubectl delete -f $APP_DIR/metrics-server.yaml --wait=false 2>/dev/null || log "Metrics Server was not found"
sleep 10

# Ingress Nginx
log "Destroying Ingress Nginx..."
kubectl delete -f $APP_DIR/ingress-nginx.yaml --wait=false 2>/dev/null || log "Ingress Nginx was not found"
sleep 10

# Monitoring
log "Destroying Monitoring..."
kubectl delete -f $APP_DIR/monitoring.yaml --wait=false 2>/dev/null || log "Monitoring was not found"
sleep 10

# AWS EBS CSI Driver
log "Destroying AWS EBS CSI Driver..."
kubectl delete -f $APP_DIR/aws-ebs-csi-driver.yaml --wait=false 2>/dev/null || log "AWS EBS CSI Driver was not found"
sleep 10

# API and Web (commented out as in deployment script)
# log "Destroying API..."
# kubectl delete -f $APP_DIR/api.yaml --wait=false 2>/dev/null || log "API was not found"
# sleep 10

# log "Destroying Web..."
# kubectl delete -f $APP_DIR/web.yaml --wait=false 2>/dev/null || log "Web was not found"
# sleep 10

# Wait for applications to be deleted
log "Waiting for applications to be deleted (this may take a while)..."
for ((i=0; i<12; i++)); do  # 2-minute timeout (12 * 10 seconds)
    APP_COUNT=$(kubectl get applications -n argocd --no-headers 2>/dev/null | wc -l || echo "0")
    if [ "$APP_COUNT" -eq 0 ]; then
        log "All applications deleted successfully"
        break
    fi
    
    log "Still waiting, $APP_COUNT applications remaining..."
    kubectl get applications -n argocd -o wide >>"${LOG_FILE}" 2>/dev/null || true
    sleep 10
done

# Final check
REMAINING_APPS=$(kubectl get applications -n argocd -o name 2>/dev/null || echo "")
if [ -n "$REMAINING_APPS" ]; then
    log "WARNING: Some applications could not be deleted. You may need to remove them manually:"
    echo "$REMAINING_APPS" | tee -a "${LOG_FILE}"
else
    log "All applications successfully deleted from ArgoCD"
fi

# Optional: Clean up resources that might be left behind
if [ "$CLEAN_RESOURCES" = "true" ]; then
    log "Performing additional cleanup of resources..."
    # Cleanup namespace resources
    for ns in monitoring ingress-nginx vault; do
        log "Cleaning up namespace: $ns"
        kubectl delete all --all -n $ns 2>/dev/null || true
        kubectl delete pvc --all -n $ns 2>/dev/null || true
        kubectl delete configmap --all -n $ns 2>/dev/null || true
        kubectl delete secret --all -n $ns 2>/dev/null || true
    done
    log "Additional cleanup completed"
fi

log "Destruction process completed successfully!"