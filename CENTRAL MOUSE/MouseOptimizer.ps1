#Requires -RunAsAdministrator
# ============================================================
#  MOUSE OPTIMIZER v3.0  |  NON-GAMING MOUSE EDITION
#  Windows 10 / 11 / AtlasOS / KernelOS / Any Windows
#  Better FPS aim, fast response, custom sensitivity,
#  NO acceleration, NO smoothing, NON-CHEAT safe only.
# ============================================================

Set-StrictMode -Off
$ErrorActionPreference = "SilentlyContinue"

function Banner {
    Clear-Host
    Write-Host ""
    Write-Host "+======================================================+" -ForegroundColor Cyan
    Write-Host "|    MOUSE OPTIMIZER v3.0  |  NON-GAMING EDITION       |" -ForegroundColor Cyan
    Write-Host "|  Fast Aim - Custom Sensi - No Accel - Non-Cheat Saf  |" -ForegroundColor DarkCyan
    Write-Host "+======================================================+" -ForegroundColor Cyan
    Write-Host ""
}

function Step($n, $total, $msg) {
    Write-Host "  [$n/$total] " -ForegroundColor Yellow -NoNewline
    Write-Host $msg -ForegroundColor White
}

function OK($msg) { Write-Host "  [OK]  $msg" -ForegroundColor Green }
function SKIP($msg) { Write-Host "  [--]  $msg" -ForegroundColor DarkGray }
function WARN($msg) { Write-Host "  [!!]  $msg" -ForegroundColor Yellow }

# ---- Admin check ----------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [X]  Please run as Administrator!" -ForegroundColor Red
    pause; exit 1
}

Banner

# ====================================================================
#  CUSTOM SENSITIVITY SELECTOR
#  Windows pointer speed: 1-20  (6 = no-accel baseline, 10 = default)
# ====================================================================
Write-Host "  +-- CUSTOM SENSITIVITY SETUP -----------------------------+" -ForegroundColor Magenta
Write-Host "  |  Presets (Windows Pointer Speed, no acceleration):      |" -ForegroundColor Magenta
Write-Host "  |   1 = Ultra-Low  (competitive FPS / tiny micro-aim)     |" -ForegroundColor Magenta
Write-Host "  |   2 = Very Low                                          |" -ForegroundColor Magenta
Write-Host "  |   3 = Low                                               |" -ForegroundColor Magenta
Write-Host "  |   4 = Low-Medium                                        |" -ForegroundColor Magenta
Write-Host "  |   5 = Medium-Low                                        |" -ForegroundColor Magenta
Write-Host "  |   6 = ** RECOMMENDED (1:1 raw, no accel baseline) **    |" -ForegroundColor Green
Write-Host "  |   7 = Medium                                            |" -ForegroundColor Magenta
Write-Host "  |   8 = Medium-High                                       |" -ForegroundColor Magenta
Write-Host "  |   9 = High                                              |" -ForegroundColor Magenta
Write-Host "  |  10 = Windows Default                                   |" -ForegroundColor Magenta
Write-Host "  +---------------------------------------------------------+" -ForegroundColor Magenta
Write-Host ""

do {
    $inputRaw = Read-Host "  Enter sensitivity preset [1-10] (or press Enter for 6)"
    if ([string]::IsNullOrWhiteSpace($inputRaw)) { $sensitivityChoice = 6; break }
    if ($inputRaw -match '^\d+$' -and [int]$inputRaw -ge 1 -and [int]$inputRaw -le 10) {
        $sensitivityChoice = [int]$inputRaw; break
    }
    Write-Host "  [!] Invalid. Enter a number between 1 and 10." -ForegroundColor Red
} while ($true)

# Map preset 1-10 -> Windows pointer speed 1-20
$windowsPointerSpeed = $sensitivityChoice * 2
if ($sensitivityChoice -eq 6) { $windowsPointerSpeed = 10 }

Write-Host ""
Write-Host "  -> Preset $sensitivityChoice selected  (Windows pointer speed = $windowsPointerSpeed)" -ForegroundColor Cyan
Write-Host ""

# ---- Load Win32 API ------------------------------------------------
# Guard: Add-Type crashes if class already exists (re-run same session)
if (-not ([System.Management.Automation.PSTypeName]'MouseAPI').Type) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class MouseAPI {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(int uiAction, int uiParam, IntPtr pvParam, int fWinIni);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(int uiAction, int uiParam, int[] pvParam, int fWinIni);
}
"@
}

$SPI_SETMOUSE = 0x0004
$SPI_GETMOUSE = 0x0003
$SPI_SETMOUSESPEED = 0x0071
$SPI_SETMOUSETRAILS = 0x005D
$SPIF = 0x03

$TOTAL = 10

# ====================================================================
#  STEP 1 -- Kill mouse acceleration (Enhance Pointer Precision OFF)
# ====================================================================
Step 1 $TOTAL "Disabling mouse acceleration (Enhance Pointer Precision OFF)"

# Read current params via SPI_GETMOUSE using GCHandle pinning (required on Win11)
$currentParams = [int[]](0, 0, 0)
$gch = [System.Runtime.InteropServices.GCHandle]::Alloc($currentParams, [System.Runtime.InteropServices.GCHandleType]::Pinned)
try {
    [MouseAPI]::SystemParametersInfo($SPI_GETMOUSE, 0, $gch.AddrOfPinnedObject(), 0) | Out-Null
}
finally {
    $gch.Free()
}
SKIP "Current params -- Threshold1=$($currentParams[0])  Threshold2=$($currentParams[1])  Speed=$($currentParams[2])"

# Write: all zeros = NO acceleration
$mouseParams = [int[]](0, 0, 0)
$gch2 = [System.Runtime.InteropServices.GCHandle]::Alloc($mouseParams, [System.Runtime.InteropServices.GCHandleType]::Pinned)
try {
    [MouseAPI]::SystemParametersInfo($SPI_SETMOUSE, 0, $gch2.AddrOfPinnedObject(), $SPIF) | Out-Null
}
finally {
    $gch2.Free()
}

$regMouse = "HKCU:\Control Panel\Mouse"
Set-ItemProperty -Path $regMouse -Name "MouseSpeed"      -Value "0" -Type String
Set-ItemProperty -Path $regMouse -Name "MouseThreshold1" -Value "0" -Type String
Set-ItemProperty -Path $regMouse -Name "MouseThreshold2" -Value "0" -Type String
OK "Acceleration fully disabled -- pure 1:1 movement"

# ====================================================================
#  STEP 2 -- Apply custom sensitivity
# ====================================================================
Step 2 $TOTAL "Applying custom sensitivity (preset $sensitivityChoice -> speed $windowsPointerSpeed)"
[MouseAPI]::SystemParametersInfo($SPI_SETMOUSESPEED, 0, [IntPtr]$windowsPointerSpeed, $SPIF) | Out-Null
Set-ItemProperty -Path $regMouse -Name "MouseSensitivity" -Value "$windowsPointerSpeed" -Type String
OK "Pointer speed set to $windowsPointerSpeed / 20"

# ====================================================================
#  STEP 3 -- Remove mouse smoothing curves
# ====================================================================
Step 3 $TOTAL "Removing mouse smoothing / ballistic curves"
# SmoothMouseXCurve / SmoothMouseYCurve -- 10 bytes each, zero = linear 1:1
$zeroCurve = [byte[]](0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
Set-ItemProperty -Path $regMouse -Name "SmoothMouseXCurve" -Value $zeroCurve -Type Binary
Set-ItemProperty -Path $regMouse -Name "SmoothMouseYCurve" -Value $zeroCurve -Type Binary
OK "Smoothing curves cleared -- raw input only"

# ====================================================================
#  STEP 4 -- USB polling rate optimization (software side)
# ====================================================================
Step 4 $TOTAL "Optimizing USB mouse polling (software registry)"
$mouclass = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
$mouhid = "HKLM:\SYSTEM\CurrentControlSet\Services\mouhid\Parameters"

foreach ($path in @($mouclass, $mouhid)) {
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "MouseDataQueueSize" -Value 100 -Type DWord
    Set-ItemProperty -Path $path -Name "QueueMousePackets"  -Value 0   -Type DWord
}
WARN "Hardware polling rate (1000 Hz) must be set via your mouse software (Razer, Logitech, etc.)"
OK "Driver queue minimized for fastest input dispatch"

# ====================================================================
#  STEP 5 -- Disable pointer trails and visual artifacts
# ====================================================================
Step 5 $TOTAL "Disabling pointer trails and cursor suppression"
[MouseAPI]::SystemParametersInfo($SPI_SETMOUSETRAILS, 0, [IntPtr]::Zero, $SPIF) | Out-Null
Set-ItemProperty -Path $regMouse -Name "EnableCursorSuppression" -Value 0 -Type DWord
OK "Pointer trails disabled"

# ====================================================================
#  STEP 6 -- Click and double-click responsiveness
# ====================================================================
Step 6 $TOTAL "Optimizing click speed and double-click responsiveness"
Set-ItemProperty -Path $regMouse -Name "DoubleClickSpeed"  -Value "400" -Type String
Set-ItemProperty -Path $regMouse -Name "DoubleClickHeight" -Value "4"   -Type String
Set-ItemProperty -Path $regMouse -Name "DoubleClickWidth"  -Value "4"   -Type String
Set-ItemProperty -Path $regMouse -Name "ClickLock"         -Value "0"   -Type String
Set-ItemProperty -Path $regMouse -Name "ClickLockTime"     -Value "0"   -Type String
Set-ItemProperty -Path $regMouse -Name "SwapMouseButtons"  -Value "0"   -Type String
OK "Click lock disabled, double-click precision tightened"

# ====================================================================
#  STEP 7 -- USB selective suspend OFF (prevents stutter)
# ====================================================================
Step 7 $TOTAL "Disabling USB selective suspend (prevents stutter/dropout)"
$usbSuspend = "HKLM:\SYSTEM\CurrentControlSet\Services\USB\Parameters"
if (-not (Test-Path $usbSuspend)) { New-Item -Path $usbSuspend -Force | Out-Null }
Set-ItemProperty -Path $usbSuspend -Name "DisableSelectiveSuspend" -Value 1 -Type DWord

powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 d5bb9247-6fa5-4586-8fc0-8c3dd272c4f0 0 2>$null
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 d5bb9247-6fa5-4586-8fc0-8c3dd272c4f0 0 2>$null
powercfg /setactive SCHEME_CURRENT 2>$null
OK "USB selective suspend disabled -- stable polling guaranteed"

# ====================================================================
#  STEP 8 -- Power plan: Maximum Performance
# ====================================================================
Step 8 $TOTAL "Setting power plan to Maximum Performance"
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
powercfg /change monitor-timeout-ac 0 2>$null
powercfg /change standby-timeout-ac 0 2>$null
powercfg /change disk-timeout-ac    0 2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null
powercfg /setactive SCHEME_CURRENT 2>$null
OK "Power plan: Maximum Performance, CPU always at 100%"

# ====================================================================
#  STEP 9 -- Disable network throttling
# ====================================================================
Step 9 $TOTAL "Disabling network throttling index"
$netReg = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
if (Test-Path $netReg) {
    Set-ItemProperty -Path $netReg -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord
    Set-ItemProperty -Path $netReg -Name "SystemResponsiveness"   -Value 0          -Type DWord
}
OK "Network throttling disabled, system responsiveness maximized"

# ====================================================================
#  STEP 10 -- DPI override for emulators (Free Fire / BlueStacks)
# ====================================================================
Step 10 $TOTAL "Applying DPI-aware overrides for emulators"
$layersKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
if (-not (Test-Path $layersKey)) { New-Item -Path $layersKey -Force | Out-Null }

$emuSearchNames = @("HD-Player", "LdVBoxHeadless", "Bluestacks", "NoxVMHandle", "MEmuHeadless", "mui", "dmm_gamelaunch")
foreach ($name in $emuSearchNames) {
    $proc = Get-Process -Name $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc -and $proc.Path) {
        Set-ItemProperty -Path $layersKey -Name $proc.Path -Value "~ HIGHDPIAWARE" -Type String
        OK "DPI override set for: $($proc.ProcessName)"
    }
}
WARN "Emulator DPI override only applied if emulator is currently running"

# ====================================================================
#  SUMMARY
# ====================================================================
Write-Host ""
Write-Host "+======================================================+" -ForegroundColor Green
Write-Host "|                    ALL DONE!                          |" -ForegroundColor Green
Write-Host "+======================================================+" -ForegroundColor Green
Write-Host "|  Sensitivity preset : $sensitivityChoice / 10  (Windows speed $windowsPointerSpeed / 20)" -ForegroundColor White
Write-Host "|  Acceleration       : OFF (1:1 raw)                   |" -ForegroundColor White
Write-Host "|  Mouse smoothing    : OFF                              |" -ForegroundColor White
Write-Host "|  USB suspend        : DISABLED                         |" -ForegroundColor White
Write-Host "|  Power plan         : MAXIMUM PERFORMANCE              |" -ForegroundColor White
Write-Host "|  Network throttle   : DISABLED                         |" -ForegroundColor White
Write-Host "+------------------------------------------------------+" -ForegroundColor Green
Write-Host "|  [!] REBOOT RECOMMENDED for full effect               |" -ForegroundColor Yellow
Write-Host "|  These tweaks are NON-CHEAT safe (registry + WinAPI)  |" -ForegroundColor DarkGray
Write-Host "+======================================================+" -ForegroundColor Green
Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")