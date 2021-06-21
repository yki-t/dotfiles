#!/usr/bin/env pwsh

function initialize {
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force # can execute script
}

# Scoop packages
function installBasePackages {
  iwr -useb get.scoop.sh | iex
  scoop bucket add extras
  scoop install git sudo pwsh alacritty
  scoop install extras/vcredist2017
  scoop uninstall vcredist2017
}

function setKeyBinds {
  # <Caps Lock> -> <Ctrl>
  $hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"};
  $kbLayout = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout';
  sudo New-ItemProperty -Path $kbLayout -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$hexified);
}

function installFonts {
  scoop bucket add nerd-fonts
  sudo scoop install Cascadia-Code
  sudo scoop install CascadiaCode-NF
  sudo scoop install CascadiaCode-NF-Mono
  Install-Module -Name posh-git   -Scope CurrentUser
  Install-Module -Name oh-my-posh -Scope CurrentUser
  Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
}

# Windows Subsystem Linux
function prepareWsl {
  sudo dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
  sudo dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
  Write-Output 'You may need to `Reboot` for next step'
}

function installWsl {
  if ( -not ( gcm wsl -ea SilentlyContinue) ) { # if 'wsl' command exists
    Write-Error 'wsl command not found. You may need to `Reboot`'
    exit 1
  }

  # WSL 2 Kernel Update
  Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi -UseBasicParsing
  msiexec /i wsl_update_x64.msi /passive /norestart
  rm wsl_update_x64.msi

  wsl --set-default-version 2
}

function installDistro {
  scoop install archwsl
}

# scoop googlechrome

# initialize
# installBasePackages
# setKeyBinds
# installFonts

# # WSL
# prepareWsl
# installWsl
# installDistro


