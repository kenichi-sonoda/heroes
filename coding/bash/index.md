## .ssh/config書き方
```
Host rokurou
  Hostname            xxx.xxx.xxx.xxx
  User                user
  IdentityFile        ~/.ssh/xxx.pem
  ServerAliveInterval 15
  LocalForward 13389 192.168.1.140:3389
  LocalForward 23389 192.168.1.145:3389
```

ディレクトリは読み取り権限だけだと開けないので実行のxも付与する
pemは600じゃないとだめ。configは644とかで大丈夫。

## WSL

### 権限がおかしくなる問題

```
「WSL」起動時に適用する設定は、「/etc/wsl.conf」に記述します。
このファイルが存在しないか、ファイルのフォーマットが不正な場合、デフォルトの状態で「WSL」が起動します。
```

```
WindowsのファイルシステムにはLinuxのメタデータが存在しないため、パーミッションを設定することができませんでした。
しかし、build 17063のリリースによってそのメタデータを扱えるようになりました。メタデータを有効にするには、次のようにmetadataオプションを付けてドライブをマウントします。
```

前回やったこれは起動毎にやらないといけなかったけど
```
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata
```

/etc/wsl.conf を作って
```
[automount]
options = "metadata,umask=22,fmask=11"
```
とすれば永続化できる。