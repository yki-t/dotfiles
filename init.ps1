#!/usr/bin/env pwsh

function initialize {
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force # can execute script
  if ( ! ( Test-Path ~\dotfiles ) ) { # Step 1
    cp -r . ~\dotfiles
  }
}

# Scoop packages
function installBasePackages {
  iwr -useb get.scoop.sh | iex
  scoop install git
  scoop bucket add extras
  scoop install extras/vcredist2017

  scoop install sudo pwsh alacritty windows-terminal
  sudo Install-PackageProvider-Name NuGet -Force
  sudo New-Item -Type SymbolicLink ~\.vimrc -Value ~\dotfiles\.vimrc
  sudo New-Item -Type SymbolicLink ~\.vim -Value ~\dotfiles\.vim
  sudo New-Item -Type SymbolicLink '~\AppData\Local\Microsoft\Windows Terminal\settings.json' -Value ~\dotfiles\settings.json

  New-Item -ItemType Directory ~\AppData\alacritty -ErrorAction SilentlyContinue
  sudo New-Item -Type SymbolicLink ~\AppData\alacritty\.alacritty.yml -Value ~\dotfiles\.alacritty.yml
}

function setKeyBinds {
  # <Caps Lock> -> <Ctrl>
  $hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"};
  $kbLayout = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout';
  sudo New-ItemProperty -Path $kbLayout -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$hexified);
}

function setLanguage {
  # system locale
  Set-WinSystemLocale -SystemLocale ja-JP
  # For
  # # Beta: Use Unicode UTF-8 for worldwide language support
  # # ベータ：ワールドワイド言語で Unicode UTF-8 を使用  
  sudo Set-ItemProperty -LiteralPath HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage -Name ACP -Value 65001
  sudo Set-ItemProperty -LiteralPath HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage -Name MACCP -Value 65001
  sudo Set-ItemProperty -LiteralPath HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage -Name OEMCP -Value 65001
}

function installFonts {
  scoop bucket add nerd-fonts
  sudo scoop install Cascadia-Code
  sudo scoop install CascadiaCode-NF
  # sudo scoop install CascadiaCode-NF-Mono
  Install-Module -Name posh-git   -Scope CurrentUser
  Install-Module -Name oh-my-posh -Scope CurrentUser
  Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
}

# Windows Subsystem Linux
function prepareWsl {
  sudo Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
  sudo Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
}

function installWsl {
  # WSL 2 Kernel Update
  if ( ! ( Test-Path wsl_update_x64.msi ) ) {
    Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi -UseBasicParsing
  }
  msiexec /i wsl_update_x64.msi /passive /norestart
  if ( ! ( Test-Path ubuntu.appx ) ) {
    iwr https://aka.ms/wslubuntu2004 -o ubuntu.appx
  }
  Add-AppxPackage ubuntu.appx
  # rm wsl_update_x64.msi
  wsl --set-default-version 2
}

function installAdditionalPackages {
  scoop install slack
  scoop install thunderbird
  scoop install googlechrome

  # Vim
  scoop install vim
  Invoke-WebRequest https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.ps1 -OutFile installer.ps1
  ./installer.ps1 ~/.cache/dein
  rm installer.ps1

  # Powerline
  pip install powerline-status

  # Keyboard input speed
  Set-ItemProperty 'HKCU:\HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response' -Name AutoRepeatDelay -Value 350
  Set-ItemProperty 'HKCU:\HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response' -Name DelayBeforeAcceptance -Value 350
  Set-ItemProperty 'HKCU:\HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response' -Name AutoRepeatRate -Value 200

  # Enable Transparency
  Set-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name EnableTransparency -Value 1

}

function main {
  if ( ! ( Test-Path initWin ) ) { # Step 1
    initialize
    installBasePackages
    setLanguage
    setKeyBinds
    installFonts
    installAdditionalPackages

    echo 'prepared' > initWin
    Restart-Computer

  } else { # Step 2
    prepareWsl
    installWsl
    installDistro

    rm initWin
  }
}

main

# あいうえお

