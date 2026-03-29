#Requires -RunAsAdministrator
# ============================================================
#  MOUSE RESET v1.0  |  RESTORE WINDOWS DEFAULTS
#  Reverses ALL changes made by MouseOptimizer.ps1
#  and MouseTweaks.ps1 -- brings Windows back to stock.
#  Windows 10 / 11 / AtlasOS / KernelOS / Any Windows
# ============================================================

Set-StrictMode -Off
$ErrorActionPreference = "SilentlyContinue"

function Banner {
    Clear-Host
    Write-Host ""
    Write-Host "+======================================================+" -ForegroundColor Magenta
    Write-Host "|       MOUSE RESET v1.0  |  RESTORE TO DEFAULT        |" -ForegroundColor Magenta
    Write-Host "|  Removes ALL Mouse Optimizer / Tweaks changes         |" -ForegroundColor DarkMagenta
    Write-Host "+======================================================+" -ForegroundColor Magenta
    Write-Host ""
}

function Step($n, $total, $msg) {
    Write-Host "  [$n/$total] " -ForegroundColor Yellow -NoNewline
    Write-Host $msg -ForegroundColor White
}

function OK($msg)   { Write-Host "  [OK]  $msg" -ForegroundColor Green }
function SKIP($msg) { Write-Host "  [--]  $msg" -ForegroundColor DarkGray }
function WARN($msg) { Write-Host "  [!!]  $msg" -ForegroundColor Yellow }

# ---- Admin check ----------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [X]  Please run as Administrator!" -ForegroundColor Red
    pause; exit 1
}

Banner

Write-Host "  This will UNDO every change made by MouseOptimizer.ps1 and" -ForegroundColor Cyan
Write-Host "  MouseTweaks.ps1, restoring Windows default mouse settings." -ForegroundColor Cyan
Write-Host ""
$confirm = Read-Host "  Continue? [Y/N]"
if ($confirm -notmatch "^[Yy]") {
    Write-Host "  Cancelled." -ForegroundColor DarkGray
    pause; exit 0
}
Write-Host ""

$TOTAL   = 10
$regMouse = "HKCU:\Control Panel\Mouse"

# ====================================================================
#  STEP 1 -- Restore mouse acceleration (Enhance Pointer Precision ON)
# ====================================================================
Step 1 $TOTAL "Restoring mouse acceleration (Windows default)"

# Load the API if not already loaded
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

$SPI_SETMOUSE     = 0x0004
$SPI_SETMOUSESPEED = 0x0071
$SPIF             = 0x03

# Windows default: Threshold1=6, Threshold2=10, Speed=1 (acceleration ON)
$defaultParams = [int[]](6, 10, 1)
$gch = [System.Runtime.InteropServices.GCHandle]::Alloc($defaultParams, [System.Runtime.InteropServices.GCHandleType]::Pinned)
try {
    [MouseAPI]::SystemParametersInfo($SPI_SETMOUSE, 0, $gch.AddrOfPinnedObject(), $SPIF) | Out-Null
}
finally { $gch.Free() }

Set-ItemProperty -Path $regMouse -Name "MouseSpeed"      -Value "1" -Type String
Set-ItemProperty -Path $regMouse -Name "MouseThreshold1" -Value "6" -Type String
Set-ItemProperty -Path $regMouse -Name "MouseThreshold2" -Value "10" -Type String
OK "Acceleration restored (Enhance Pointer Precision = ON)"

# ====================================================================
#  STEP 2 -- Restore default pointer speed (Windows default = 10/20)
# ====================================================================
Step 2 $TOTAL "Restoring default pointer speed (10/20)"
[MouseAPI]::SystemParametersInfo($SPI_SETMOUSESPEED, 0, [IntPtr]10, $SPIF) | Out-Null
Set-ItemProperty -Path $regMouse -Name "MouseSensitivity" -Value "10" -Type String
OK "Pointer speed restored to 10/20 (Windows default)"

# ====================================================================
#  STEP 3 -- Restore default mouse smoothing curves
# ====================================================================
Step 3 $TOTAL "Restoring default SmoothMouseXCurve / SmoothMouseYCurve"
# Windows default curves (5 points, 10 bytes each)
$defaultXCurve = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0xa0,0x02,0x00,0x00,0x00,0x38)
$defaultYCurve = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)

# Remove any existing values first, then write the full default
Remove-ItemProperty -Path $regMouse -Name "SmoothMouseXCurve" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $regMouse -Name "SmoothMouseYCurve" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $regMouse -Name "SmoothMouseXCurve" -Value $defaultXCurve -Type Binary
Set-ItemProperty -Path $regMouse -Name "SmoothMouseYCurve" -Value $defaultYCurve -Type Binary
OK "Smoothing curves restored to Windows defaults"

# ====================================================================
#  STEP 4 -- Restore click / double-click / drag defaults
# ====================================================================
Step 4 $TOTAL "Restoring click speed, drag, hover defaults"
Set-ItemProperty -Path $regMouse -Name "DoubleClickSpeed"  -Value "500"  -Type String
Set-ItemProperty -Path $regMouse -Name "DoubleClickHeight" -Value "4"    -Type String
Set-ItemProperty -Path $regMouse -Name "DoubleClickWidth"  -Value "4"    -Type String
Set-ItemProperty -Path $regMouse -Name "DragWidth"         -Value "4"    -Type String
Set-ItemProperty -Path $regMouse -Name "DragHeight"        -Value "4"    -Type String
Set-ItemProperty -Path $regMouse -Name "ClickLock"         -Value "0"    -Type String
Set-ItemProperty -Path $regMouse -Name "ClickLockTime"     -Value "1200" -Type String
Set-ItemProperty -Path $regMouse -Name "MouseHoverTime"    -Value "400"  -Type String
Set-ItemProperty -Path $regMouse -Name "MouseHoverHeight"  -Value "4"    -Type String
Set-ItemProperty -Path $regMouse -Name "MouseHoverWidth"   -Value "4"    -Type String
Set-ItemProperty -Path $regMouse -Name "MouseTrails"       -Value "0"    -Type String
Set-ItemProperty -Path $regMouse -Name "EnableCursorSuppression" -Value 1 -Type DWord
OK "Click, drag, hover settings restored to Windows defaults"

# ====================================================================
#  STEP 5 -- Restore mouse driver buffer (mouclass / mouhid)
# ====================================================================
Step 5 $TOTAL "Restoring mouse driver buffer size (mouclass / mouhid / HidUsb)"
$mouclass = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
$mouhid   = "HKLM:\SYSTEM\CurrentControlSet\Services\mouhid\Parameters"
$hidReg   = "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb\Parameters"

foreach ($path in @($mouclass, $mouhid)) {
    if (Test-Path $path) {
        # Windows default queue size is 100
        Set-ItemProperty -Path $path -Name "MouseDataQueueSize" -Value 100 -Type DWord -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $path -Name "QueueMousePackets"  -ErrorAction SilentlyContinue
    }
}
if (Test-Path $hidReg) {
    Remove-ItemProperty -Path $hidReg -Name "MouseDataQueueSize" -ErrorAction SilentlyContinue
}
OK "Mouse driver buffer restored to Windows default (100)"

# ====================================================================
#  STEP 6 -- Re-enable USB selective suspend
# ====================================================================
Step 6 $TOTAL "Re-enabling USB selective suspend (power saving)"
$usbParams = "HKLM:\SYSTEM\CurrentControlSet\Services\USB\Parameters"
if (Test-Path $usbParams) {
    Remove-ItemProperty -Path $usbParams -Name "DisableSelectiveSuspend" -ErrorAction SilentlyContinue
}

# Restore USB device power flags
$usbClassKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\USB"
if (Test-Path $usbClassKey) {
    Get-ChildItem $usbClassKey -ErrorAction SilentlyContinue | ForEach-Object {
        Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
            $devParams = Join-Path $_.PSPath "Device Parameters"
            if (Test-Path $devParams) {
                Remove-ItemProperty -Path $devParams -Name "AllowIdleIrpInD3"               -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $devParams -Name "EnhancedPowerManagementEnabled" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $devParams -Name "DeviceSelectiveSuspended"       -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $devParams -Name "SelectiveSuspendEnabled"        -ErrorAction SilentlyContinue
            }
        }
    }
}

# Restore USB power settings in power plan
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 d5bb9247-6fa5-4586-8fc0-8c3dd272c4f0 1 2>$null
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 d5bb9247-6fa5-4586-8fc0-8c3dd272c4f0 1 2>$null
powercfg /setactive SCHEME_CURRENT 2>$null
OK "USB selective suspend restored"

# ====================================================================
#  STEP 7 -- Restore Balanced power plan (Windows default)
# ====================================================================
Step 7 $TOTAL "Restoring Balanced power plan (Windows default)"
# GUID 381b4222-f694-41f0-9685-ff5bb260df2e = Balanced
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
powercfg /change monitor-timeout-ac   10 2>$null
powercfg /change standby-timeout-ac   30 2>$null
powercfg /change disk-timeout-ac      20 2>$null
powercfg /change hibernate-timeout-ac 0  2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN  5   2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX  100 2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFINCPOL       1   2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFDECPOL       1   2>$null
powercfg /setactive SCHEME_CURRENT 2>$null

# Restore CPU core parking defaults
$cpuParkKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
if (Test-Path $cpuParkKey) {
    Set-ItemProperty -Path $cpuParkKey -Name "ValueMin" -Value 0   -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $cpuParkKey -Name "ValueMax" -Value 100 -Type DWord -ErrorAction SilentlyContinue
}
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 0   2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100 2>$null
powercfg /setactive SCHEME_CURRENT 2>$null
OK "Power plan: Balanced restored, CPU parking defaults restored"

# ====================================================================
#  STEP 8 -- Restore network throttling and Nagle's algorithm
# ====================================================================
Step 8 $TOTAL "Restoring network throttling and Nagle's algorithm"
$netReg = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
if (Test-Path $netReg) {
    Set-ItemProperty -Path $netReg -Name "NetworkThrottlingIndex" -Value 10         -Type DWord
    Set-ItemProperty -Path $netReg -Name "SystemResponsiveness"   -Value 20         -Type DWord
}

$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($adapter in $adapters) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($adapter.InterfaceGuid)"
    if (Test-Path $regPath) {
        Remove-ItemProperty -Path $regPath -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $regPath -Name "TCPNoDelay"      -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $regPath -Name "TcpDelAckTicks"  -ErrorAction SilentlyContinue
    }
}
OK "Network throttling restored, Nagle's algorithm re-enabled"

# ====================================================================
#  STEP 9 -- Remove emulator DPI overrides
# ====================================================================
Step 9 $TOTAL "Removing emulator DPI-aware overrides"
$layersKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
if (Test-Path $layersKey) {
    $emuNames = @("HD-Player","LdVBoxHeadless","Bluestacks","NoxVMHandle","MEmuHeadless","Nox","gameloop","TxGameAssistant","dnplayer","mui","dmm_gamelaunch")
    foreach ($name in $emuNames) {
        $proc = Get-Process -Name $name -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($proc -and $proc.Path) {
            Remove-ItemProperty -Path $layersKey -Name $proc.Path -ErrorAction SilentlyContinue
            OK "Removed DPI override for: $($proc.ProcessName)"
        }
    }
    # Also clean up any HIGHDPIAWARE entries by value search
    $entries = Get-ItemProperty -Path $layersKey -ErrorAction SilentlyContinue
    if ($entries) {
        $entries.PSObject.Properties | Where-Object { $_.Value -eq "~ HIGHDPIAWARE" } | ForEach-Object {
            Remove-ItemProperty -Path $layersKey -Name $_.Name -ErrorAction SilentlyContinue
            OK "Removed DPI override for: $($_.Name)"
        }
    }
}
SKIP "If no emulators were running, no DPI entries to remove"

# ====================================================================
#  STEP 10 -- Restore HKLM MouseSensitivity (MarkC fix)
# ====================================================================
Step 10 $TOTAL "Restoring system MouseSensitivity to default"
$win32kReg = "HKLM:\SYSTEM\CurrentControlSet\Control"
Set-ItemProperty -Path $win32kReg -Name "MouseSensitivity" -Value 10 -Type DWord -ErrorAction SilentlyContinue
OK "System MouseSensitivity = 10 (Windows default)"

# ====================================================================
#  SUMMARY
# ====================================================================
Write-Host ""
Write-Host "+======================================================+" -ForegroundColor Magenta
Write-Host "|                RESET COMPLETE!                       |" -ForegroundColor Magenta
Write-Host "+======================================================+" -ForegroundColor Magenta
Write-Host "|  Mouse acceleration    : RESTORED (default ON)       |" -ForegroundColor White
Write-Host "|  Pointer speed         : 10/20 (Windows default)     |" -ForegroundColor White
Write-Host "|  Smoothing curves      : RESTORED (Windows default)  |" -ForegroundColor White
Write-Host "|  Click / drag / hover  : RESTORED (Windows defaults) |" -ForegroundColor White
Write-Host "|  Mouse driver buffer   : RESTORED (default 100)      |" -ForegroundColor White
Write-Host "|  USB selective suspend : RESTORED (enabled)           |" -ForegroundColor White
Write-Host "|  Power plan            : Balanced (Windows default)   |" -ForegroundColor White
Write-Host "|  Network throttling    : RESTORED (Nagle ON)         |" -ForegroundColor White
Write-Host "|  Emulator DPI overrides: REMOVED                      |" -ForegroundColor White
Write-Host "+------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "|  [!] REBOOT RECOMMENDED for full effect              |" -ForegroundColor Yellow
Write-Host "+======================================================+" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
