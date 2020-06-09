# rails_docker

## Dockerコマンド

1. イメージの作成 ( Dockerfile を元にイメージを作成 )
    - $ docker-compose build
1. コンテナの起動 ( docker-compose.yml の設定を元にコンテナを起動する )
    - $ docker-compose up --detach
1. コンテナへ接続 （ 対象のコンテナに対して`bash`を実行する ）（ exitで接続解除 ）
    - $ # execの後はdocker-compose.ymlでのserviceネームを指定する
    - $ docker-compose exec rails_web bash
1. コンテナの削除
    - $ docker-compose down

### Docker Tipsコマンド

- $ docker-compose ps
  - 立ち上がってるContainer（service）を確認できる
- $ docker images
  - ビルドした or docker pullしたイメージの一覧を確認できる

## Railsコマンド

https://railsdoc.com/rails
https://qiita.com/jun_jun_jun/items/dd260c43387a8e17803d

- rails new sample
  - 指定するか考えておくべきコマンド一覧
    - -d postgresql, --datebase=postgresql
    - --skip-test # minitestオフ
    - --skip-turbolinks #  turbolinksオフ
  - $ rails new app_name -d postgresql --skip-test --skip-turbolinks
- rails webpacker:install
- rails s -p 3000 -b '0.0.0.0'
  - bind
  - http://localhost:3000/
- PG Connection
  - database.yml の develop:とtest:を 書き換え
    - development:
        <<: *default
        database: app_name_development
        host: rails_db
        username: postgres
        password: postgres
- No Database
  - rails db:create
    - developmentとtestを作成する
  - さらにcreate:allで全DBを作成する
