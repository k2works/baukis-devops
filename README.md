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
#### パラメータ
| 変数名                  | 値           | 備考         |
|:-----------------------|:-------------|:------------|
| AWS Access Key ID      | xxxxxxxxxxxxxxx                       | aws-cliで設定     |
| AWS Secret Access Key  | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  | aws-cliで設定     |
| Default region name    | ap-northeast-1                             | aws-cliで設定     |
| Default output format  | json                                       | aws-cliで設定     |

以下`#{xxxx}`表記はパラメータの変数を参照すること
なお、AWSシークレットアクセスキーは各自のアカウント情報で取得したものを使う

#### AWS設定
```
$ vagrant up
$ vagrant ssh
$ cd /vagrant
```

```
$ aws configure
 AWS Access Key ID [None]: #{AWS Access Key ID}
 AWS Secret Access Key [None]: #{AWS Secret Access Key}
 Default region name [None]: #{Default region name}
 Default output format [None]: #{Default output format}
$ aws ec2 describe-regions --output table
  ----------------------------------------------------------
  |                     DescribeRegions                    |
  +--------------------------------------------------------+
  ||                        Regions                       ||
  |+-----------------------------------+------------------+|
  ||             Endpoint              |   RegionName     ||
  |+-----------------------------------+------------------+|
  ||  ec2.eu-west-1.amazonaws.com      |  eu-west-1       ||
  ||  ec2.ap-southeast-1.amazonaws.com |  ap-southeast-1  ||
  ||  ec2.ap-southeast-2.amazonaws.com |  ap-southeast-2  ||
  ||  ec2.eu-central-1.amazonaws.com   |  eu-central-1    ||
  ||  ec2.ap-northeast-2.amazonaws.com |  ap-northeast-2  ||
  ||  ec2.ap-northeast-1.amazonaws.com |  ap-northeast-1  ||
  ||  ec2.us-east-1.amazonaws.com      |  us-east-1       ||
  ||  ec2.sa-east-1.amazonaws.com      |  sa-east-1       ||
  ||  ec2.us-west-1.amazonaws.com      |  us-west-1       ||
  ||  ec2.us-west-2.amazonaws.com      |  us-west-2       ||
  |+-----------------------------------+------------------+|
```

VPCの作成
```
$ cd /vagrant/ops/staging/aws/
$ aws cloudformation validate-template --template-body file://vpc/vpc-1az-2subnet-pub.template
$ chmod 0755 ./vpc-create-stack.sh
$ ./vpc-create-stack.sh
$ aws cloudformation list-stack-resources --stack-name Baukis-devops-VPC --output table
------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                       ListStackResources                                                                       |
+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
||                                                                    StackResourceSummaries                                                                    ||
|+--------------------------+-----------------------------------------+----------------------------+------------------+-----------------------------------------+|
||   LastUpdatedTimestamp   |            LogicalResourceId            |    PhysicalResourceId      | ResourceStatus   |              ResourceType               ||
|+--------------------------+-----------------------------------------+----------------------------+------------------+-----------------------------------------+|
||  2016-05-26T11:04:32.245Z|  GatewayToInternet                      |  Bauki-Gatew-6EF0UFZDQS7C  |  CREATE_COMPLETE |  AWS::EC2::VPCGatewayAttachment         ||
||  2016-05-26T11:04:37.870Z|  InboundEphemeralPublicNetworkAclEntry  |  Bauki-Inbou-1RN68U3XRV81D |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-26T11:04:37.701Z|  InboundHTTPPublicNetworkAclEntry       |  Bauki-Inbou-DZYUPRYYTKEZ  |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-26T11:04:37.522Z|  InboundHTTPSPublicNetworkAclEntry      |  Bauki-Inbou-19TZOSK6TT5Y5 |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-26T11:04:37.484Z|  InboundSSHPublicNetworkAclEntry        |  Bauki-Inbou-1UKK4O3DI52UA |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-26T11:04:09.022Z|  InternetGateway                        |  igw-0321b466              |  CREATE_COMPLETE |  AWS::EC2::InternetGateway              ||
||  2016-05-26T11:04:37.908Z|  OutboundPublicNetworkAclEntry          |  Bauki-Outbo-QZRAUQVHA822  |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-26T11:04:17.765Z|  PublicNetworkAcl                       |  acl-87eee5e2              |  CREATE_COMPLETE |  AWS::EC2::NetworkAcl                   ||
||  2016-05-26T11:04:52.044Z|  PublicRoute                            |  Bauki-Publi-1E6AN6G0HPM3D |  CREATE_COMPLETE |  AWS::EC2::Route                        ||
||  2016-05-26T11:04:17.844Z|  PublicRouteTable                       |  rtb-5d584a38              |  CREATE_COMPLETE |  AWS::EC2::RouteTable                   ||
||  2016-05-26T11:04:32.927Z|  PublicSubnet1a                         |  subnet-ebb8ab9c           |  CREATE_COMPLETE |  AWS::EC2::Subnet                       ||
||  2016-05-26T11:04:32.957Z|  PublicSubnet2a                         |  subnet-eab8ab9d           |  CREATE_COMPLETE |  AWS::EC2::Subnet                       ||
||  2016-05-26T11:04:53.328Z|  PublicSubnetNetworkAclAssociation1a    |  aclassoc-d5a171b2         |  CREATE_COMPLETE |  AWS::EC2::SubnetNetworkAclAssociation  ||
||  2016-05-26T11:04:53.302Z|  PublicSubnetNetworkAclAssociation2a    |  aclassoc-d6a171b1         |  CREATE_COMPLETE |  AWS::EC2::SubnetNetworkAclAssociation  ||
||  2016-05-26T11:04:53.854Z|  PublicSubnetRouteTableAssociation1a    |  rtbassoc-d303dcb7         |  CREATE_COMPLETE |  AWS::EC2::SubnetRouteTableAssociation  ||
||  2016-05-26T11:04:52.342Z|  PublicSubnetRouteTableAssociation2a    |  rtbassoc-d103dcb5         |  CREATE_COMPLETE |  AWS::EC2::SubnetRouteTableAssociation  ||
||  2016-05-26T11:04:12.785Z|  VPC                                    |  vpc-70705915              |  CREATE_COMPLETE |  AWS::EC2::VPC                          ||
|+--------------------------+-----------------------------------------+----------------------------+------------------+-----------------------------------------+|
```

#### ステージング環境のビルド(ローカル)
```
$ cd /vagrant/ops/staging/docker/
$ docker-compose build
$ cd /vagrant
$ cp ./ops/staging/docker/Dockerfile .
$ cp ./ops/staging/docker/docker-compose-staging.yml ./docker-compose.yml
$ docker-compose build
```

#### ステージング環境の実行(ローカル)
```
$ docker-compose run app mysql -hdb -uroot -ppassword -e "GRANT ALL ON app_staging.* TO app@'%' IDENTIFIED BY 'password';"
$ docker-compose run app rake db:create
$ docker-compose up
```
`http://127.0.0.1:8080/`で動作を確認する

#### ステージング環境のビルド(リモート)
レポジトリをプッシュする
```
$ docker login
$ docker push k2works/baukis-devops-app:latest
$ docker push k2works/baukis-devops-db:latest
$ docker push k2works/baukis-devops-proxy:latest
```
ElasticBeanstalkのサンプルアプリケーションを作成する

Multi-container Dockerを選択する

サンプルアプリケーションを作成したら[認証情報](https://console.aws.amazon.com/iam/home?region=ap-northeast-1#roles)のロールに移動して２件ロールが新規追加されていることを確認する

aws-elasticbeanstalk-ec2-roleロールを選択してポリシーのアタッチからAmazonEC2ContainerServiceforEC2Roleを追加する

aws-elasticbeanstalk-service-roleロールを選択してポリシーのアタッチからAWSElasticBeanstalkServiceを追加する

ElasticBeanstalkのアプリケーションをセットアップする
```
$ cp ./ops/staging/aws/elastic-beanstalk/Dockerrun.aws.json .
$ eb init

  Select a default region
  1) us-east-1 : US East (N. Virginia)
  2) us-west-1 : US West (N. California)
  3) us-west-2 : US West (Oregon)
  4) eu-west-1 : EU (Ireland)
  5) eu-central-1 : EU (Frankfurt)
  6) ap-southeast-1 : Asia Pacific (Singapore)
  7) ap-southeast-2 : Asia Pacific (Sydney)
  8) ap-northeast-1 : Asia Pacific (Tokyo)
  9) ap-northeast-2 : Asia Pacific (Seoul)
  10) sa-east-1 : South America (Sao Paulo)
  11) cn-north-1 : China (Beijing)
  (default is 3): 8

  Select an application to use
  1) 初めての Elastic Beanstalk アプリケーション
  2) [ Create new Application ]
  (default is 4):

  Enter Application Name
  (default is "vagrant"): baukis-devops
  Application baukis-devops has been created.

  It appears you are using Multi-container Docker. Is this correct?
  (y/n): y

  Select a platform version.
  1) Multi-container Docker 1.9.1 (Generic)
  2) Multi-container Docker 1.6.2 (Generic)
  (default is 1): 1
  Do you want to set up SSH for your instances?
  (y/n): y

  Type a keypair name.
  (Default is aws-eb): baukis-devops
  Generating public/private rsa key pair.
  Enter passphrase (empty for no passphrase):
  Enter same passphrase again:
  Your identification has been saved in /home/vagrant/.ssh/baukis-devops.
  Your public key has been saved in /home/vagrant/.ssh/baukis-devops.pub.
  The key fingerprint is:
  82:a6:48:eb:23:f0:62:f3:5c:43:5a:2d:45:3f:72:9f baukis-devops
  The key's randomart image is:
  +--[ RSA 2048]----+
  |       .         |
  |      . .        |
  |       o +       |
  |     .o o o .    |
  | .  o+..S  E     |
  |o..o+ ..         |
  |oo.. o           |
  |++o . .          |
  |oo+o             |
  +-----------------+
  WARNING: Uploaded SSH public key for "baukis-devops" into EC2 for region ap-northeast-1.
```

VPC情報を確認して変数にセットする
```
$ aws cloudformation describe-stacks --stack-name Baukis-devops-VPC --query 'Stacks[].Outputs[]' --output table
----------------------------------------------------------
|                     DescribeStacks                     |
+-----------------------+------------+-------------------+
|      Description      | OutputKey  |    OutputValue    |
+-----------------------+------------+-------------------+
|  VPC ID               |  VPCID     |  vpc-70705915     |
|  PublicSubnet for ELB |  ELBSUBNET |  subnet-ebb8ab9c  |
|  PublicSubnet for EC2 |  EC2SUBNET |  subnet-ebb8ab9c  |
+-----------------------+------------+-------------------+
$ vi ./ops/staging/aws/eb-create-vpc-env.sh
```
パーミッションを実行可能にする
```
$ chmod 0755 ./ops/staging/aws/eb-create-vpc-env.sh
$ chmod 0755 ./ops/staging/aws/eb-setenv-staging.sh
```

作成したアプリケーションにデプロイスクリプトを実行する
```
$ ./ops/staging/aws/eb-create-vpc-env.sh
$ ./ops/staging/aws/eb-setenv-staging.sh
$ eb printenv
 Environment Variables:
     APP_DATABASE_PASSWORD = password
     RAILS_ENV = staging
     SECRET_KEY_BASE = 483439d1ec14f14bda2236b659b6e0eb6091e81ab15fb7a156b3098e3d6daafa6b7f4aa19083e0b29bcf865f0a81e76ea833001c811694b50152f3e3ef91bb5d
```

#### ステージング環境の実行(リモート)
```
$ eb ssh
$ sudo docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS                         NAMES
96dea8d78106        k2works/baukis-devops-proxy:latest   "nginx -g 'daemon off"   2 minutes ago       Up 2 minutes        443/tcp, 0.0.0.0:80->80/tcp   ecs-awseb-staging-env-kdhsmybukx-2-proxy-fccaccedbfb4cef3c601
41bd6f66aead        k2works/baukis-devops-app:latest     "rails server -b 0.0."   2 minutes ago       Up 2 minutes        0.0.0.0:3000->3000/tcp        ecs-awseb-staging-env-kdhsmybukx-2-app-96d49de1f1caa2c6bd01
c9f2d778e3ce        k2works/baukis-devops-db:latest      "docker-entrypoint.sh"   2 minutes ago       Up 2 minutes        3306/tcp                      ecs-awseb-staging-env-kdhsmybukx-2-db-98ac9a8ef6fd8bb30f00
319ce3f93715        amazon/amazon-ecs-agent:latest       "/agent"                 15 minutes ago      Up 15 minutes       127.0.0.1:51678->51678/tcp    ecs-agent
$ sudo docker exec -it 41bd mysql -hdb -uroot -ppassword -e "GRANT ALL ON app_staging.* TO app@'%' IDENTIFIED BY 'password';"
$ sudo docker exec -it 41bd bundle exec rake db:create
$ exit
```

`http://staging-baukis.ap-northeast-1.elasticbeanstalk.com/`で動作を確認する

### 本番環境の構築
#### パラメータ
| 変数名                  | 値           | 備考         |
|:-----------------------|:-------------|:------------|
| AWS Access Key ID      | xxxxxxxxxxxxxxx                       | aws-cliで設定     |
| AWS Secret Access Key  | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  | aws-cliで設定     |
| Default region name    | ap-northeast-1                             | aws-cliで設定     |
| Default output format  | json                                       | aws-cliで設定     |

以下`#{xxxx}`表記はパラメータの変数を参照すること
なお、AWSシークレットアクセスキーは各自のアカウント情報で取得したものを使う

#### AWS設定
```
$ vagrant up
$ vagrant ssh
$ cd /vagrant
```

```
$ aws configure
 AWS Access Key ID [None]: #{AWS Access Key ID}
 AWS Secret Access Key [None]: #{AWS Secret Access Key}
 Default region name [None]: #{Default region name}
 Default output format [None]: #{Default output format}
$ aws ec2 describe-regions --output table
  ----------------------------------------------------------
  |                     DescribeRegions                    |
  +--------------------------------------------------------+
  ||                        Regions                       ||
  |+-----------------------------------+------------------+|
  ||             Endpoint              |   RegionName     ||
  |+-----------------------------------+------------------+|
  ||  ec2.eu-west-1.amazonaws.com      |  eu-west-1       ||
  ||  ec2.ap-southeast-1.amazonaws.com |  ap-southeast-1  ||
  ||  ec2.ap-southeast-2.amazonaws.com |  ap-southeast-2  ||
  ||  ec2.eu-central-1.amazonaws.com   |  eu-central-1    ||
  ||  ec2.ap-northeast-2.amazonaws.com |  ap-northeast-2  ||
  ||  ec2.ap-northeast-1.amazonaws.com |  ap-northeast-1  ||
  ||  ec2.us-east-1.amazonaws.com      |  us-east-1       ||
  ||  ec2.sa-east-1.amazonaws.com      |  sa-east-1       ||
  ||  ec2.us-west-1.amazonaws.com      |  us-west-1       ||
  ||  ec2.us-west-2.amazonaws.com      |  us-west-2       ||
  |+-----------------------------------+------------------+|
```

VPCの作成
```
$ cd /vagrant/ops/production/aws/
$ aws cloudformation validate-template --template-body file://vpc/vpc-2az-2subnet-pub.template
$ chmod 0755 ./vpc-create-stack.sh
$ ./vpc-create-stack.sh
$ aws cloudformation list-stack-resources --stack-name Baukis-devops-production-VPC --output table
+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
||                                                                    StackResourceSummaries                                                                    ||
|+--------------------------+-----------------------------------------+----------------------------+------------------+-----------------------------------------+|
||   LastUpdatedTimestamp   |            LogicalResourceId            |    PhysicalResourceId      | ResourceStatus   |              ResourceType               ||
|+--------------------------+-----------------------------------------+----------------------------+------------------+-----------------------------------------+|
||  2016-05-27T02:08:48.212Z|  GatewayToInternet                      |  Bauki-Gatew-UVKCQJQULK0Q  |  CREATE_COMPLETE |  AWS::EC2::VPCGatewayAttachment         ||
||  2016-05-27T02:08:53.934Z|  InboundEphemeralPublicNetworkAclEntry  |  Bauki-Inbou-1LAS5ZWB7BPSD |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-27T02:08:54.226Z|  InboundHTTPPublicNetworkAclEntry       |  Bauki-Inbou-1J026C8XFFGAC |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-27T02:08:54.106Z|  InboundHTTPSPublicNetworkAclEntry      |  Bauki-Inbou-1DZR1P3VQZKKV |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-27T02:08:53.918Z|  InboundSSHPublicNetworkAclEntry        |  Bauki-Inbou-1CLC3U0FRSO3W |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-27T02:08:27.435Z|  InternetGateway                        |  igw-dde470b8              |  CREATE_COMPLETE |  AWS::EC2::InternetGateway              ||
||  2016-05-27T02:08:54.035Z|  OutboundPublicNetworkAclEntry          |  Bauki-Outbo-17VW9Q3MH3UHJ |  CREATE_COMPLETE |  AWS::EC2::NetworkAclEntry              ||
||  2016-05-27T02:08:34.109Z|  PublicNetworkAcl                       |  acl-50585235              |  CREATE_COMPLETE |  AWS::EC2::NetworkAcl                   ||
||  2016-05-27T02:09:08.241Z|  PublicRoute                            |  Bauki-Publi-1DB7UMKX55PTD |  CREATE_COMPLETE |  AWS::EC2::Route                        ||
||  2016-05-27T02:08:34.676Z|  PublicRouteTable                       |  rtb-f82e3c9d              |  CREATE_COMPLETE |  AWS::EC2::RouteTable                   ||
||  2016-05-27T02:08:49.119Z|  PublicSubnet1a                         |  subnet-ed20329a           |  CREATE_COMPLETE |  AWS::EC2::Subnet                       ||
||  2016-05-27T02:08:49.153Z|  PublicSubnet1c                         |  subnet-57ffd70e           |  CREATE_COMPLETE |  AWS::EC2::Subnet                       ||
||  2016-05-27T02:09:08.744Z|  PublicSubnetNetworkAclAssociation1a    |  aclassoc-608b5807         |  CREATE_COMPLETE |  AWS::EC2::SubnetNetworkAclAssociation  ||
||  2016-05-27T02:09:09.400Z|  PublicSubnetNetworkAclAssociation1c    |  aclassoc-618b5806         |  CREATE_COMPLETE |  AWS::EC2::SubnetNetworkAclAssociation  ||
||  2016-05-27T02:09:08.424Z|  PublicSubnetRouteTableAssociation1a    |  rtbassoc-c1a57ba5         |  CREATE_COMPLETE |  AWS::EC2::SubnetRouteTableAssociation  ||
||  2016-05-27T02:09:08.455Z|  PublicSubnetRouteTableAssociation1c    |  rtbassoc-c2a57ba6         |  CREATE_COMPLETE |  AWS::EC2::SubnetRouteTableAssociation  ||
||  2016-05-27T02:08:28.832Z|  VPC                                    |  vpc-1f133a7a              |  CREATE_COMPLETE |  AWS::EC2::VPC                          ||
|+--------------------------+-----------------------------------------+----------------------------+------------------+-----------------------------------------+|
```

#### 本番環境のビルド(ローカル)
```
$ cd /vagrant/ops/production/docker/
$ docker-compose build
$ cd /vagrant
$ cp ./ops/production/docker/Dockerfile .
$ cp ./ops/production/docker/docker-compose-production.yml ./docker-compose.yml
$ docker-compose build
```

#### 本番環境の実行(ローカル)
```
$ docker-compose run app mysql -hdb -uroot -ppassword -e "GRANT ALL ON ebdb.* TO app@'%' IDENTIFIED BY 'password';"
$ docker-compose run app rake db:create
$ docker-compose up
```
`http://127.0.0.1:8080/`で動作を確認する

#### 本番環境のビルド(リモート)
レポジトリをプッシュする
```
$ docker login
$ docker push k2works/baukis-devops-app:latest
$ docker push k2works/baukis-devops-db:latest
$ docker push k2works/baukis-devops-proxy:latest
```

VPC情報を確認して変数にセットする
```
$ aws cloudformation describe-stacks --stack-name Baukis-devops-production-VPC --query 'Stacks[].Outputs[]' --output table
-----------------------------------------------------------
|                     DescribeStacks                      |
+------------------------+------------+-------------------+
|       Description      | OutputKey  |    OutputValue    |
+------------------------+------------+-------------------+
|  VPC ID                |  VPCID     |  vpc-1f133a7a     |
|  PublicSubnet for ELB  |  ELBSUBNET |  subnet-ed20329a  |
|  PublicSubnet for EC2  |  EC2SUBNET |  subnet-ed20329a  |
|  PrivateSubnet for RDS |  DBSUBNET1 |  subnet-ed20329a  |
|  PrivateSubnet for RDS |  DBSUBNET2 |  subnet-57ffd70e  |
$ vi ./ops/staging/aws/eb-create-vpc-rds-env.sh
```
パーミッションを実行可能にする
```
$ chmod 0755 ./ops/production/aws/eb-create-vpc-rds-env.sh
$ chmod 0755 ./ops/production/aws/eb-setenv-production.sh
```

作成したアプリケーションにデプロイスクリプトを実行する
```
$ ./ops/production/aws/eb-create-vpc-rds-env.sh
$ eb use production-env
$ ./ops/production/aws/eb-setenv-production.sh
$ eb printenv
 Environment Variables:
     APP_DATABASE_PASSWORD = password
     RAILS_ENV = production
     SECRET_KEY_BASE = 483439d1ec14f14bda2236b659b6e0eb6091e81ab15fb7a156b3098e3d6daafa6b7f4aa19083e0b29bcf865f0a81e76ea833001c811694b50152f3e3ef91bb5d
```

#### 本番環境の実行(リモート)
```
$ eb ssh
$ $ sudo docker ps
  CONTAINER ID        IMAGE                                COMMAND                  CREATED              STATUS              PORTS                         NAMES
  7a018c225cd8        k2works/baukis-devops-proxy:latest   "nginx -g 'daemon off"   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp, 443/tcp   ecs-awseb-production-env-46pze42ppq-2-proxy-decb858df380ffbea101
  4343c23036f9        k2works/baukis-devops-app:latest     "rails server -b 0.0."   About a minute ago   Up About a minute   0.0.0.0:3000->3000/tcp        ecs-awseb-production-env-46pze42ppq-2-app-a2c8b68692c3a5ab3400
  b1b9d81bcd8e        k2works/baukis-devops-db:latest      "docker-entrypoint.sh"   About a minute ago   Up About a minute   3306/tcp                      ecs-awseb-production-env-46pze42ppq-2-db-d0dca892859cdfa0b701
  505eee3df14a        amazon/amazon-ecs-agent:latest       "/agent"                 14 minutes ago       Up 14 minutes       127.0.0.1:51678->51678/tcp    ecs-agent
$ exit
```
`http://baukis.ap-northeast-1.elasticbeanstalk.com/`で動作を確認する

## 開発
### アプリケーションの開発
#### 開発プロジェクト始動
##### 新規Railsアプリケーションの作成
```
$ vagrant up
$ vgarnt ssh
$ cd /vagrant/ops/development/docker/
$ docker-compose build
$ cd /vagrant
$ cp ./ops/development/docker/Dockerfile .
$ cp ./ops/development/docker/docker-compose-development.yml docker-compose.yml
```

###### Gemパッケージのインストール
`Gemfile`を編集後にパッケージのインストールを再実行する
```
$ cd /vagrant
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.2.3 bundle update coffee-rails
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.2.3 bundle install
$ docker-compose build
```

##### Spring
```
$ docker-compose run app bundle exec spring binstub rspec
$ docker-compose run app bundle exec spring status
$ docker-compose run app bundle exec spring stop
```

##### データベースのセットアップ
```
$ docker-compose run app rake db:create
$ docker-compose run app rake db:create RAILS_ENV=test
$ docker-compose up
```
`http://127.0.0.1:3000/`で動作を確認する
終了する場合は`Ctl-c`で終了

##### その他の準備作業
+ ライセンス文書の作成
+ タイムゾーンとロケールの設定
+ ジェネレータの設定

hostsファイルの設定
```
$ sudo sh -c "echo '127.0.0.1 baukis.example.com' >> /etc/hosts"
$ sudo sh -c "echo '127.0.0.1 example.com' >> /etc/hosts"
```

#### RSpec
##### RSpecの初期設定
```
$ docker-compose run app bundle exec rails g rspec:install
$ docker-compose run app bundle exec rspec
```

#### ビジュアルデザイン
##### 架設トップページの作成
+ ルーテイングの設定
+ コントローラとアクションの作成
```
$ docker-compose run app bundle exec rails g controller staff/top
$ docker-compose run app bundle exec rails g controller admin/top
$ docker-compose run app bundle exec rails g controller customer/top
```
+ ERBテンプレートの作成
  - [http://127.0.0.1:3000/staff](http://127.0.0.1:3000/staff)
  - [http://127.0.0.1:3000/admin](http://127.0.0.1:3000/admin)
  - [http://127.0.0.1:3000/customer](http://127.0.0.1:3000/customer)
+ レイアウト
+ 部分テンプレート
+ ヘルパーメソッドの定義

##### Sass/SCSS
+ アセットパイプライン
+ スタイルシートの切り替え
+ ヘッダとフッタのスタイル
+ 見出し(h1要素)のスタイル
+ 色を変数で表現する
+ 寸法を変数で表現する
+ アセットのプリコンパイル
```
$ docker-compose run app bundle exec rake db:create RAILS_ENV=production
$ docker-compose run app bundle exec rake assets:precompile
```

#### エラーページ
##### 500 Internal Server Error
+ 準備作業
+ 例外の補足
+ ビジュアルデザイン
##### 403 Forbidden
+ 例外の補足
+ ERBテンプレートの作成
+ 動作確認
##### 404 Not Found
+ 例外ActionController::RoutingErrorの処理
```
$ docker-compose run app bundle exec rails g controller errors
```
+ 例外ActiveRecord::RecordNotFoundの処理
##### ActiveSupport::Concern

#### ユーザー認証
##### マイグレーション
+ 各種スケルトンの作成
+ マイグレーションスクリプト
+ マイグレーションの実行
```
$ docker-compose run app bundle exec rails g model StaffMember
$ docker-compose run app bundle exec rake db:migrate
$ docker-compose run app bundle exec rake db:reset
```
+ 主キー
```
$ docker-compose run app rails r 'StaffMember.columns.each { |c| p [ c.name, c.type ] }'
```

##### モデル
+ モデルの基礎知識
+ 検索用メールアドレス
+ ハッシュ関数
```
$ docker-compose run app bin/rspec spec/models/staff_member_spec.rb
```
+ シードデータの投入
```
$ docker-compose run app bin/rake db:seed
$ docker-compose run app bin/rake db:reset
$ docker-compose run app bin/rails r 'puts StaffMember.count'
$ docker-compose run app bin/rails r 'puts StaffMember.first.hashed_password'
```
##### セッション
+ セッションとは
+ current_staff_memberメソッドの定義
+ ルーテイングの決定
+ リンクの設置
```
$ mkdir app/views/staff/shared
$ mkdir app/views/admin/shared
$ mkdir app/views/customer/shared
$ cp app/views/shared/_header.html.erb app/views/staff/shared/
$ cp app/views/shared/_header.html.erb app/views/admin/shared/
$ cp app/views/shared/_header.html.erb app/views/customer/shared/
$ rm app/views/shared/_header.html.erb
```
##### フォームオブジェクト
+ フォームの基礎知識
+ フォームオブジェクトとは
```
$ mkdir -p app/forms/staff
```
+ ログインフォームの作成
```
$ docker-compose run app bin/rails g controller staff/sessions
```
+ paramsオブジェクト
+ ログアウト機能の実装
+ スタイルシートの作成

##### サービスオブジェクト
+ Staff::Authenticatorクラス
```
$ mkdir -p app/services/staff
```
+ サービスオブジェクトのspecファイル
```
$ mkdir spec/factories
$ mkdir -p spec/services/staff
$ docker-compose run app bin/rspec spec/services/staff/authenticator_spec.rb
```
##### ログイン・ログアウト後のメッセージ表示
+ フラッシュへの書き込み
+ メッセージの表示

#### ルーテイングの基礎知識
##### アクション単位のルーテイング
##### 名前空間
#### リソースベースのルーテイング
##### ルーティングの分類
##### resourcesメソッド
#### 単数リソース
##### 単数リソースの６つの基本アクション
##### resourceメソッド
##### resourceメソッドのオプション
#### 制約
##### Rails.application.config
##### ホスト名による制約
##### ルーテイングのテスト
```
$ mkdir spec/routing
```

#### 管理者による職員アカウント管理機能（前編）
##### 準備作業
```
$ docker-compose run app bin/rails g controller admin/staff_members
$ docker-compose run app bin/rake db:reset
```
##### indexアクション
##### showアクション
##### newアクション
##### editアクション

#### 管理者による職員アカウント管理機能（後編）
##### createアクション
##### updateアクション
##### destroyアクション

#### String Parameters
##### マスアサインメント脆弱性
##### Strong Parametersによる防御
##### コントローラのテスト
+ attributes_for
```
$ mkdir -p spec/controllers/admin
$ touch spec/controllers/admin/staff_members_controller_spec.rb
```
+ createアクションのテスト
```
$ docker-compose run app bin/rspec spec/controllers/admin/staff_members_controller_spec.rb
```
+ updateアクションのテスト
```
$ docker-compose run app bin/rspec spec/controllers/admin/staff_members_controller_spec.rb
```
##### 400 Bad Request
```
$ touch app/views/errors/bad_request.html.erb
```

#### 職員自身によるアカウント管理機能
##### showアクション
```
$ docker-compose run app bin/rails g controller staff/accounts
$ touch app/views/staff/accounts/show.html.erb
$ touch app/assets/stylesheets/staff/tables.css.scss
```
##### editアクション
```
$ touch app/views/staff/accounts/edit.html.erb
$ touch app/views/staff/accounts/_form.html.erb
$ cp app/assets/stylesheets/admin/form.css.scss app/assets/stylesheets/staff
```
##### updateアクション
```
$ mkdir -p spec/controllers/staff
$ touch spec/controllers/staff/accounts_controller_spec.rb
```
##### updateアクションのテスト
```
$ docker-compose run app bin/rspec spec/controllers/staff/accounts_controller_spec.rb
```


## 運用
### ステージング環境の運用
#### 環境を終了する
```
$ eb use staging-env
$ eb terminate staging-env
 The environment "staging-env" and all associated instances will be terminated.
 To confirm, type the environment name: staging-env
$ aws cloudformation delete-stack --stack-name Baukis-devops-IAM
$ aws cloudformation delete-stack --stack-name Baukis-devops-VPC
```
### 本番環境の運用
#### 環境を終了する
```
$ eb use production-env
$ eb terminate production-env
 The environment "production-env" and all associated instances will be terminated.
 To confirm, type the environment name: production-env
$ aws cloudformation delete-stack --stack-name Baukis-devops-production-IAM
$ aws cloudformation delete-stack --stack-name Baukis-devops-production-VPC
$ aws rds describe-db-snapshots --query 'DBSnapshots[].DBSnapshotIdentifier[]' --output table
---------------------------------------------------------------------
|                        DescribeDBSnapshots                        |
+-------------------------------------------------------------------+
|  awseb-e-46pze42ppq-stack-snapshot-awsebrdsdatabase-voezmmtc745k  |
+-------------------------------------------------------------------+
$ aws rds delete-db-snapshot --db-snapshot-identifier awseb-e-46pze42ppq-stack-snapshot-awsebrdsdatabase-voezmmtc745k
```
### アプリケーションの運用
#### アプリケーションを終了する
```
$ eb terminate --all

 The application "baukis-devops" and all its resources will be deleted.
 This application currently has the following:
 Running environments: 0
 Configuration templates: 0
 Application versions: 9

 To confirm, type the application name: baukis-devops
 Removing application versions from s3.
 INFO: deleteApplication is starting.
 INFO: No environment needs to be terminated.
 INFO: The environment termination step is done.
 INFO: The application has been deleted successfully.
```
#### 開発環境を終了する
```
$ exit
$ vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...
```
## 参照

# 参照
+ [実践Ruby on Rails 4: 現場のプロから学ぶ本格Webプログラミング](http://www.amazon.co.jp/exec/obidos/ASIN/4844335928/oiax-22/ref=nosim)
+ [Baukis - 顧客管理システム](https://github.com/kuroda/baukis-on-rails-4-2)
+ [DockerHub](https://hub.docker.com/)
+ [DockerHub rails](https://hub.docker.com/_/rails/)
+ [DockerHub mysql](https://hub.docker.com/_/mysql/)
