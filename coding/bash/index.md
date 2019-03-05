.ssh/config書き方

Host rokurou
  Hostname            xxx.xxx.xxx.xxx
  User                user
  IdentityFile        ~/.ssh/xxx.pem
  ServerAliveInterval 15
  LocalForward 13389 192.168.1.140:3389
  LocalForward 23389 192.168.1.145:3389

ディレクトリは読み取り権限だけだと開けないので実行のxも付与する
pemは600じゃないとだめ