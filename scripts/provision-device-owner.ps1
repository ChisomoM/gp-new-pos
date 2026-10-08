<#
.SYNOPSIS
  Provisions a single POS terminal as this app's Android device owner.

.DESCRIPTION
  Device-owner status (needed to close the back+recents unpin gesture under
  true lock task -- see KioskHelper.kt's configureDeviceOwnerLockTask and
  the kiosk-lock implementation plan) can only be granted by `dpm
  set-device-owner`, and only on a device with no accounts and no existing
  device admin/owner. This script installs the already-built APK, checks
  that precondition, runs the dpm command, and verifies it took.

  This does NOT build the APK -- build it first (see -ApkPath below) and
  do not skip real release signing for a device you intend to keep in the
  field; android/key.properties already holds the release signing config
  for this repo.

.PARAMETER DeviceId
  adb device serial. Required when more than one device/emulator is
  connected; auto-detected when only one is attached.

.PARAMETER ApkPath
  Path to the built, signed APK to install. Defaults to the standard
  Flutter release output path for the production flavor.

.PARAMETER PackageId
  Application ID of the build being provisioned. Defaults to the
  production flavor's id (no suffix). Pass the .stg/.dev suffixed id to
  provision a staging/dev build instead.

.PARAMETER AdbPath
  Full path to adb.exe. Defaults to this machine's known SDK location;
  override on a different provisioning machine.

.EXAMPLE
  .\scripts\provision-device-owner.ps1

.EXAMPLE
  .\scripts\provision-device-owner.ps1 -DeviceId 0123456789ABC -PackageId com.geepay.geepay_pos.dev -ApkPath build\app\outputs\flutter-apk\app-development-debug.apk
#>
param(
    [string]$DeviceId,
    [string]$ApkPath = "build\app\outputs\flutter-apk\app-production-release.apk",
    [string]$PackageId = "com.geepay.geepay_pos",
    [string]$AdminClass = "com.geepay.geepay_pos.KioskDeviceAdminReceiver",
    [string]$AdbPath = "C:\Users\omen\AppData\Local\Android\sdk\platform-tools\adb.exe"
)

$ErrorActionPreference = "Stop"

function Invoke-Adb {
    # Note: do NOT name this parameter $Args -- it's a reserved PowerShell
    # automatic variable and shadowing it breaks @ArgumentList splatting,
    # silently leaving adb with no actual subcommand (it then just prints
    # its own usage/help text instead of running anything).
    param([string[]]$ArgumentList)
    if ($DeviceId) {
        & $AdbPath -s $DeviceId @ArgumentList
    } else {
        & $AdbPath @ArgumentList
    }
}

Write-Host "== 1. Resolving target device ==" -ForegroundColor Cyan
$devices = & $AdbPath devices -l | Select-String -Pattern "\bdevice\b" | Where-Object { $_ -notmatch "List of devices" }
if (-not $DeviceId) {
    if (@($devices).Count -ne 1) {
        Write-Host "More than one (or zero) devices connected. Re-run with -DeviceId <serial>:" -ForegroundColor Red
        & $AdbPath devices -l
        exit 1
    }
    $DeviceId = ($devices[0] -split "\s+")[0]
}
Write-Host "Target device: $DeviceId"

Write-Host "`n== 2. Checking eligibility (no accounts, no existing device admin) ==" -ForegroundColor Cyan
$admins = Invoke-Adb -ArgumentList @("shell", "dumpsys", "device_policy") | Select-String -Pattern "Enabled Device Admins" -Context 0, 2
Write-Host $admins
$accounts = Invoke-Adb -ArgumentList @("shell", "dumpsys", "account") | Select-String -Pattern "Account \{"
if ($accounts) {
    Write-Host "This device has signed-in accounts -- device-owner provisioning will fail. Factory reset required." -ForegroundColor Red
    Write-Host $accounts
    exit 1
}
Write-Host "No accounts found. If 'Enabled Device Admins' above is non-empty, this will also fail -- factory reset first." -ForegroundColor Yellow

Write-Host "`n== 3. Installing $ApkPath ==" -ForegroundColor Cyan
if (-not (Test-Path $ApkPath)) {
    Write-Host "APK not found at $ApkPath -- build it first, e.g.:" -ForegroundColor Red
    Write-Host "  flutter build apk --release --flavor production -t lib/main_production.dart"
    exit 1
}
Invoke-Adb -ArgumentList @("install", "-r", $ApkPath)

Write-Host "`n== 4. Setting device owner ==" -ForegroundColor Cyan
$component = "$PackageId/$AdminClass"
Invoke-Adb -ArgumentList @("shell", "dpm", "set-device-owner", $component)

Write-Host "`n== 5. Verifying ==" -ForegroundColor Cyan
$ownerDump = Invoke-Adb -ArgumentList @("shell", "dumpsys", "device_policy") | Select-String -Pattern "Device Owner" -Context 0, 3
Write-Host $ownerDump
if ($ownerDump -match [regex]::Escape($PackageId)) {
    Write-Host "`nSuccess: $PackageId is the device owner on $DeviceId." -ForegroundColor Green
} else {
    Write-Host "`nCould not confirm device-owner status -- check the output above." -ForegroundColor Red
    exit 1
}
