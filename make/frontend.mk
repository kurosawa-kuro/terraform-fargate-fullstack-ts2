# ================================
# Frontend
# ================================

# Docker関連の設定
DOCKER_USERNAME = kurosawakuro
DOCKER_IMAGE = frontend-3000
DOCKER_TAG = latest
DOCKER_FULL_IMAGE = $(DOCKER_USERNAME)/$(DOCKER_IMAGE):$(DOCKER_TAG)
DOCKER_CONTAINER_NAME = frontend-container

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
	cd src/frontend && docker build -t $(DOCKER_FULL_IMAGE) .

frontend-docker-run:
	cd src/frontend && docker run -p 3000:3000 --name $(DOCKER_CONTAINER_NAME) $(DOCKER_FULL_IMAGE)

frontend-docker-run-detached:
	cd src/frontend && docker run -d -p 3000:3000 --name $(DOCKER_CONTAINER_NAME) $(DOCKER_FULL_IMAGE)

frontend-docker-push-dockerhub:
	cd src/frontend && docker push $(DOCKER_FULL_IMAGE)

frontend-docker-push-ecr:
	cd src/frontend && docker push $(ECR_FULL_IMAGE)

frontend-docker-stop:
	docker stop $(DOCKER_CONTAINER_NAME) && docker rm $(DOCKER_CONTAINER_NAME)

frontend-docker-logs:
	docker logs $(DOCKER_CONTAINER_NAME)

frontend-docker-shell:
	docker exec -it $(DOCKER_CONTAINER_NAME) /bin/sh

frontend-docker-all: frontend-docker-build frontend-docker-run
	@echo "Dockerコンテナを起動しました。ブラウザで http://localhost:3000 にアクセスしてください" 

