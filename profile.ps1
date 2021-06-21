# Ctrl + d で Exit
Import-Module PSReadLine
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

# bash風のtab補完
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# PowerShellでPowerLineを適用するための設定
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox

