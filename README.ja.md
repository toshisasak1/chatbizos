# ChatBizOS

[English](README.md) | **日本語**

ChatBizOS は OpenClaw 上に構築されたオープンソースのマルチエージェント型ビジネス構築フレームワークです。非エンジニアでも、Discord や Slack から AI チームに話しかけるだけで、事業アイデアを戦略、コンテンツ、実装計画、進捗管理へ落とし込めます。

## ChatBizOS とは

ChatBizOS は、5 つの専門エージェントを 1 つのワークフローとしてまとめています。

- **Producer**: 全体進行を管理し、優先順位を決め、進捗を見える化します。
- **Concept**: 事業戦略、顧客像、オファー、ポジショニングを設計します。
- **Conversation**: メッセージング、コンテンツ、集客施策を作ります。
- **Builder**: 実装手順、ツール選定、運用フローを整理します。
- **Compliance**: 法務、規制、プラットフォーム利用規約上のリスクを確認します。

成果物は Markdown ベースのワークスペースとして蓄積されます。何を決めたか、何を進めているか、どこで人間の判断が必要かを、後から追える形で残せます。

## 主な機能

- 5 エージェントによる事業構築チーム
- Discord / Slack ベースのチャット運用
- OpenAI / Anthropic / ローカル LLM の設定に対応
- 戦略、調査、成長、実装、検証を整理するワークスペーステンプレート
- 朝のブリーフィング、夜のレビュー、週次進捗報告の cron 運用
- 汎用的なビジネス立ち上げ向けに設計された `SOUL.md`
- `.env` を生成するセットアップウィザード
- Docker を使ったローカルデプロイ

## クイックスタート

```bash
git clone https://github.com/toshisasak1/chatbizos
cd chatbizos
cp .env.example .env
# .env に API キーとチャット連携情報を設定
docker compose up -d
```

起動後は、設定した Discord または Slack のチャンネルから Producer エージェントに話しかけてください。

## アーキテクチャ

```text
ユーザー
    |
    v
Discord / Slack
    |
    v
OpenClaw Gateway
    |
    v
Producer ----> Concept
   |              |
   |              v
   |--------> Conversation
   |              |
   |              v
   |--------> Builder
   |              |
   |              v
   +--------> Compliance
    |
    v
ワークスペースの Markdown ファイル
```

## エージェント

### Producer
全体の司令塔です。現在の状況を読み取り、次の優先タスクを決め、担当エージェントに依頼し、人間に確認が必要な論点を整理します。

### Concept
事業戦略担当です。市場、顧客、オファー、価格、ポジショニング、調査仮説を設計します。

### Conversation
集客とコンテンツ担当です。ブランドメッセージ、投稿案、LP コピー、顧客との対話スクリプトを作成します。

### Builder
実装担当です。ノーコードや低コードを優先しながら、実行可能な導入手順と技術スタックを提案します。

### Compliance
法務・リスク担当です。プライバシー、広告表現、利用規約、消費者保護などの観点からリスクを洗い出し、必ず人間レビューへエスカレーションします。

## 設定ファイル

主要な設定ファイルは次のとおりです。

- `config/chatbizos.yaml`: プロジェクト、エージェント、LLM、チャネル設定
- `config/openclaw-config.json`: OpenClaw ランタイム設定テンプレート
- `config/cron.yaml`: ブリーフィングやレビューのスケジュール
- `.env`: API キーやチャット連携情報などの環境変数

## ドキュメント

- [はじめに](docs/ja/getting-started.md)
- [アーキテクチャ](docs/ja/architecture.md)
- [エージェントのカスタマイズ](docs/ja/agent-customization.md)
- [LLM プロバイダー](docs/ja/llm-providers.md)
- [トラブルシューティング](docs/ja/troubleshooting.md)

## コントリビュート

コントリビューション歓迎です。プルリクエストを送る前に `CONTRIBUTING.md` を読んでください。

## ライセンス

MIT ライセンスです。詳細は `LICENSE` を参照してください。
