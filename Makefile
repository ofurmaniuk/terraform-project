.PHONY: install clean init plan apply destroy cleanup

install:
	sudo yum install -y yum-utils && \
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && \
	sudo yum -y install terraform

cache:
	find / -type d -name ".terraform" -exec rm -rf {} + && \
	rm -rf $$HOME/.terraform.d/plugin-cache/*

init: install
	git pull && \
	terraform init

plan:
	terraform plan

apply:
	terraform apply --auto-approve

cleanup:
	@echo "Cleaning up Kubernetes resources..."
	@if aws eks describe-cluster --name $$(terraform output -raw eks_cluster_name) 2>/dev/null; then \
		aws eks update-kubeconfig --name $$(terraform output -raw eks_cluster_name) --region us-east-2 && \
		kubectl delete all --all --all-namespaces || true && \
		kubectl delete pvc --all --all-namespaces || true && \
		kubectl delete helmrelease --all --all-namespaces || true; \
	fi

destroy: cleanup
	@echo "Destroying node groups..."
	terraform destroy -target=module.eks.aws_eks_node_group.main -auto-approve || true
	@echo "Destroying EKS cluster..."
	terraform destroy -target=module.eks.aws_eks_cluster.main -auto-approve || true
	@echo "Destroying RDS instances..."
	terraform destroy -target=module.rds.aws_rds_cluster_instance.aurora_instance -auto-approve || true
	@echo "Destroying RDS cluster..."
	terraform destroy -target=module.rds.aws_rds_cluster.aurora -auto-approve || true
	@echo "Destroying remaining infrastructure..."
	terraform destroy -auto-approve