package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gin-contrib/cors"
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
		env = "development" // デフォルトは開発環境
	}

	// Dockerコンテナ内では環境変数が直接設定されるため、ファイル読み込みをスキップする可能性も考慮
	envFile := fmt.Sprintf(".env.%s", env)
	err := godotenv.Load(envFile)
	if err != nil {
		log.Printf("警告: %s ファイルが見つかりません。環境変数が直接設定されていることを確認してください。", envFile)
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

	// CORSミドルウェアの設定
	router.Use(cors.New(cors.Config{
		AllowOrigins: []string{
			"http://52.199.151.155:3000",
			"http://52.199.151.155:8080",
			"http://localhost:3000",
			"http://localhost:8080",
			"http://fullstack-02-alb-209785604.ap-northeast-1.elb.amazonaws.com:3000",
			"http://fullstack-02-alb-209785604.ap-northeast-1.elb.amazonaws.com:8080",
			"http://fullstack-02-alb-209785604.ap-northeast-1.elb.amazonaws.com",
		},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	// APIバージョン取得
	apiVersion := os.Getenv("API_VERSION")
	if apiVersion == "" {
		apiVersion = "v1"
	}

	// ルートパスのハンドラ
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "healthy",
		})
	})

	// APIエンドポイント
	api := router.Group(fmt.Sprintf("/api/%s", apiVersion))
	{
		api.GET("/hello", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message": "hello world",
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

	// センシティブな情報はデバッグモードでのみログ出力する
	if os.Getenv("LOG_LEVEL") == "debug" {
		log.Printf("DATABASE_URL: %s", os.Getenv("DATABASE_URL"))
		log.Printf("SECRET: %s", os.Getenv("SECRET"))
	}

	router.Run("0.0.0.0:" + port)
}
