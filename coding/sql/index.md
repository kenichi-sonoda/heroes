# SQL編

SQLのクエリ作成などで役に立ちそうなものを書く。
railsのmodelとか、ASP.NETのlinqとかは省く。
直接SQL文書かないといけない時のために。

- placeholder
  - 第一引数は`$`で記述して、第二引数で渡す技術
  - 文字列とかで`''`を記述するとクエリ発行やばい
```
client.query("SELECT * FROM stooges WHERE name IN ($1, $2, $3)", ['larry', 'curly', 'moe'], ...);
```
- Node6.10なら文字列に式を埋め込めるよ
  - https://html5experts.jp/takazudo/17396/
