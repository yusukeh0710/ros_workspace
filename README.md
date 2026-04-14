# ROS Notebook Environment (Humble-oriented)

`python:3.12` ベースの Docker コンテナ上で、JupyterLab と ROS2 開発向け最小ツールを使う作業環境です。

## 使い方

1. 環境変数ファイルを作成

```bash
cp .env.example .env
```

2. `.env` の `JUPYTER_PASSWORD` を任意の値に変更

3. 起動

```bash
docker compose up --build
```

4. ブラウザでアクセス

`http://localhost:8888`

## 含まれる主なツール

- `jupyterlab`
- `colcon-common-extensions`
- `vcstool`
- `rosdep`
