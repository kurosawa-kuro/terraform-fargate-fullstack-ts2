# ================================
# Frontend
# ================================

# Docker関連の設定
FRONTEND_DOCKER_USERNAME = kurosawakuro
FRONTEND_DOCKER_IMAGE = frontend-3000
FRONTEND_DOCKER_TAG = latest
FRONTEND_DOCKER_FULL_IMAGE = $(FRONTEND_DOCKER_USERNAME)/$(FRONTEND_DOCKER_IMAGE):$(FRONTEND_DOCKER_TAG)
FRONTEND_DOCKER_CONTAINER_NAME = frontend-container

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
	cd src/frontend && docker build -t $(FRONTEND_DOCKER_FULL_IMAGE) .

frontend-docker-run:
	cd src/frontend && docker run -p 3000:3000 --name $(FRONTEND_DOCKER_CONTAINER_NAME) $(FRONTEND_DOCKER_FULL_IMAGE)

frontend-docker-run-detached:
	cd src/frontend && docker run -d -p 3000:3000 --name $(FRONTEND_DOCKER_CONTAINER_NAME) $(FRONTEND_DOCKER_FULL_IMAGE)

frontend-docker-push-dockerhub:
	cd src/frontend && docker push $(FRONTEND_DOCKER_FULL_IMAGE)

frontend-docker-push-ecr:
	cd src/frontend && docker push $(ECR_FULL_IMAGE)

frontend-docker-stop:
	docker stop $(FRONTEND_DOCKER_CONTAINER_NAME) && docker rm $(FRONTEND_DOCKER_CONTAINER_NAME)

frontend-docker-logs:
	docker logs $(FRONTEND_DOCKER_CONTAINER_NAME)

frontend-docker-shell:
	docker exec -it $(FRONTEND_DOCKER_CONTAINER_NAME) /bin/sh

frontend-docker-all: frontend-docker-build frontend-docker-run
	@echo "Dockerコンテナを起動しました。ブラウザで http://localhost:3000 にアクセスしてください" 

