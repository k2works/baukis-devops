#  開発環境

## 目的
一貫した開発環境をVMで維持構築する

## 前提
| ソフトウェア     | バージョン    | 備考         |
|:---------------|:-------------|:------------|
| vagrant        | 1.7.4        |             |

## 構成
+ プロビジョニング
+ 追加作業
+ リリース

## 詳細

### プロビジョニング
```
$ vagrant up
$ vagrant provision
```

### 追加作業
1. プロビジョニングイメージを保存する
```
$ vagrant sandbox on
$ vagrant sandbox commit
```

1. GoogleChromeをインストールする
1. Emacsをインストールする
```
$ curl -fsSkL https://raw.github.com/rejeep/evm/master/go | bash
$ echo 2.3.0 > /home/vagrant/.evm/.ruby-version
$ sudo mkdir /usr/local/evm
$ sudo chown $USER: /usr/local/evm
$ evm install emacs-24.5
$ evm use emacs-24.5
$ git clone https://github.com/k2works/emacs-env.git
$ cp -r emacs-env/emacs24 .emacs.d
$ curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
$ cd .emacs.d/
$ cask install
```

### リリース
```
$ ./create_box.sh
```

## 参照
+ [俺のEmacs](https://github.com/k2works/emacs-env)
+ [rejeep/evm](https://github.com/rejeep/evm)
+ [cask/cask](https://github.com/cask/cask)