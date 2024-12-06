.PHONY: install clean init plan apply destroy ubuntu-install

install:
	sudo yum install -y yum-utils && \
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && \
	sudo yum -y install terraform

ubuntu-install:
	wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && \
	sudo apt-get update && \
	sudo apt-get install -y terraform

cache:
	find / -type d -name ".terraform" -exec rm -rf {} + && \
	rm -rf $$HOME/.terraform.d/plugin-cache/*

init: ubuntu-install
	git pull && \
	terraform init

plan:
	terraform plan

apply:
	terraform apply --auto-approve

destroy:
	terraform destroy --auto-approve