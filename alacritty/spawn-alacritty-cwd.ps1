$lastPwd = Get-Content $env:APPDATA/lastpwd
if ($lastPwd -eq "") {
  $lastPwd = "~"
}
Start-Process "C:\Program Files\Alacritty\alacritty.exe" -ArgumentList "--command ""C:\Windows\System32\wsl.exe --cd ""$lastPwd""" -Wait -NoNewWindow
