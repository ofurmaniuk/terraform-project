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





