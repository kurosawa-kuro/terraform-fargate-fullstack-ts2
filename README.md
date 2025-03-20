# terraform-fargate-fullstack-ts2

以下は、「**terraform-fargate-fullstack**」プロジェクトの仕様を再整理・リファクタリングしたドキュメントです。  
この段階では、具体的なソースコードは不要であり、**アーキテクチャ概要**と**環境変数の管理方針**を明確化しています。

---

## 1. 概要

- **目的**  
  AWS上に**フロントエンド（Next.js/TypeScript）**と**バックエンド（Go/Gin）**を分離して配置し、シンプルなマイクロサービス構成をTerraform（IaC）でデプロイする。

- **特徴**  
  - **開発環境**: AWS Lightsail（またはローカルPC）  
  - **本番環境**: AWS Fargate  
  - **ネットワーク**: パブリックサブネットのみ（プライベートサブネットは対象外）  
  - **ロードバランサー**: パブリックアクセス用 (ALB)  
  - **ネーミング規則**: リソースやタグに `fullstack-ts-01` という接頭辞を付与  

---

## 2. フロントエンド

- **技術スタック**: Next.js (TypeScript)
- **主要機能**:  
  1. Hello World 表示  
  2. Go バックエンドのAPIレスポンス表示  
  3. 初期実装時は CSR（クライアントサイドレンダリング）のみで可  
- **環境変数管理**:
  - **ローカル開発用**: `.env.local` または `.env.development.local`  
  - **本番環境用**: `.env.production`  
  - Next.jsではビルド時・実行時に環境変数を読み込む仕組みがあるため、必要な項目を `.env.*` に定義する。  

---

## 3. バックエンド

- **技術スタック**: Go + Gin フレームワーク
- **API機能**:  
  1. 「Hello World」形式の JSONレスポンス  
  2. コンソールログ出力  
- **環境変数管理**:
  - **ローカル開発用**: `.env.dev` または `config.dev.yaml`  
  - **本番環境用**: `.env.prod` または `config.prod.yaml`  
  - Goアプリ起動時に環境変数を読み込み、APIエンドポイントやログレベルなどの設定値を参照する。

---

## 4. Terraform (インフラ)

- **プロビジョニングツール**: Terraform
- **利用サービス**:  
  - VPC（デフォルト構成をできるだけ活用）  
  - ECS Fargate（コンテナオーケストレーション）  
  - ALB（パブリックアクセス）  
- **環境変数管理**:
  - **ローカル開発用**: `terraform.tfvars.dev` または `dev.tfvars`  
  - **本番環境用**: `terraform.tfvars.prod` または `prod.tfvars`  
  - Terraform実行時に `-var-file` オプション等で環境別の変数を読み込む方法を想定。

---

## 5. 対象外要素

- **環境変数管理システム**（Parameter Store, Secrets Manager 等）の利用  
- **データベース連携**  
- **プライベートサブネット構成**（NAT Gateway や VPCエンドポイントは考慮しない）  

---

## 6. デプロイ方式

1. **AWS Fargate + ALB**  
   - フロントエンド用タスクとバックエンド用タスクを別々のECSサービスとしてデプロイ。  
   - パスベースルーティング(例: `/api/*` → バックエンド, `/` → フロントエンド)をALBで実装。  
2. **Terraformで一括構築**  
   - インフラをコード化し、`terraform apply` によってECSクラスター・タスク定義・サービス・ALBなどを自動作成。  
   - 各環境別に `tfvars` ファイルを切り替え、必要な変数を注入。  

---

## 7. 今後の拡張イメージ (参考)

- **環境変数管理システムの導入**: AWS Systems Manager Parameter Store や Secrets Manager  
- **DB連携**: RDS や DynamoDB を追加し、バックエンドでCRUD実装  
- **CI/CD**: GitHub Actions や AWS CodePipeline でコンテナビルド & デプロイ自動化  
- **HTTPS化**: ACMで証明書を発行し、ALBリスナーを443に拡張  

---

### まとめ

本プロジェクトは、**Next.js/TypeScript**フロントエンドと**Go/Gin**バックエンドを**AWS Fargate**上で動かすフルスタック構成です。  
現時点では最小限のHello World機能を想定し、**ローカル・本番それぞれでの環境変数ファイル管理**と**Terraformの環境別変数**運用を行う方針です。追加や変更があれば随時ご連絡ください。