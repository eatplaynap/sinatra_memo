# Sinatraメモアプリ
Sinatraを使って作成したメモアプリです。
追加、削除、編集が行えます。

# 開発環境
- Ruby 3.0.0
- macOS Big Sur 11.3.1

# 注意
事前にpostgresqlのインストール及びDBの作成が必要になります。
また、ご自身のpostgresql上で、`postgres`ユーザーにログインし、`sinatra_memo`というDBを作成してください。
```
$ psql -U${USER} postgres
postgres=# create user postgres with SUPERUSER;
$ psql -Upostgres
postgres=# DROP TABLE IF EXISTS memo;
CREATE TABLE memo (
  id SERIAL  PRIMARY KEY,
  memo_title TEXT NOT NULL,
  article TEXT NOT NULL
);
```

# アプリケーションの入手から実行まで
```
$ git clone https://github.com/eatplaynap/sinatra_memo.git
$ cd sinatra_memo
$ bundle install
$ ruby memo_app.rb
```

``http://localhost:4567/memos``から一覧ページに飛び、表示を確認してください。
