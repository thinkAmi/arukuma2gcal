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

### .google-api.yaml の作成
`.google-api.example.yaml` をリネームし、必要な項目を埋めます。  

あるいは、 `google-api-client` を実行して、`.google-api.yaml` を取得します。  
Windowsで取得する方法については、以下を参照下さい。 
[Windows7 + Ruby + google-api-clientで、GoogleAPI向けOAuth認証用のYAMLファイルを取得する](http://d.hatena.ne.jp/thinkAmi/20131218/1387317778)
　  
　  

### arukuma_config.yaml の作成
`arukuma_config_example.yaml`をリネームし、対象のGoogleカレンダーIDを設定します。
　  
　  

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
上記パターン別のスクリプトを使います。  
実際の動きとしては、その期間の全イベントを削除してから、登録するようにしてあります。

###同月1日～月末のアルクマスケジュールを登録する

    cd \path\to\Arukumap
    bundle exec ruby gather_all.rb
　  
　  


### システム日付～月末のアルクマスケジュールを登録する
    cd \path\to\Arukumap
    bundle exec ruby gather.rb
　  
　  

ライセンス
----------
MIT