# terraform-project

```shell
# Get public and private keys 
 ssh-keygen
 cat .ssh/id_rsa.pub
# Clone repository (SSH)
git clone git@github.com:ofurmaniuk/terraform-project.git
```

```shell
# Terraform installation 
sudo yum install -y yum-utils && \
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && \
sudo yum -y install terraform
```

```shell
#  Docker build 
docker buildx build --platform linux/amd64 -t ofurmaniuk/app-api:latest . 
docker tag ofurmaniuk/app-api:latest app-api:latest
docker push ofurmaniuk/app-api:latest

docker buildx build --platform linux/amd64 -t ofurmaniuk/app-web:latest . 
docker tag ofurmaniuk/app-web:latest app-web:latest
docker push ofurmaniuk/app-web:latest
```

```shell
# Delete cache
find / -type d -name ".terraform" -exec rm -rf {} + && \
rm -rf $$HOME/.terraform.d/plugin-cache/*
```

```shell
# Linux commands 
df -h # Check disk space
ls -a # Show hidden files
```

```shell
# AWS Authorization:
aws configure
- AWS Access Key ID:
- AWS Secret Access Key:
- Default region name: us-east-2
- Default output format: json
```

```shell
# Find your "Cluster Name":
terraform output configure_kubectl
#  Configure  kubeconfig file to work with Cluster:
aws eks update-kubeconfig --region us-east-2 --name production-cluster
#  Useful commands 
kubectl get namespaces
kubectl get nodes 
kubectl cluster-info
kubectl get pods --all-namespaces or k get pods -A
kubectl get svc --all-namespaces
kubectl describe nodes
kubectl get pods -A -w  # -w means watch ,to monitor pod creation
```

```shell
# Show HOST of Databases:
aws rds describe-db-instances --query 'DBInstances[*].[Endpoint.Address,Endpoint.Port,DBInstanceIdentifier]' --output table
# Install  ingress-nginx controller ( needed for the Web !)
k apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml
```



```shell 
# Check Linux (bash config file) alias
cat ~/.bashrc
```

```shell 
# Send alias commands to bash config file ( CloudShell )
echo 'alias k="kubectl" && alias kc="kubectl config" && alias kcc="kubectl config current-context" && alias kcg="kubectl config get-contexts" && alias kcs="kubectl config set-context" && alias kcu="kubectl config use-context" && alias ka="kubectl apply -f" && alias kd="kubectl delete" && alias kdf="kubectl delete -f" && alias kdp="kubectl delete pod" && alias kg="kubectl get" && alias kga="kubectl get all" && alias kgaa="kubectl get all --all-namespaces" && alias kgn="kubectl get nodes" && alias kgno="kubectl get nodes -o wide" && alias kgp="kubectl get pods" && alias kgpa="kubectl get pods --all-namespaces" && alias kgpo="kubectl get pods -o wide" && alias kgs="kubectl get services" && alias kgsa="kubectl get services --all-namespaces" && alias kl="kubectl logs" && alias klf="kubectl logs -f" && alias kpf="kubectl port-forward" && alias kex="kubectl exec -it" && alias kdesc="kubectl describe" && alias ktp="kubectl top pod" && alias ktn="kubectl top node"' >> ~/.bashrc && source ~/.bashrc
```

```shell
# Send alias commands to zsh config file ( Mac terminal )
echo 'alias k="kubectl" && alias kc="kubectl config" && alias kcc="kubectl config current-context" && alias kcg="kubectl config get-contexts" && alias kcs="kubectl config set-context" && alias kcu="kubectl config use-context" && alias ka="kubectl apply -f" && alias kd="kubectl delete" && alias kdf="kubectl delete -f" && alias kdp="kubectl delete pod" && alias kg="kubectl get" && alias kga="kubectl get all" && alias kgaa="kubectl get all --all-namespaces" && alias kgn="kubectl get nodes" && alias kgno="kubectl get nodes -o wide" && alias kgp="kubectl get pods" && alias kgpa="kubectl get pods --all-namespaces" && alias kgpo="kubectl get pods -o wide" && alias kgs="kubectl get services" && alias kgsa="kubectl get services --all-namespaces" && alias kl="kubectl logs" && alias klf="kubectl logs -f" && alias kpf="kubectl port-forward" && alias kex="kubectl exec -it" && alias kdesc="kubectl describe" && alias ktp="kubectl top pod" && alias ktn="kubectl top node"' >> ~/.zshrc && source ~/.zshrc
```

```shell
# login to EKS cluster 
aws eks update-kubeconfig --name production-cluster --region us-east-2

# Create namespace 
kubectl create namespace production

# Deploy ConfigMaps
kubectl apply -f k8s/api/api-cm.yaml
kubectl apply -f k8s/web/web-cm.yaml 

# Deploy Services 
kubectl apply -f k8s/api/api-svc.yaml
kubectl apply -f k8s/web/web-svc.yaml 

# Deploy aplications API and WEB 
kubectl apply -f k8s/api/api-deploy.yaml 
kubectl apply -f k8s/web/web-deploy.yaml 
```

```shell
# Important! Web to work properly needs controller. 
# Install  ingress-nginx controller. 
k apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml

chmod +x install-nginx-controller.sh
bash scripts/post-install.s
```

```shell 
npm install --save-dev eslint prettier eslint-config-prettier eslint-plugin-prettier




 # Dockerhub images name: 
 # image: ofurmaniuk/app-api:latest
 # image: ofurmaniuk/app-web:latest

```shell 
# CI 

# 1. Configure GitHub Repository Secrets

# 2. SonarCloud Setup
- Go to sonarcloud.io
- Create new organization
- Create new project
- Get SONAR_TOKEN

# ESLint/Prettier Setup
cd apps/api
# Verify .eslintrc.js exists (it does)
# Run linting locally to test:
npm install
npx eslint .
npx prettier --check .

# DockerHub setup 

# Create DockerHub repository
docker login
# Repository should be: ofurmaniuk/app-api

# Verification

# Make a test commit in apps/api
git add .
git commit -m "test: trigger CI pipeline"
git push

# Check Actions tab in GitHub
# Verify:
- Linting passes
- SonarCloud analysis runs
- Docker image builds/pushes
- Trivy scan completes

```shell
# Log in to your cluster
aws eks update-kubeconfig --name production-cluster --region us-east-2

# ========== ArgoCD ===========#
# Get service ( get argocd-server address)
kubectl get svc -n argocd
# Get the initial admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# =============== Grafana =============== #

# Check  service 
kubectl get svc -n monitoring 
# Check Grafana password 
kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# dashbord for prometheus 1860 
# dashboard for loki 15141
# dashboard for Falco 11914 

# ============= AWS-ebs-csi-driver ============= # 
# Downloads dependencies for aws-ebs-csi-driver
cd helm/charts/aws-ebs-csi-driver && helm dependency build && cd ../../..
# Apply csi- driver that allows to create persisten volumes 
kubectl apply -f k8s/argocd/applications/main/aws-ebs-csi-driver.yaml

# ============= Monitoring ============= # 
# Downloads dependencies for monitoring stack 
cd helm/charts/monitoring && helm dependency build && cd ../../..
# Apply manifest of monitoring stack ( list of programs)
kubectl apply -f k8s/argocd/applications/main/monitoring.yaml

# ============= Ingress-nginx ============= # 
# Downloads dependencies for ingress-nginx
cd helm/charts/ingress-nginx && helm dependency build && cd ../../..
# Apply manifest of ingress-nginx 
kubectl apply -f k8s/argocd/applications/main/ingress-nginx.yaml 

# ============= Metrics-server ============= # 
# Downloads dependencies for metrics-server
cd helm/charts/metrics-server && helm dependency build && cd ../../..
# Apply manifest of metrics-server
kubectl apply -f k8s/argocd/applications/main/metrics-server.yaml 
```

```shell
# ============= Vault ============= # 
# Get your vault svc 
kubectl get svc -n vault vault-ui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
http://<your-load-balancer-url>:8200
# use token and root token as password

# Downloads dependencies for vault 
cd helm/charts/vault && helm dependency build && cd ../../..
# Apply manifest of vault 
kubectl apply -f k8s/argocd/applications/main/vault.yaml

# Initialize Vault and get unsealing keys - CRITICAL: BACKUP THESE KEYS!
kubectl exec -it vault-0 -n vault -- sh
vault operator init

# Unseal the vault with 3 different keys
vault operator unseal KEY1
vault operator unseal KEY2
vault operator unseal KEY3


# Authenticate with root token
 vault login ROOT_TOKEN
``` 

```shell
# Enable KV2 secrets engine for your project
vault secrets enable -path=secret kv-v2

# Create secret with your Aurora DB credentials (removed 'data' from path)
vault kv put secret/database \
    username="dbadmin" \
    password="password" \
    host="production-aurora-cluster.cluster-cdpxotwegnsy.us-east-2.rds.amazonaws.com" \
    port="5432" \
    dbname="mydatabase"

# Enable Kubernetes auth if not already enabled
vault auth enable kubernetes

# Configure Kubernetes auth for your EKS cluster with complete config
vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    issuer="https://kubernetes.default.svc.cluster.local"

# Create policy for your API access (updated path)
vault policy write api - <<EOF
path "secret/data/database" {
  capabilities = ["read"]
}
EOF

# Create role for your API service account (changed name to match pod annotation)
vault write auth/kubernetes/role/api \
    bound_service_account_names=api-sa \
    bound_service_account_namespaces=production \
    policies=api \
    ttl=1h
``` 


```shell
kubectl delete application vault -n argocd
kubectl delete namespace vault --force --grace-period=0

``` 

```shell
 kubectl apply -f k8s/argocd/applications/main/api.yaml  

kubectl delete -f k8s/argocd/applications/main/api.yaml --wait=false

kubectl apply -f k8s/argocd/applications/main/web.yaml  

``` 



`

 Useful commands 
# Delete everything in namespace monitoring 
kubectl delete all --all -n monitoring
# Delete a pod 
kubectl delete pod "pod name" -n monitoring --force --grace-period=0
# Delete a ns 
kubectl delete ns <namespace name>

# ====================== Loki ================== #
# installed thought Argo 
# once i create Loki ( kind of database for logs ) and insatll Promtail ( which collects info from pods and converts it into logs ) i will create  a dashboard on Grafana for Loki (15141 dashboard for Loki)






If i create a yaml file and then apply it  it means i do it in the declarative method /way. 
If i run a long command with resource parameters in terminal it means i do it in the imperative way/method 

declarative - what to do ? better because you create a file and you  can save it 
imperative -how to do ? was it was first they developed declarative. 
for example :
if i go to aws and create needed resources , it menas imperative method of resorces creation 
if i do it via terraform - it meants i use declarative method of resources creation ( this is better beacuse declarative method can be authomated)

Ansible is a IaC tool and it declarative way to install software and configure system/network on VMs 
example: 
on Digital ocean we created a Centoes machine/VM and using ansible playbooks to ....


