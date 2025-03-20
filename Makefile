# ================================
# Frontend
# ================================
frontend-dev:
	cd src/frontend && npm run dev

frontend-build:
	cd src/frontend && npm run build

frontend-start:
	cd src/frontend && npm start

frontend-lint:
	cd src/frontend && npm run lint

frontend-test:
	cd src/frontend && npm test

frontend-docker-build:
	cd src/frontend && docker build -t nextjs-app .

frontend-docker-run:
	cd src/frontend && docker run -p 3000:3000 --name nextjs-container nextjs-app

frontend-docker-run-detached:
	cd src/frontend && docker run -d -p 3000:3000 --name nextjs-container nextjs-app

frontend-docker-stop:
	docker stop nextjs-container && docker rm nextjs-container

frontend-docker-logs:
	docker logs nextjs-container

frontend-docker-shell:
	docker exec -it nextjs-container /bin/sh

frontend-docker-all: frontend-docker-build frontend-docker-run
	@echo "Dockerコンテナを起動しました。ブラウザで http://localhost:3000 にアクセスしてください"

# ================================
# Backend
# ================================
backend-dev:
	cd src/backend && GO_ENV=dev go run main.go

backend-mod-tidy:
	cd src/backend && go mod tidy

backend-docker-build:
	cd src/backend && docker build -t gin-app .

backend-docker-run:
	cd src/backend && docker run -p 8080:8080 --name gin-container gin-app

backend-docker-run-detached:
	cd src/backend && docker run -d -p 8080:8080 --name gin-container gin-app

backend-docker-stop:
	docker stop gin-container && docker rm gin-container

backend-docker-logs:
	docker logs gin-container

backend-docker-shell:
	docker exec -it gin-container /bin/sh

backend-test:
	curl http://localhost:80808080/api/health
	curl http://localhost:80808080/api/v1/ping

backend-test-prod:
	curl http://localhost:8080/api/health
	curl http://localhost:8080/api/v1/ping

backend-docker-all: backend-docker-build backend-docker-run
	@echo "Dockerコンテナを起動しました。テストするには 'make backend-test' を実行してください"

# ================================
# Curl
# ================================
curl:
	curl localhost:8080

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


# ================================
# Other
# ================================

