# ROS Notebook Environment

`python:3.12` ベースの Docker コンテナ上で、JupyterLab と ROS2 開発向け最小ツールを使う作業環境です。
ベースイメージは変更せず、ROS 2 apt リポジトリ設定を追加して必要パッケージを導入しています。

## 使い方

1. 環境変数ファイルを作成

```bash
cp .env.example .env
```

2. `.env` の `JUPYTER_PASSWORD` を任意の値に変更

3. 起動

```bash
docker compose up -d --build
```

4. ブラウザでアクセス

`http://localhost:8888`

## ノートブック配置先

- ホスト側: `./notebook`
- コンテナ側: `/workspace/notebook`（Jupyter のルート）
- 起動後は `http://localhost:8888/lab/tree` で `notebook` 配下が表示されます

## 含まれる主なツール

- `jupyterlab`
- `rosdep`
- `rclpy`
- `rosbag2_py`
- `rosbag2_storage_mcap`（rosbag2 の MCAP ストレージプラグイン）
- `mcap`（Python パッケージ）

## ROS ディストリビューション切替

- デフォルトは `ROS_DISTRO=jazzy` です
- 必要であれば `docker-compose.yml` の `environment` で `ROS_DISTRO` を上書きできます
