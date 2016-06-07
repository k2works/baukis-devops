# アプリケーションアーキテクチャ

# 目的
+ アプリケーション設計および開発の指針を提示します。
+ アプリケーションのアーキテクチャ全体概要を理解するためのポータル的な位置づけのガイドです。
+ このガイドを起点に各々の詳細ガイドを参照してください。

# 前提
+ 対象者は、アプリ設計者・開発者です。

# 構成
+ [全体概要](#1)
+ [共通設計指針](#2)
+ [共通処理パターン指針](#3)
+ [処理パターン固有指針](#4)
+ [共通実装指針](#5)
+ [物理モデル](#6)

# 詳細
## <a name="1">全体概要</a>
### 全体像
### レイヤー構造
### 処理構造
## <a name="2">共通設計指針</a>
### 設計クラス
### データ共有方式
### メッセージリソース、定数
## <a name="3">共通処理パターン指針</a>
### データアクセス
### 例外処理
### ログ
### セキュリティ
### 初期化
### 国際化
### 日付処理
### 帳票出力
### 固定長データ・ファイルの扱い
### 共通機能
## <a name="4">処理パターン固有指針</a>
### Web固有
### MQ待ち受け処理固有
### バッチ処理固有
### ファイル待ち受け処理固有
## <a name="5">共通実装指針</a>
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
#### before_action
##### 管理者ページのアクセス制御
##### before_actionの継承
##### 職員ページのアクセス制御

#### アクセス制御の強化
##### 強制的ログアウト
##### セッションタイムアウト
#### アクセス制御のテスト
##### 失敗するエグザンプルの修正
```
$ docker-compose run app bin/rspec spec/
```
##### 共有エグザンプル
+ admin/staff_membersコントローラのテスト
```
$ mkdir -p spec/support
$ touch spec/support/shared_examples_for_admin_controllers.rb
```
##### 強制的ログアウトのテスト
```
$ touch spec/controllers/staff/top_controller_spec.rb
$ docker-compose run app bin/rspec spec/controllers/staff/top_controller_spec.rb
```
##### セッションタイムアウトのテスト

#### モデル間の関連付け
##### 一対多の関連付け
##### 外部キー制約
```
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.2.3 bundle install
$ docker-compose build
```
##### StaffEventモデルの追加
+ マイグレーション
```
$ docker-compose run app bin/rails g model staff_event
$ rm spec/models/staff_event_spec.rb
```
+ モデル間の関連付け
```
$ docker-compose run app bin/rake db:migrate
```
##### イベントの記録

#### ネストされたリソース
##### ネストされたリソースとは
+ ルーテイングの設定
+ リンクの設置
##### admin/staff_eventsコントローラ
+ indexアクションの実装
```
$ docker-compose run app rails g controller admin/staff_events
```
+ ERBテンプレートの作成
```
$ touch app/views/admin/staff_events/index.html.erb
$ touch app/views/admin/staff_events/_event.html.erb
```
+ StaffEvent#descriptionメソッドの定義
+ 動作確認

#### ページネーション
##### シードデータの投入
```
$ touch db/seeds/development/staff_events.rb
$ docker-compose run app bin/rake db:reset
```
##### Gemパッケージkaminari
```
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.2.3 bundle install
$ docker-compose build
$ docker-compose run app bin/rails g kaminari:config
$ docker-compose run app bin/rails g kaminari:views default
$ mkdir -p config/locales/views
$ touch config/locales/views/paginate.ja.yml
```
##### indexアクションの修正
##### ERBテンプレートの修正
##### ページネーションのカスタマイズ
+ ERBテンプレートの修正
+ スタイルシートの作成
```
$ touch app/assets/stylesheets/admin/pagination.css.scss
```
#### N + 1問題
##### Gemパッケージquiet_assets
```
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.2.3 bundle install
$ docker-compose build
```
##### N+1問題とは
##### includeメソッド
##### リファクタリング

#### モデルオブジェクトの正規化とバリデーション
##### 値の正規化とバリデーション
##### 準備作業
+ Gemパッケージのインストール
```
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.2.3 bundle install
$ docker-compose build
```
+ スタイルシートの書き換え
##### 氏名とフリガナの正規化とバリデーション
+ validatesメソッド
+ before_validationメソッド
```
$ touch app/models/concerns/string_normalizer.rb
```
##### 開始日と終了日のバリデーション
##### メールアドレスの正規化とバリデーション
+ バリデーション（１）
+ バリデーション（２）
##### 正規化とバリデーションのテスト
+ 正規化とテスト
+ バリデーションのテスト
```
$ docker-compose run app bin/rspec spec/models/staff_member_spec.rb
```
#### 職員が自分のパスワードを変更する機能
##### ルーテイングの設定
##### showアクション
```
$ docker-compose run app bin/rails g controller staff/passwords
```
##### editアクション
+ フォームオブジェクト
```
$ touch app/forms/staff/change_password_form.rb
```
+ アクション
+ ERBテンプレート
```
$ touch app/views/staff/passwords/edit.html.erb
```
##### バリデーション
#### モデルプレゼンター
##### 問題の所在
+ 雑然としたERBテンプレート
＋どこでメソッドを定義するか
##### プレゼンターとは
+ ModelPresenterクラスの定義
```
$ mkdir -p app/presenters
$ touch app/presenters/model_presenter.rb
$ touch app/presenters/staff_member_presenter.rb
```
+ モデルプレゼンターの利用
+ 委譲
#### HtmlBuilder
##### 問題の所在
##### HtmlBuilderモジュルの作成
```
$ mkdir -p app/lib
$ touch app/lib/html_builder.rb
```
##### markupメソッドの使用法
+ 引数なしの場合
+ 引数ありの場合
##### StaffEventPresenter
```
$ touch app/presenters/staff_event_presenter.rb
$ rm app/views/admin/staff_events/_event.html.erb
```
#### フォームプレゼンター
##### 問題の所在
##### FormPresenterクラスの定義
```
$ touch app/presenters/form_presenter.rb
```
##### フォームプレゼンターの利用
+ StaffMemberFormPresenterクラスの作成
```
$ touch app/presenters/staff_member_form_presenter.rb
```
+ 部分テンプレートの書き換え
+ スタイルシートの調整
+ フォームプレゼンターの拡張
##### さらなる改善
+ labelメソッドの書き換え
+ ERBテンプレート内でmarkupメソッドを使う
+ with_optionsメソッド
#### 入力エラーメッセージの生成
##### Errorsオブジェクト
##### エラーメッセージの設定
```
$ mkdir -p config/locales/models
$ touch config/locales/models/errors.ja.yml
$ touch config/locales/models/staff_member.ja.yml
```
##### エラーメッセージの生成
##### パスワード変更フォームの改造
+ ERBテンプレートの書き換え
+ 翻訳データの作成
```
$ mkdir -p config/locales/models/staff
$ touch config/locales/models/staff/change_password_form.ja.yml
```
+ スタイルシートの書き換え

#### jQueryとCoffeeScript
##### 準備作業
+ app/assets/javascriptsディレクトリの分割
```
$ cp app/assets/javascripts/application.js app/assets/javascripts/admin.js
$ cp app/assets/javascripts/application.js app/assets/javascripts/customer.js
$ cp app/assets/javascripts/application.js app/assets/javascripts/staff.js
$ rm app/assets/javascripts/application.js
$ mkdir -p app/assets/javascripts/admin
$ mkdir -p app/assets/javascripts/customer
$ mkdir -p app/assets/javascripts/shared
```
+ レイアウトファイルの修正
+ アセットパイプラインの設定
##### 入力フォームの有効・無効を切り替える
+ フォームプレゼンターの修正
+ CoffeeScriptプログラムの作成
```
$ touch app/assets/javascripts/admin/staff_member_form.js.coffee
```
+ CoffeeScriptプログラムの作成
+ 動作確認
#### Datepicker
##### 準備作業
##### Datepickerの利用
```
$ touch app/assets/javascripts/shared/datepicker.js.coffee
```
##### FormPresenterの修正
#### 単一テーブル継承
##### 単一テーブル継承とは
##### 顧客関連テーブル群の作成
```
$ docker-compose run app bin/rails g model customer
$ docker-compose run app bin/rails g model address
$ rm spec/models/customer_spec.rb
$ rm spec/models/address_spec.rb
$ docker-compose run app bin/rake db:migrate
```
##### 顧客関連モデル群の初期実装
```
$ touch app/models/home_address.rb
$ touch app/models/work_address.rb
```
#### 顧客アカウントの一覧表示・詳細表示
##### シードデータの投入
```
$ touch db/seeds/development/customers.rb
$ docker-compose run app bin/rake db:reset
```
##### 顧客アカウントの一覧表示
+ ルーテイングの設定
+ 職員トップページにリンクを設定
```
$ touch app/views/staff/top/dashboard.html.erb
```
+ staff/customers#indexアクション
```
$ docker-compose run app bin/rails g controller staff/customers
```
+ CustomerPresenter
```
$ touch app/presenters/customer_presenter.rb
```
+ staff/customers#indexアクションのERBテンプレート
```
$ touch app/views/staff/customers/index.html.erb
```
+ スタイルシート
```
$ cp app/assets/stylesheets/admin/pagination.css.scss app/assets/stylesheets/staff
```
##### 顧客アカウントの詳細表示
+ staff/customers#showアクション
+ ModelPresenterの修正
+ AddressPresenterの作成
```
$ touch app/presenters/address_presenter.rb
```
+ Staff/customers#showアクションのERBテンプレート
```
$ touch app/views/staff/customers/show.html.erb
```
#### 顧客アカウントの新規登録・編集フォーム
##### フォームオブジェクトの作成
```
$ touch app/forms/staff/customer_form.rb
```
##### new/editアクションの実装
##### フォームプレゼンターの作成
+ CustomerFormPresenterクラスの作成
```
$ mv app/presenters/staff_member_form_presenter.rb app/presenters/user_form_presenter.rb
$ touch app/presenters/staff_member_form_presenter.rb
$ touch app/presenters/customer_form_presenter.rb
```
+ AddressFormPresenterクラスの作成
```
$ touch app/presenters/address_form_presenter.rb
```
+ FormPresenterクラスの拡張
##### ERBテンプレート本体の作成
```
$ touch app/views/staff/customers/new.html.erb
$ touch app/views/staff/customers/edit.html.erb
```
##### 部分テンプレート群の作成
+ 部分テンプレート（１）
```
$ touch app/views/staff/customers/_form.html.erb
```
+ 部分テンプレート（２）
```
$ touch app/views/staff/customers/_customer_fields.html.erb
```
+ 部分テンプレート（３）
```
$ touch app/views/staff/customers/_home_address_fields.html.erb
```
+ 部分テンプレート（４）
```
$ touch app/views/staff/customers/_work_address_fields.html.erb
```
##### CoffeeScriptプログラムの修正
```
$ cp app/assets/javascripts/admin/staff_member_form.js.coffee app/assets/javascripts/staff/customer_form.js.coffee
$ touch app/assets/javascripts/staff/datepicker.js.coffee
```
##### スタイルシートの修正
```
$ touch app/assets/stylesheets/shared/datepicker.css.scss
```
#### 顧客アカウントの新規登録・更新・削除
##### フォームオブジェクトの拡張
+ assign_attributesメソッドの追加
+ saveメソッドの追加
+ create/updateアクションの実装
##### destroyアクションの実装

#### Capybara
##### Capybaraとは
##### 準備作業
+ FeaturesSpecHelperモジュール
```
$ touch spec/support/features_spec_helper.rb
```
+ ファクトリーの定義
```
$ touch spec/factories/addresses.rb
$ touch spec/factories/customers.rb
```
##### 顧客アカウント更新機能のテスト
```
$ mkdir -p spec/features/staff
$ touch spec/features/staff/customer_management_spec.rb
$ docker-compose run app bin/rspec spec/features/staff/customer_management_spec.rb
```

##### 顧客アカウント新規登録機能のテスト
```
$ docker-compose run app bin/rspec spec/features/staff/customer_management_spec.rb
```
#### 顧客アカウント新規登録・更新機能の改良
##### モデルオブジェクトにおける値の正規化とバリデーション
+ Customerモデル
+ Addressモデル、HomeAddressモデル、WorkAddressモデル
+ 翻訳ファイル
```
$ touch config/locales/models/customer.ja.yml
$ touch config/locales/models/address.ja.yml
```
+ 動作確認
##### フォームオブジェクトのおけるバリデーションの実施
+ CustomerFormの修正
##### バリデーションのテスト
```
$ docker-compose run app bin/rspec spec/features/staff/customer_management_spec.rb
```
##### autosaveオプションによる処理の簡素化
#### ActiveSupport::Concernによるコード共有
##### PersonalNameHolderモジュールの抽出
```
$ touch app/models/concerns/personal_name_holder.rb
$ docker-compose run app bin/rspec
```
##### EmalHolderモジュールの抽出
```
$ touch app/models/concerns/email_holder.rb
$ docker-compose run app bin/rspec
```
##### PasswordHolderモジュールの抽出
```
$ touch app/models/concerns/password_holder.rb
$ docker-compose run app bin/rspec
```
#### 自宅住所と勤務先の任意入力
##### フィールドの有効化・無効化
+ 詳細仕様
+ フォームオブジェクトの書き換え
+ ERBテンプレートの書き換え
+ CoffeeScriptプログラムの書き換え
+ 動作確認
##### フォームオブジェクトの修正
+ assign_attributesメソッドの書き換え（１）
+ assign_attributesメソッドの書き換え（２）
+ assign_attributesメソッドの書き換え（３）
##### Capybaraによるテスト
+ 既存シナリオの修正
+ シナリオの追加
```
$ docker-compose run app bin/rspec spec/features/staff/customer_management_spec.rb
```
#### 顧客電話番号の管理（１）
##### 電話番号管理機能の仕様
##### phonesテーブルとPhoneモデル
+ マイグレーションスクリプト
```
$ docker-compose run app bin/rails g model phone
$ rm spec/models/phone_spec.rb
$ docker-compose run app bin/rake db:migrate
```
+ Phoneモデルの実装
##### 顧客、自宅住所、勤務先との関連付け
+ Customerモデル
+ Addressモデル
+ シードデータの投入
```
$ docker-compose run app bin/rake db:reset
```
#### 顧客電話番号の管理（２）
##### 個人電話番号の入力欄表示
```
$ touch app/views/staff/customers/_phone_fields.html.erb
```
##### 個人電話番号の新規登録、更新、削除
+ CustomerFormクラスの拡張（１）
+ CustomerFormクラスの拡張（２）
+ 動作確認
+ Capybaraによるテスト
```
$ touch spec/features/staff/phone_management_spec.rb
$ docker-compose run app bin/rspec spec/features/staff/phone_management_spec.rb
```
##### 自宅電話の新規登録、更新、削除
+ 自宅電話番号の入力欄表示
+ 自宅電話番号の新規登録、更新、削除
+ Capybaraによるテスト
```
$ docker-compose run app bin/rspec spec/features/staff/phone_management_spec.rb
```
#### 顧客検索フォーム
##### 顧客検索機能の仕様
##### データベーススキーマの見直し
+ インデックスの必要性
```
$ docker-compose run app bin/rails g migration alter_customers1
$ docker-compose run app bin/rails g migration alter_addresses1
```
+ customersテーブルへのインデックス追加
+ addressesテーブルへのインデックスの追加
```
$ docker-compose run app bin/rake db:migrate
```
##### 誕生年、誕生月、誕生日の設定
+ Customerモデルの修正
+ SQL文によるマイグレーション
```
$ docker-compose run app bin/rails g migration update_customers1
$ docker-compose run app bin/rake db:migrate
$ docker-compose run app bin/rake db:rollback
$ docker-compose run app bin/rake db:migrate
```
##### 検索フォームの表示
+ フォームオブジェクトの作成
```
$ touch app/forms/staff/customer_search_form.rb
```
+ indexアクションの修正
+ 検索フォーム用の部分テンプレートの作成
```
$ touch app/views/staff/customers/_search_form.html.erb
```
+ ERBテンプレートの本体の修正
+ スタイルシートの作成
```
$ touch app/assets/stylesheets/staff/search.css.scss
```
#### 検索機能の実装
##### indexアクションの修正
##### フォームオブジェクトの修正（１）
+ 検索条件の設定
+ 動作確認
##### フォームオブジェクトの修正（２）
+ Customerモデルの修正
+ 動作確認
##### 検索文字列の正規化

#### 次回から自動でログイン
##### 顧客のログイン・ログアウト機能
+ ルーテイング
+ コントローラ
```
$ touch app/controllers/customer/base.rb
$ docker-compose run app bin/rails g controller customer/sessions
```
+ ビュー
```
$ cp app/views/admin/sessions/new.html.erb app/views/customer/sessions/
$ cp -f app/views/admin/shared/_header.html.erb app/views/customer/shared/
$ mkdir -p app/forms/customer
$ cp app/forms/admin/login_form.rb app/forms/customer/
$ cp app/assets/stylesheets/admin/flash.css.scss app/assets/stylesheets/customer
$ cp app/assets/stylesheets/admin/sessions.css.scss app/assets/stylesheets/customer
```
+ サービスオブジェクト
```
$ mkdir -p app/services/customer
$ cp app/services/admin/authenticator.rb app/services/customer/
```
+ 動作確認

##### 自動ログイン機能の追加
+ ビューの修正
+ コントローラの修正
+ 動作確認
##### RSpecによるテスト
+ クッキーの値テスト
```
$ mkdir -p spec/controllers/customer
$ touch spec/controllers/customer/session_controller_spec.rb
```
+ クッキーの有効期限テスト

#### IPアドレスによるアクセス制限
##### IPアドレスによるアクセス制限
+ 仕様
+ 準備作業
+ AllowedSourceモデル
```
$ docker-compose run app bin/rails g model AllowedSource
$ docker-compose run app bin/rake db:migrate
$ docker-compose run app bin/rspec spec/models/allowed_source_spec.rb
```
+ クラスメソッドinclude?
+ コントローラの修正
+ 動作確認
```
$ docker-compose run app bin/rails r "AllowedSource.create(namespace: 'staff', ip_address: '127.0.0.1')"
```
##### 許可IPアドレスの管理
+ 仕様
+ ルーテイング
##### 許可IPアドレスの一覧表示
```
$ docker-compose run app bin/rails g controller admin/allowed_sources
$ touch app/presenters/allowed_source_presenter.rb
$ touch app/views/admin/allowed_sources/index.html.erb
$ docker-compose run app bin/rails r "AllowedSource.create(namespace: 'staff', ip_address: '127.0.0.1')"
$ docker-compose run app bin/rails r "AllowedSource.create(namespace: 'staff', ip_address: '192.168.1.*')"
```
+ 許可IPアドレスの新規登録フォーム
```
$ touch app/views/admin/allowed_sources/_new_allowed_source.html.erb
```
+ 許可IPアドレスの追加
+ 許可IPアドレスの一括削除フォーム
+ 許可IPアドレスの一括削除
```
$ touch app/services/admin/allowed_sources_deleter.rb
```
#### 多対多の関連付け
##### 多対多の関連付け
+ プログラム管理機能の概要
+ データベース設計
```
$ docker-compose run app bin/rails g model program
$ docker-compose run app bin/rails g model entry
$ rm -rf spec/models/program_spec.rb
$ rm -rf spec/models/entry_spec.rb
$ docker-compose run app bin/rake db:migrate
```
+ Entryモデルとプログラムモデル
```
$ touch db/seeds/development/programs.rb
$ touch db/seeds/development/entries.rb
$ docker-compose run app bin/rake db:reset
```
##### プログラム管理機能（前編）
+ プログラムの一覧表示
```
$ docker-compose run app bin/rails g controller staff/programs
$ touch app/presenters/program_presenter.rb
$ touch app/views/staff/programs/index.html.erb
$ touch app/views/staff/programs/_program.html.erb
```
+ プログラムの詳細表示
```
$ touch app/views/staff/programs/show.html.erb
$ touch app/assets/stylesheets/staff/divs_and_spans.css.scss
```
##### パフォーマンスの改善
+ ベンチマーク測定の準備
```
$ touch spec/support/performance_spec_helper.rb
```
+ プログラム一覧表示機能のベンチマーク測定
```
$ touch spec/factories/programs.rb
$ touch spec/features/staff/program_management_spec.rb
$ docker-compose run app bin/rspec -t performance spec/features/staff/program_management_spec.rb
$ cat log/performace_spec.log
```
+ includesメソッドによる改善
+ スコープの定義
+ テーブルの左結合(LEFT JOIN)

##### プログラム管理機能（後編）
+ プログラム新規登録・更新フォームの仕様
+ プログラムの新規登録・編集フォーム
```
$ touch app/forms/staff/program_form.rb
$ touch app/presenters/program_form_presenter.rb
$ touch app/views/staff/programs/new.html.erb
$ touch app/views/staff/programs/edit.html.erb
$ touch app/views/staff/programs/_form.html.erb
```
+ プログラムの新規登録と更新
+ バリデーション
```
$ touch app/lib/date_string_validator.rb
$ touch config/locales/models/program.ja.yml
```
##### プログラム申込者管理機能
+ 多数のオブジェクトを一括編集するフォーム
```
$ touch app/views/staff/programs/_entries_form.html.erb
$ touch app/assets/stylesheets/staff/entries.css.scss
```
+ 隠しフィールドとCoffeeScript
```
$ touch app/forms/staff/entries_form.rb
$ touch app/assets/javascripts/staff/entries_form.js.coffee
```
+ 多数のオブジェクトの一括更新処理

##### プログラム一覧表示・詳細表示機能（顧客向け）
+ ルーテイング
+ 顧客トップページの修正
```
$ touch app/views/customer/top/dashboard.html.erb
```
+ プログラムの一覧と詳細
```
$ docker-compose run app bin/rails g controller customer/programs
$ touch app/views/customer/programs/index.html.erb
$ touch app/views/customer/programs/_program.html.erb
$ touch app/views/customer/programs/show.html.erb
$ cp app/assets/stylesheets/staff/tables.css.scss app/assets/stylesheets/customer
$ cp app/assets/stylesheets/staff/pagination.css.scss app/assets/stylesheets/customer
$ cp app/assets/stylesheets/staff/divs_and_spans.css.scss app/assets/stylesheets/customer
```
##### プログラム申し込み機能
+ 仕様の確認
+ 「申し込む」ボタンの設置
+ 申込を受け取る
```
$ docker-compose run app bin/rails g controller customer/entries
$ touch app/services/customer/entry_acceptor.rb
```
+ 排他制御
+ プログラム申し込み機能の仕上げ
+ 申し込みのキャンセル

#### フォームの確認画面
##### 顧客自身によるアカウント管理機能
+ ルーテイング
+ 顧客トップページの修正
+ アカウント詳細表示
```
$ docker-compose run app bin/rails g controller customer/accounts
$ cp app/views/staff/customers/show.html.erb app/views/customer/accounts/
```
+ アカウント編集機能
```
$ cp app/forms/staff/customer_form.rb app/forms/customer/account_form.rb
$ cd app/views/
$ cp staff/customers/edit.html.erb customer/accounts/
$ cp staff/customers/_customer_fields.html.erb customer/accounts/
$ cp staff/customers/_form.html.erb customer/accounts/
$ cp staff/customers/_home_address_fields.html.erb customer/accounts/
$ cp staff/customers/_phone_fields.html.erb customer/accounts/
$ cp staff/customers/_work_address_fields.html.erb customer/accounts/
$ cd ../..
$ cd app/assets/javascripts/
$ cp staff/customer_form.js.coffee customer/account_form.js.coffee
$ cd ../..
$ cp app/assets/stylesheets/staff/form.css.scss app/assets/stylesheets/customer
```
##### 確認画面
+ ルーテイング
+ 編集フォームの修正
```
$ touch app/views/customer/accounts/confirm.html.erb
```
+ 確認画面の仮実装
+ 確認画面用プレゼンターの作成
```
$ touch app/presenters/confirming_form_presenter.rb
$ touch app/presenters/confirming_user_form_presenter.rb
$ touch app/presenters/confirming_address_form_presenter.rb
```
+ 確認画面の本実装
```
$ touch app/views/customer/accounts/_confirming_form.html.erb
$ touch app/views/customer/accounts/_confirming_phone_fields.html.erb
```
+ CoffeeScriptの修正
+ 訂正ボタン
+ Capybaraによるテスト
```
$ mkdir spec/features/customer
$ touch spec/features/customer/account_management_spec.rb
```
#### Ajax
##### 顧客向け問い合わせフォーム
+ データベース設計
```
$ docker-compose run app bin/rails g model message
$ docker-compose run app bin/rake db:migrate
```
+ モデル間の関連付け
```
$ touch app/models/customer_message.rb
$ touch app/models/staff_message.rb
```
+ バリデーション等
+ ルーテイング
+ newアクション
```
$ docker-compose run app bin/rails g controller customer/messages
$ touch app/views/customer/messages/new.html.erb
$ touch app/views/customer/messages/_form.html.erb
```
+ confirmアクション
```
$ touch app/views/customer/messages/confirm.html.erb
$ touch app/views/customer/messages/_confirming_form.html.erb
```
+ createアクション

##### 問い合わせ到着の通知
+ ルーテイング
+ countアクション
```
$ docker-compose run app bin/rails g controller staff/messages
```
+ ヘッダ
```
$ touch app/helpers/staff_helper.rb
```
+ モデル間の関連付け
+ Ajax
```
$ touch app/assets/javascripts/staff/paths.js.cofee.erb
$ touch app/assets/javascripts/staff/messages.js.coffee
```
+ アクセス制限

### ツリー構造
#### 問い合わせの一覧表示と削除
+ ルーテイング
+ リンクの設置
+ メッセージ一覧
```
$ touch app/views/staff/messages/index.html.erb
$ touch app/presenters/message_presenter.rb
```
+ シードデータの投入
```
$ touch db/seeds/development/messages.rb
$ docker-compose run app bin/rake db:reset
```
+ 動作確認
+ 問い合わせの削除
#### メッセージツリーの表示
+ showアクション
```
$ touch app/views/staff/messages/show.html.erb
```
+ メッセージツリーの表示
#### パフォーマンスチューニング
+ パフォーマンス測定
```
$ touch spec/factories/messages.rb
$ touch spec/features/staff/message_management_spec.rb
$ docker-compose run app bin/rspec -t performance spec/features/staff/message_management_spec.rb
$ cat log/performance_spec.log
```
+ パフォーマンスの向上策
```
$ touch app/lib/simple_tree.rb
```
### タグ付け
#### 問い合わせへの返信機能
+ ルーテイング
+ リンクの設置
+ 返信内容編集フォーム
```
$ docker-compose run app bin/rails g controller staff/replies
$ touch app/views/staff/replies/new.html.erb
$ touch app/views/staff/replies/_form.html.erb
$ touch app/views/staff/replies/_message.html.erb
```
+ 確認画面
```
$ touch app/views/staff/replies/confirm.html.erb
$ touch app/views/staff/replies/_confirming_form.html.erb
```
+ 返信の送信
#### メッセージへのタグ付け
+ データベース設計
```
$ docker-compose run app bin/rails g model tag
$ docker-compose run app bin/rails g model message_tag_link
$ rm spec/models/message_tag_link_spec.rb
$ docker-compose run app bin/rake db:migrate
```
+ モデル間の関連付け
+ Tag-itのインストール
```
$ curl https://raw.githubusercontent.com/aehlke/tag-it/master/js/tag-it.js -o vendor/assets/javascripts/tag-it.js
$ curl https://raw.githubusercontent.com/aehlke/tag-it/master/css/jquery.tagit.css -o vendor/assets/stylesheets/jquery.tagit.css
$ curl https://raw.githubusercontent.com/aehlke/tag-it/master/css/tagit.ui-zendesk.css -o vendor/assets/stylesheets/tagit.ui-zendesk.css
 touch app/assets/javascripts/staff/tag-it.js.coffee
```
+ タグの追加・削除インターフェース
+ タグの追加・削除
+ JavaScriptプログラムの改善
+ 照合順序の変更
```
$ docker-compose run app bin/rake db:reset
$ docker-compose run app bin/rails g migration change_collations
$ docker-compose run app bin/rake db:migrate
```
#### タグによるメッセージの絞り込み
+ ルーテイング
+ indexアクションの変更
```
$ touch app/views/staff/messages/_tags.html.erb
```
+ リンクの設置
```
$ touch app/views/staff/messages/_links.html.erb
```
#### 一意制約と排他的ロック
+ 問題の所在
+ 排他制御のための専用テーブルを作る
```
$ docker-compose run app bin/rails g model hash_lock
$ rm spec/models/hash_lock_spec.rb
$ docker-compose run app bin/rake db:migrate
$ touch db/seeds/hash_locks.rb
$ docker-compose run app bin/rails r db/seeds/hash_locks.rb
```
## <a name="6">物理モデル</a>
### 実装モデル
### 配置モデル

# 参照
