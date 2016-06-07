# 目的
『実践Ruby on Rails 4: 現場のプロから学ぶ本格Webプログラミング』のサンプルアプリケーションをモダンなインフラストラクチャ構築アプローチでクラウド環境に展開するところまでを解説する。

# 前提
| ソフトウェア     | バージョン    | 備考         |
|:---------------|:-------------|:------------|
| docker         | 1.10.3       |             |
| docker-compose | 1.6.2        |             |
| vagrant        | 1.7.4        |             |
| Ruby           | 2.3.0        |             |
| MySQL          | 5.6          |             |
| Nginx          | 1.9.15       |             |
| Rails          | 4.2.6        |             |

+ DockerHubのアカウントを作っている
+ AWSのアカウントを作っている

# 構成
+ [アプリケーションアーキテクチャ](./doc/application.md)
+ [インフラストラクチャアーキテクチャ](./doc/infrastructure.md)

# 参照
+ [実践Ruby on Rails 4: 現場のプロから学ぶ本格Webプログラミング](http://www.amazon.co.jp/exec/obidos/ASIN/4844335928/oiax-22/ref=nosim)
+ [Baukis - 顧客管理システム](https://github.com/kuroda/baukis-on-rails-4-2)
+ [DockerHub](https://hub.docker.com/)
+ [DockerHub rails](https://hub.docker.com/_/rails/)
+ [DockerHub mysql](https://hub.docker.com/_/mysql/)
`