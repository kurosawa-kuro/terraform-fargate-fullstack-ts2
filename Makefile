# ================================
# Frontend
# ================================
# src/frontend && npm run dev
frontend-dev:
	cd src/frontend && npm run dev

# ================================
# Backend
# ================================
backend-dev:
	cd src/backend && GO_ENV=dev go run main.go

backend-docker-build:
	cd src/backend && docker build -t gin-app .



backend-docker-run-detached:
	cd src/backend && docker run -d -p 80:80 --name gin-container gin-app

backend-docker-run:
	cd src/backend && docker run -p 80:80 --name gin-container gin-app

backend-docker-stop:
	docker stop gin-container && docker rm gin-container

backend-docker-logs:
	docker logs gin-container

backend-docker-shell:
	docker exec -it gin-container /bin/sh

backend-test:
	curl http://localhost:8080/api/health
	curl http://localhost:8080/api/v1/ping

backend-test-prod:
	curl http://localhost:80/api/health
	curl http://localhost:80/api/v1/ping

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

# ================================
# Other
# ================================

