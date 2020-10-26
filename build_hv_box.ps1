# CentOS 8 packer build script
# https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps


# vars
$timestart = (Get-Date)
$LogStamp = (Get-date -Format ddMMyy) + "_" + (get-date -format hhmmsstt)
$BuildLog = ".\logs\build." + $LogStamp + ".log"
$packerlogloc = ".\logs\build.$LogStamp.packer.log"

$Outmsg = "Started at $timestart"
Write-Host  "[*] $Outmsg" -ForegroundColor green -BackgroundColor black;
Add-Content $BuildLog $Outmsg


#
# environment checks
#

# check privs
$userhasadmin = ( [Security.Principal.WindowsPrincipal] ` [Security.Principal.WindowsIdentity]::GetCurrent() ` ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($userhasadmin -eq $true) { 
    Write-Host "[*] In RoleSecurity Principal admin" -ForegroundColor green -BackgroundColor black; 
}
if ($userhasadmin -eq $false) { 
    Write-Host "[*] NO Administrator priv" -ForegroundColor red -BackgroundColor black;
    exit 1;
}

# check files exist
$FileExists = Test-Path packer-conf\centos8.json
If ($FileExists -eq $False) {
    Write-Host "[*] missing: $FileExists" -ForegroundColor red -BackgroundColor black;
    exit 1;
}

# check vagrant and packer are in path
if(!(Get-Command vagrant.exe -ErrorAction SilentlyContinue)) {
    Add-Content $BuildLog "ERROR vagrant.exe not in path"
    Write-Host "[*] vagrant.exe not in path" -ForegroundColor red -BackgroundColor black;
    exit 1;
}
if(!(Get-Command packer.exe -ErrorAction SilentlyContinue)) {
    Add-Content $BuildLog "ERROR packer.exe not in path"
    Write-Host "[*] packer.exe not in path" -ForegroundColor red -BackgroundColor black;
    exit 1;
}


# stop on fail
$ErrorActionPreference = "Stop"


#
# init
#

# create a log file
out-file -Filepath $BuildLog -append -Force -NoClobber

# dump info to log file
$scriptName = $MyInvocation.MyCommand.Name
Write-Host "[*] Log file: $BuildLog" -ForegroundColor green -BackgroundColor black
Write-Host "[*] Script name: $scriptName" -ForegroundColor green -BackgroundColor black
Write-Host "[*] Script location: $PSScriptRoot" -ForegroundColor green -BackgroundColor black
Write-Host "[*] Run from: $(Get-Location)" -ForegroundColor green -BackgroundColor black
Add-Content $BuildLog "script: $PSScriptRoot\$scriptName"


# create an ID for this build
$buildid = ([guid]::NewGuid().ToString())
# log it
$Outmsg = "Build id $($buildid) "
Write-Host  "[*] $Outmsg" -ForegroundColor green -BackgroundColor black;
Add-Content $BuildLog $Outmsg
# set as env var
$Env:cos8vm_id = "$buildid"


# enable all Hyper-V tools PowerShell mods
Write-Host "[*] Enable PowerShell Hyper-V mods " -ForegroundColor green -BackgroundColor black;
Enable-WindowsOptionalFeature -Online -FeatureName  Microsoft-Hyper-V-Tools-All | Out-Null


# check Packer VM is not already running
$CheckVM = "centos8-hv-build"
$VMName = Get-VM -name $CheckVM -ErrorAction SilentlyContinue
if ($VMname) {
    $Outmsg = "ERROR Hyper-V VM $CheckVM is running"
    Write-Host  "[*] $Outmsg" -ForegroundColor red -BackgroundColor black;
    Add-Content $BuildLog $Outmsg
    exit 1;
} 
if (!$VMname) {
    Write-Host "[*] Hyper-V VM $CheckVM not running (good)" -ForegroundColor green -BackgroundColor black;
}

# check HyperV switch used by Packer exists
$VMswitch = Get-VMSwitch -SwitchType External -Name PackerSwitch
if (!$VMswitch) { 
    $Outmsg = "ERROR Hyper-V Switch $VMswitch is missing"
    Write-Host  "[*] $Outmsg" -ForegroundColor red -BackgroundColor black;
    Add-Content $BuildLog $Outmsg
    exit 1;
} 
if ($VMswitch) {
    Write-Host "[*] Hyper-V PackerSwtich good" -ForegroundColor green -BackgroundColor black;
}


#
# clean up old build
#
$Outmsg = "Clean old builds"
Write-Host  "[*] $Outmsg" -ForegroundColor green -BackgroundColor black;
Add-Content $BuildLog $Outmsg

# delete old build items
Remove-Item -LiteralPath ".\temp\" -Force -Recurse
Remove-Item -LiteralPath ".\boxes\" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -LiteralPath ".\output-centos8\" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -LiteralPath ".\packer_cache\" -Force -Recurse -ErrorAction SilentlyContinue

# remove box
#vagrant box remove file://boxes/CentOS8.box


#
# Packer
#
# environment vars for packer
$env:PACKER_LOG = 3
$env:PACKER_LOG_PATH = "$packerlogloc"
$env:PACKER_CACHE_DIR = "./temp/cache/"
Add-Content $BuildLog "packer log: packer_$LogStamp.log"
# validate
$Outmsg = "validate packer json"
Write-Host  "[*] $Outmsg" -ForegroundColor green -BackgroundColor black;
Add-Content $BuildLog $Outmsg
try {
    packer.exe validate -var-file="packer-conf/centos8.var.json" "packer-conf/centos8.json"
}
catch {
    $Outmsg = "invalid packer json"
    Write-Host  "[*] $Outmsg" -ForegroundColor red -BackgroundColor black;
    Add-Content $BuildLog $Outmsg
    exit 1;
}
Start-Sleep -Seconds 1
# build box
$Outmsg = "start packer build"
Write-Host  "[*] $Outmsg" -ForegroundColor green -BackgroundColor black;
Add-Content $BuildLog $Outmsg
try {
    packer.exe build -only=centos8-hyperv -var-file="packer-conf/centos8.var.json" "packer-conf/centos8.json"
}
catch {
    $Outmsg = "error building"
    Write-Host  "[*] $Outmsg" -ForegroundColor red -BackgroundColor black;
    Add-Content $BuildLog $Outmsg
    exit 1;
}
finally {
# show build output
    Write-Host "[*] Build artefacts:" -ForegroundColor green -BackgroundColor black;
    (Get-ChildItem .\boxes\ | Format-Table -HideTableHeaders | Out-String).Trim()
}


#
# Vagrant
#

# check the Vagrant VM is not running
#$CheckVM = "centos8vm"
#$VMName = Get-VM -name $CheckVM -ErrorAction SilentlyContinue
#if ($VMname) { 
#    Write-Host "[*] ERROR Hyper-V VM '$CheckVM running" -ForegroundColor green -BackgroundColor black;
#    exit 1;
#}

#$env:VAGRANT_DEFAULT_PROVIDER = hyperv

# validate vagrant file
$Outmsg = "validate the Vagrantfile"
Write-Host  "[*] $Outmsg" -ForegroundColor green -BackgroundColor black;
Add-Content $BuildLog $Outmsg
try {
    vagrant.exe validate .\Vagrantfile
}
catch {
    $Outmsg = "Vagrantfile validation falied"
    Write-Host  $Outmsg -ForegroundColor red -BackgroundColor black;
    Add-Content $BuildLog $Outmsg
    exit 1;
}

# remove old box
vagrant.exe box remove centos8vm

# add new box
try {
    $Outmsg = "add the box $newhvbox to vagrant store"
    Write-Host  "[*] $Outmsg" -ForegroundColor green -BackgroundColor black;
    Add-Content $BuildLog $Outmsg
    # get box name
    $newhvbox = Get-ChildItem .\boxes\ -Name *.box
    # add
    vagrant.exe box add ./boxes/$newhvbox --name centos8vm   
}
catch {
    $Outmsg = "failed to add box to vagrant store"
    Write-Host  $Outmsg -ForegroundColor red -BackgroundColor black;
    Add-Content $BuildLog $Outmsg
    exit 1;
}



#
# done
#

$timefinish = (Get-Date)
$timetaken = $(($timefinish - $timestart).totalseconds)

$Outmsg = "Done. Build took $timetaken seconds."
Write-Host  "[*] $Outmsg" -ForegroundColor green -BackgroundColor black;
Add-Content $BuildLog $Outmsg
