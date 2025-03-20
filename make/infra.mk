# ================================
# Infra
# ================================
# deploy = init plan apply
tf-deploy:
	cd infra/ssm && terraform init
	cd infra/ssm && terraform plan -out=plan.tfplan
	cd infra/ssm && terraform apply plan.tfplan

# deploy with environment variables
tf-deploy-env:
	cd infra/ssm && terraform init
	cd infra/ssm && terraform plan -var-file=terraform.tfvars -out=plan.tfplan
	cd infra/ssm && terraform apply plan.tfplan

# validate terraform configuration
tf-validate:
	cd infra/ssm && terraform validate

# format terraform files
tf-fmt:
	cd infra/ssm && terraform fmt -recursive

# show terraform state
tf-status:
	cd infra/ssm && terraform state list

# plan destroy
tf-plan-destroy:
	cd infra/ssm && terraform plan -destroy -out=destroy.tfplan

# destroy
tf-destroy:
	cd infra/ssm && terraform destroy

# destroy with auto-approve
tf-destroy-auto:
	cd infra/ssm && terraform destroy -auto-approve 