package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

// 環境変数からポート番号を取得
func getPort() string {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // デフォルト値
	}
	return port
}

// 環境変数の初期化
func initEnv() {
	env := os.Getenv("GO_ENV")
	if env == "" {
		env = "dev" // デフォルトは開発環境
	}

	envFile := fmt.Sprintf(".env.%s", env)
	err := godotenv.Load(envFile)
	if err != nil {
		log.Printf("警告: %s ファイルが見つかりません。デフォルト設定を使用します。", envFile)
	} else {
		log.Printf("環境設定を %s から読み込みました", envFile)
	}

	// 環境変数のログ出力（デバッグ用）
	logLevel := os.Getenv("LOG_LEVEL")
	if logLevel == "debug" {
		log.Println("環境変数:")
		log.Printf("ENV: %s", os.Getenv("ENV"))
		log.Printf("PORT: %s", os.Getenv("PORT"))
		log.Printf("LOG_LEVEL: %s", os.Getenv("LOG_LEVEL"))
		log.Printf("API_VERSION: %s", os.Getenv("API_VERSION"))
	}
}

func main() {
	// 環境変数の初期化
	initEnv()

	// Ginモードの設定
	if os.Getenv("ENV") == "production" {
		gin.SetMode(gin.ReleaseMode)
	} else {
		gin.SetMode(gin.DebugMode)
	}

	// Ginルーターの初期化
	router := gin.Default()

	// APIバージョン取得
	apiVersion := os.Getenv("API_VERSION")
	if apiVersion == "" {
		apiVersion = "v1"
	}

	// ルートパスのハンドラ
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Hello World from Go Gin Backend!",
			"version": apiVersion,
			"env":     os.Getenv("ENV"),
		})
	})

	// APIエンドポイント
	api := router.Group(fmt.Sprintf("/api/%s", apiVersion))
	{
		api.GET("/hello", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message": "Hello from API!",
			})
		})

		api.GET("/health", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"status": "healthy",
			})
		})
	}

	// サーバー起動
	port := getPort()
	log.Printf("サーバーを起動しています: http://localhost:%s", port)
	log.Printf("0320 1730")
	log.Printf("DATABASE_URL: %s", os.Getenv("DATABASE_URL"))
	log.Printf("secret: %s", os.Getenv("SECRET"))
	router.Run(":" + port)
}
