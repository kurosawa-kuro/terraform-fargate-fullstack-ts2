# ビルドステージ
FROM node:20-alpine AS builder

# 作業ディレクトリを設定
WORKDIR /app

# パッケージマネージャーの選択（npm, yarn, pnpmなど）
# package-lock.jsonが存在する場合はnpmを使用
COPY package*.json ./

# 依存関係のインストール
RUN npm ci

# ソースコードのコピー
COPY . .

# アプリケーションのビルド
RUN npm run build

# 実行ステージ
FROM node:20-alpine AS runner
WORKDIR /app

# 本番環境用の変数設定
ENV NODE_ENV production

# システムユーザーの追加
RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

# ビルド済みのアプリケーションをコピー
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static

# スタンドアロンモードでビルドされた場合
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/server ./.next/server

# ユーザー切り替え
USER nextjs

# ポート設定
EXPOSE 3000

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl --fail http://localhost:3000 || exit 1

# 起動コマンド
CMD ["node", "server.js"]
