#UI�̌������{��ŏ㏑�����܂��B
Set-WinUILanguageOverride -Language ja-JP

#����/���t�̌`����Windows�̌���Ɠ����ɂ��܂��B
Set-WinCultureFromLanguageListOptOut -OptOut $False

#���P�[�V��������{�ɂ��܂��B
Set-WinHomeLocation -GeoId 0x7A

#�V�X�e�����P�[������{�ɂ��܂��B
Set-WinSystemLocale -SystemLocale ja-JP

#�^�C���]�[���𓌋��ɂ��܂��B
Set-TimeZone -Id "Tokyo Standard Time"

#�T�[�o�[���ċN�����܂��B
Restart-Computer
