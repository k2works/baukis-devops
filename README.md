# 目的
『実践Ruby on Rails 4: 現場のプロから学ぶ本格Webプログラミング』のサンプルアプリケーションをモダンなインフラストラクチャ構築アプローチでクラウド環境に展開するところまでを解説する。

# 前提
| ソフトウェア     | バージョン    | 備考         |
|:---------------|:-------------|:------------|
| docker         | 1.10.3       |             |
| docker-compose | 1.6.2        |             |
| vagrant        | 1.7.4        |             |
| Ruby           | 2.2.3        |             |
| MySQL          | 5.6          |             |
| Nginx          | 1.9.15       |             |
| Rails          | 4.2.5        |             |

+ DockerHubのアカウントを作っている
+ AWSのアカウントを作っている

# 構成

+ 構築
+ 開発
+ 運用
+ 参照

# 詳細
## 構築
### 開発環境の構築
#### 新規Railsアプリケーションの作成
```
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ docker run -it --rm --user "$(id -u):$(id -g)" -v "$PWD":/usr/src/app -w /usr/src/app rails:4.2.5 rails new -d mysql --skip-test-unit --skip-bundle .
$ rm README.rdoc
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.2.3 bundle install
```
`Overwrite /usr/src/app/.gitignore? (enter "h" for help) [Ynaqdh]`が出たら`n`を入力してエンター

#### 開発環境のビルド
```
$ cd /vagrant/ops/development/docker/
$ docker-compose build
$ cd /vagrant
$ cp ./ops/development/docker/Dockerfile .
$ cp ./ops/development/docker/docker-compose-development.yml ./docker-compose.yml
$ docker-compose build
```

#### 開発環境の実行
```
$ docker-compose run app rake db:create
$ docker-compose up
```
`http://127.0.0.1:8080/`で動作を確認する

### ステージング環境の構築
### 本番環境の構築
## 開発
### アプリケーションの開発
## 運用
### アプリケーションの運用
## 参照

# 参照
+ [実践Ruby on Rails 4: 現場のプロから学ぶ本格Webプログラミング](http://www.amazon.co.jp/exec/obidos/ASIN/4844335928/oiax-22/ref=nosim)
+ [Baukis - 顧客管理システム](https://github.com/kuroda/baukis-on-rails-4-2)
+ [DockerHub](https://hub.docker.com/)
+ [DockerHub rails](https://hub.docker.com/_/rails/)
+ [DockerHub mysql](https://hub.docker.com/_/mysql/)
