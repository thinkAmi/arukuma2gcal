arukuma2gcal
============

アルクマスケジュールをGoogleカレンダーへと登録するコマンドラインツールです。  
[アルクマキャラバン隊スケジュール](http://arukuma.jp/schedule/)
　  
　  

開発・動作環境
----------

* OS: Windows7 x64 SP1
* Ruby: 2.0.0-p353
* nokogiri 1.6.1 
* google-api-client 0.6.4
* geocoder 1.1.9 
　  
　  

環境設定
----------
コマンドラインから実行するために、以下の設定を行います。

### .env の作成
`.example.env` を `.env` にリネームし、必要な項目を埋めます。

なお、GoogleAPIに関する部分は、`google-api-client` を実行すると、`.google-api.yaml` ができるので、その内容を記載します。  
Windowsで取得する方法については、以下を参照下さい。  
[Windows7 + Ruby + google-api-clientで、GoogleAPI向けOAuth認証用のYAMLファイルを取得する](http://d.hatena.ne.jp/thinkAmi/20131218/1387317778)
　  
　  
また、`GOOGLE_CALENDAR_ID` には、対象のGoogleカレンダーIDを設定します。

　  
　  

### gemのセットアップ
Bundlerでセットアップします。

    cd \path\to\Arukumap
    bundle install --path vendor/bundle
　  
　  

機能
----------
アルクマスケジュールで表示される左側のカレンダーのうち、システム日付と同月内のイベントをGoogleカレンダーに登録します。  
登録するパターンは、以下の2つです。

1. 同月1日～月末までのイベントをすべてを登録する
2. システム日付～月末のイベントを登録する
　  
　  

使い方
----------
###コマンドラインから使う場合
上記パターン別のスクリプトを使います。  
実際の動きとしては、その期間の全イベントを削除してから、登録するようにしてあります。

####同月1日～月末のアルクマスケジュールを登録する

    cd \path\to\Arukumap
    bundle exec ruby gather_all.rb
　  
　  


#### システム日付～月末のアルクマスケジュールを登録する
    cd \path\to\Arukumap
    bundle exec ruby gather.rb
　  
　  
###Herokuで使う場合
Herokuのアプリを作ります。

    heroku create
    git push heroku master

heroku-configプラグインで.envファイルの内容をHerokuアプリの環境変数としてpushして確認します。

    heroku config:push
    heroku config

Herokuのタイムゾーンを確認します。`2013-12-28 5:00:00 +0900` のように日本標準時が設定されていることを確認します。

    heroku run console
    Time.now

Herokuのプロセスを作成・確認します。

    heroku scale clock=1
    heroku ps

Herokuのログで実行されていることを確認します。

    heroku logs


ライセンス
----------
MIT