#Windows Server 2019のlanguagePackを「C:\lang.iso」としてダウンロードします。
Invoke-WebRequest -Uri https://software-download.microsoft.com/download/pr/17763.1.180914-1434.rs5_release_SERVERLANGPACKDVD_OEM_MULTI.iso -OutFile C:\lang.iso

#「C:\lang.iso」をマウントします。
$mountResult = Mount-DiskImage C:\lang.iso -PassThru

#マウントしたISOのドライブレターを取得します。
$driveLetter = ($mountResult | Get-Volume).DriveLetter

#パスを格納
$lppath = $driveLetter + ":\x64\langpacks\Microsoft-Windows-Server-Language-Pack_x64_ja-jp.cab"

#「Lpksetup.exe」コマンドを使って日本語languagePackをインストールします。インストール後再起動します。
C:\windows\system32\Lpksetup.exe /i ja-JP /f /s /p $lppath
