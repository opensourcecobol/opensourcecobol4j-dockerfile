このリポジトリでは、GitHub Actionsを使用して、opensource COBOL 4J及びOpen COBOL ESQL 4JのインストールされたDockerイメージのリリースを行います。

# リリース手順

## build-config.jsonの編集

リリースするバージョンに合わせて、build-config.jsonを編集します。
* opensource_COBOL_4J_version: Dockerイメージにインストールするopensource COBOL 4Jのバージョン
* Open_COBOL_ESQL_4J_version: DockerイメージにインストールするOpen COBOL ESQL 4Jのバージョン
* version_string_prefix: リリースするDockerイメージタグのプレフィックス
  * 例えば20250929を指定すると、以下の3つのタグを持つDockerイメージがビルドされ、Docker Hubにプッシュされます。
    * opensourcecobol/opensourcecobol4j:20250929
    * opensourcecobol/opensourcecobol4j:20250929-utf8
    * opensourcecobol/opensourcecobol4j:latest

## ワークフローの手動実行

[公式ドキュメント](https://docs.github.com/ja/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)を参考にして、ワークフローを手動で実行します。

* ワークフロー名: `Build and Push Docker Image`
* ブランチ: `main`
* 入力パラメータ: `push_to_dockerhub`に`true`を指定

これによりDockerイメージがビルドされ、Docker HubにDockerイメージがプッシュされます。

Copyright 2021-2025, Tokyo System House Co., Ltd. <opencobol@tsh-world.co.jp>
