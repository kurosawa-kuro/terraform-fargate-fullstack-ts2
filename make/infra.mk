# ================================
# Infra
# ================================

# Terraform共通設定
TF_CMD := terraform
TF_PLAN_FILE := plan.tfplan
TF_DESTROY_FILE := destroy.tfplan

# コンポーネント設定
TF_COMPONENTS := ssm fargate

# コンポーネント毎のパス
TF_SSM_DIR := infra/ssm
TF_FARGATE_DIR := infra/fargate

# 共通コマンド定義
define tf-cmd
	cd $(2) && $(TF_CMD) $(1)
endef

define tf-plan
	cd $(1) && $(TF_CMD) plan $(2) -out=$(TF_PLAN_FILE)
endef

define tf-apply
	cd $(1) && $(TF_CMD) apply $(TF_PLAN_FILE)
endef

define tf-destroy
	cd $(1) && $(TF_CMD) destroy $(2)
endef

# SSM関連コマンド
tf-ssm-deploy:
	cd $(TF_SSM_DIR) && $(TF_CMD) init
	$(call tf-plan,$(TF_SSM_DIR),)
	$(call tf-apply,$(TF_SSM_DIR))

tf-ssm-deploy-env:
	cd $(TF_SSM_DIR) && $(TF_CMD) init
	$(call tf-plan,$(TF_SSM_DIR),-var-file=terraform.tfvars)
	$(call tf-apply,$(TF_SSM_DIR))

tf-ssm-validate:
	$(call tf-cmd,validate,$(TF_SSM_DIR))

tf-ssm-fmt:
	$(call tf-cmd,fmt -recursive,$(TF_SSM_DIR))

tf-ssm-status:
	$(call tf-cmd,state list,$(TF_SSM_DIR))

tf-ssm-plan-destroy:
	$(call tf-plan,$(TF_SSM_DIR),-destroy)

tf-ssm-destroy:
	$(call tf-destroy,$(TF_SSM_DIR),)

tf-ssm-destroy-auto:
	$(call tf-destroy,$(TF_SSM_DIR),-auto-approve)

# Fargate関連コマンド
tf-fargate-deploy:
	cd $(TF_FARGATE_DIR) && $(TF_CMD) init
	$(call tf-plan,$(TF_FARGATE_DIR),)
	$(call tf-apply,$(TF_FARGATE_DIR))

tf-fargate-destroy:
	$(call tf-destroy,$(TF_FARGATE_DIR),)

# 追加：Fargateの他のコマンド
tf-fargate-validate:
	$(call tf-cmd,validate,$(TF_FARGATE_DIR))

tf-fargate-fmt:
	$(call tf-cmd,fmt -recursive,$(TF_FARGATE_DIR))

tf-fargate-status:
	$(call tf-cmd,state list,$(TF_FARGATE_DIR))

tf-fargate-destroy-auto:
	$(call tf-destroy,$(TF_FARGATE_DIR),-auto-approve)

# 全コンポーネント共通コマンド
tf-deploy-all: tf-ssm-deploy tf-fargate-deploy

tf-destroy-all: tf-ssm-destroy tf-fargate-destroy

tf-fmt-all:
	for comp in $(TF_COMPONENTS); do \
		$(MAKE) tf-$$comp-fmt; \
	done

tf-validate-all:
	for comp in $(TF_COMPONENTS); do \
		$(MAKE) tf-$$comp-validate; \
	done