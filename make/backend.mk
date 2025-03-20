# ================================
# Backend
# ================================

# Docker関連の変数
BACKEND_DOCKER_IMAGE_NAME := kurosawakuro/backend-8080
BACKEND_DOCKER_TAG ?= latest
BACKEND_DOCKER_FULL_IMAGE := $(BACKEND_DOCKER_IMAGE_NAME):$(BACKEND_DOCKER_TAG)
BACKEND_DOCKER_CONTAINER_NAME := backend-container

# ECR関連の変数
ECR_REPO := 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/backend-8080
ECR_TAG ?= $(BACKEND_DOCKER_TAG)
ECR_FULL_IMAGE := $(ECR_REPO):$(ECR_TAG)

# ポート設定
BACKEND_PORT := 8080

backend-dev:
	cd src/backend && GO_ENV=dev go run main.go

backend-mod-tidy:
	cd src/backend && go mod tidy

backend-docker-build:
	cd src/backend && docker build -t $(BACKEND_DOCKER_FULL_IMAGE) .

backend-docker-run:
	cd src/backend && docker run -p $(BACKEND_PORT):$(BACKEND_PORT) --name $(BACKEND_DOCKER_CONTAINER_NAME) $(BACKEND_DOCKER_FULL_IMAGE)

backend-docker-push-dockerhub:
	cd src/backend && docker push $(BACKEND_DOCKER_FULL_IMAGE)

backend-docker-push-ecr:
	cd src/backend && docker push $(ECR_FULL_IMAGE)

backend-docker-stop:
	docker stop $(BACKEND_DOCKER_CONTAINER_NAME) && docker rm $(BACKEND_DOCKER_CONTAINER_NAME)

backend-docker-logs:
	docker logs $(BACKEND_DOCKER_CONTAINER_NAME)

backend-docker-shell:
	docker exec -it $(BACKEND_DOCKER_CONTAINER_NAME) /bin/sh

backend-test:
	curl http://localhost:$(BACKEND_PORT)/api/health
	curl http://localhost:$(BACKEND_PORT)/api/v1/ping

backend-test-prod:
	curl http://localhost:$(BACKEND_PORT)/api/health
	curl http://localhost:$(BACKEND_PORT)/api/v1/ping

backend-docker-all: backend-docker-build backend-docker-run
	@echo "Dockerコンテナを起動しました。テストするには 'make backend-test' を実行してください" 