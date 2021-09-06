<#
Copyright 2021 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

#this might solve this issue: https://github.com/MicrosoftDocs/windowsserverdocs/issues/2074
$currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0 Restart-Service wuauserv Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU Restart-Service wuauserv

$adminpath = "c:\ProgramData\ssh"
$adminfile = "administrators_authorized_keys"

$sshdService = Get-Service | ? Name -like 'sshd'
if ($sshdService.Count -eq 0)
{
    Write-Output "Installing OpenSSH"
    $isAvailable = Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'

    if (!$isAvailable) {
        throw "OpenSSH is not available on this machine"
    }

    Add-WindowsCapability -Online -Name OpenSSHpowershell.Server~~~~0.0.1.0
}
else
{
    Write-Output "OpenSSH Server service detected - skipping online install..."
}

Start-Service sshd

if (!(Test-Path "$adminpath")) {
    Write-Output "Created new file and text content added"
    New-Item -path $adminpath -name $adminfile -type "file" -value ""
}

Write-Output "$adminpath found."

Write-Output "Setting required permissions..."
icacls $adminpath\$adminfile /remove "NT AUTHORITY\Authenticated Users"
icacls $adminpath\$adminfile /inheritance:r
icacls $adminpath\$adminfile /grant SYSTEM:`(F`)
icacls $adminpath\$adminfile /grant BUILTIN\Administrators:`(F`)

# todo(knabben) - import vagrant pub key

Write-Output "Restarting sshd service..."
Restart-Service sshd
# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. 
$firewall = Get-NetFirewallRule -Name *ssh*

if (!$firewall) {
    throw "OpenSSH is firewall is not configured properly"
}
Write-Output "OpenSSH installed and configured successfully"

# vagrant public key
$src='https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'
$dst='C:\Users\vagrant\.ssh\authorized_keys'
(New-Object System.Net.WebClient).DownloadFile($src, $dst)
