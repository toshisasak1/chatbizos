# はじめに

このガイドは、できるだけセットアップの負担を減らして ChatBizOS を動かしたい非エンジニア向けに書かれています。

## 1. 事前準備

必要なもの:

- Docker Desktop または Docker Engine
- Discord または Slack のアカウント
- 利用する LLM プロバイダーの API キー
- `.env` ファイルを編集できる程度の基本操作

## 2. API キーを用意する

### OpenAI

1. OpenAI アカウントを作成するか、既存アカウントにサインインします。
2. API ダッシュボードを開きます。
3. 新しい API キーを発行します。
4. 発行したキーを `.env` に貼り付けます。

画面イメージ: API キー一覧ページに「新しいシークレットキーを作成」ボタンと既存キーの一覧が表示されます。

### Anthropic

1. Anthropic アカウントを作成するか、既存アカウントにサインインします。
2. API keys セクションを開きます。
3. 新しいキーを作成します。
4. 発行したキーを `.env` に貼り付けます。

画面イメージ: Anthropic のコンソールでキー管理画面が開き、作成ボタンとマスク済みのキー一覧が表示されます。

## 3. Discord Bot または Slack App を作る

### Discord

1. Discord Developer Portal にアクセスします。
2. 新しい Application を作成します。
3. Bot ユーザーを追加します。
4. Bot Token をコピーします。
5. 必要な権限を付けて Bot をサーバーに招待します。
6. サーバー ID とチャンネル ID を控えます。

### Slack

1. Slack API ダッシュボードにアクセスします。
2. 新しい App を作成します。
3. メッセージ送受信に必要な Bot Token Scope を追加します。
4. App をワークスペースにインストールします。
5. Bot Token、App Token、対象チャンネル ID を控えます。

## 4. リポジトリを取得する

```bash
git clone https://github.com/toshisasak1/chatbizos
cd chatbizos
```

## 5. セットアップウィザードを実行する

```bash
./setup/setup.sh
```

ウィザードでは、LLM プロバイダー、API キー、チャットチャネル、チャネル認証情報、タイムゾーンを順番に聞かれます。入力内容をもとに `.env` が生成されます。

## 6. Docker Compose で起動する

```bash
docker compose up -d
```

この処理でコンテナのビルド、ワークスペース準備、OpenClaw 設定生成、ゲートウェイ起動まで行われます。

## 7. Bot と最初の会話を始める

設定した Discord または Slack のチャンネルを開いて、次のようなメッセージを送ってください。

- 「ハンドメイドキャンドルの事業を始めたい」
- 「コンサルティング商品の需要を検証したい」
- 「ニッチな SaaS のアイデアがある」

Producer エージェントが、状況整理と優先順位付けから会話を始めます。

## 8. ワークスペースを理解する

`workspace/` ディレクトリには、事業づくりの進捗が保存されます。

重要なファイル:

- `STATUS.md`: 現在フェーズと主なブロッカー
- `MILESTONES.md`: 重要な到達点
- `06_operations/task_queue.md`: 現在の作業キュー
- `06_operations/decision_log.md`: 重要な意思決定の記録
- `07_validation/compliance_log.md`: リスクメモと人間レビュー事項

## 9. よくある問題と対処

### コンテナは起動するが Bot が反応しない

- `.env` の値を見直してください。
- Bot が対象チャンネルにアクセスできるか確認してください。
- `docs/ja/troubleshooting.md` を確認してください。

### ワークスペースが空のまま

- コンテナが `./workspace` に書き込めるか確認してください。
- コンテナを再ビルドして再起動してください。

### LLM エラーが出る

- API キーを再確認してください。
- `.env` の `LLM_PROVIDER` が想定値になっているか確認してください。
