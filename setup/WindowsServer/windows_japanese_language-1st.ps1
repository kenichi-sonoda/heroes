#Windows Server 2019��languagePack���uC:\lang.iso�v�Ƃ��ă_�E�����[�h���܂��B
Invoke-WebRequest -Uri https://software-download.microsoft.com/download/pr/17763.1.180914-1434.rs5_release_SERVERLANGPACKDVD_OEM_MULTI.iso -OutFile C:\lang.iso

#�uC:\lang.iso�v���}�E���g���܂��B
$mountResult = Mount-DiskImage C:\lang.iso -PassThru

#�}�E���g����ISO�̃h���C�u���^�[���擾���܂��B
$driveLetter = ($mountResult | Get-Volume).DriveLetter

#�p�X���i�[
$lppath = $driveLetter + ":\x64\langpacks\Microsoft-Windows-Server-Language-Pack_x64_ja-jp.cab"

#�uLpksetup.exe�v�R�}���h���g���ē��{��languagePack���C���X�g�[�����܂��B�C���X�g�[����ċN�����܂��B
C:\windows\system32\Lpksetup.exe /i ja-JP /f /s /p $lppath
