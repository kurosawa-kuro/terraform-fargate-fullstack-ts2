# ================================
# Main Makefile
# ================================

# Include all sub-makefiles
include make/frontend.mk
include make/backend.mk
include make/curl.mk
include make/infra.mk

# ================================
# Other
# ================================

# Help command to list available targets
.PHONY: help
help:
	@echo "利用可能なコマンド一覧:"
	@echo ""
	@echo "【フロントエンド関連】"
	@echo "  frontend-dev               - フロントエンド開発サーバーを起動"
	@echo "  frontend-build             - フロントエンドをビルド"
	@echo "  frontend-start             - ビルド済みフロントエンドを起動"
	@echo "  frontend-lint              - フロントエンドのlintチェック"
	@echo "  frontend-test              - フロントエンドのテスト実行"
	@echo "  frontend-docker-all        - フロントエンドのDockerビルドと実行"
	@echo ""
	@echo "【バックエンド関連】"
	@echo "  backend-dev                - バックエンド開発サーバーを起動"
	@echo "  backend-mod-tidy           - Goの依存関係を整理"
	@echo "  backend-docker-all         - バックエンドのDockerビルドと実行"
	@echo "  backend-test               - バックエンドのAPIテスト"
	@echo ""
	@echo "【インフラ関連】"
	@echo "  tf-deploy                  - Terraformによるデプロイ"
	@echo "  tf-validate                - Terraformの構成を検証"
	@echo "  tf-fmt                     - Terraformファイルのフォーマット"
	@echo "  tf-destroy                 - インフラの破棄"
	@echo ""
	@echo "詳細は各サブコマンドの定義を参照してください。"

# Default target
.DEFAULT_GOAL := help

