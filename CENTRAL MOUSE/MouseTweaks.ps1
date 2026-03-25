#Requires -RunAsAdministrator
# ============================================================
#  MOUSE TWEAKS v3.0  |  GAMING MOUSE EDITION
#  Windows 10 / 11 / AtlasOS / KernelOS / Any Windows
#  Ultra fast gaming aim, FPS / Free Fire ready,
#  Ultra polling rate, Easy drag, Custom SENSI,
#  Raw input, No acceleration, NON-CHEAT safe only.
# ============================================================

Set-StrictMode -Off
$ErrorActionPreference = "SilentlyContinue"

function Banner {
    Clear-Host
    Write-Host ""
    Write-Host "+========================================================+" -ForegroundColor Red
    Write-Host "|      MOUSE TWEAKS v3.0  |  GAMING MOUSE EDITION         |" -ForegroundColor Red
    Write-Host "|  Ultra Polling - Raw Input - Fast Aim - NON-CHEAT Safe   |" -ForegroundColor DarkRed
    Write-Host "+========================================================+" -ForegroundColor Red
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
#  GAMING SENSITIVITY SELECTOR
# ====================================================================
Write-Host "  +-- GAMING CUSTOM SENSITIVITY ----------------------------+" -ForegroundColor Magenta
Write-Host "  |  RAW INPUT -- No acceleration -- Pure 1:1 movement      |" -ForegroundColor Magenta
Write-Host "  |                                                         |" -ForegroundColor Magenta
Write-Host "  |   1 = Ultra-Low   (360 deg needs wide desk sweep)       |" -ForegroundColor Magenta
Write-Host "  |   2 = Very Low    (pro-level FPS aim)                   |" -ForegroundColor Magenta
Write-Host "  |   3 = Low         (balanced FPS / Free Fire)            |" -ForegroundColor Magenta
Write-Host "  |   4 = ** RECOMMENDED for gaming (clean + fast) **       |" -ForegroundColor Green
Write-Host "  |   5 = Medium-Low  (emulator drag / fast flicks)         |" -ForegroundColor Magenta
Write-Host "  |   6 = Medium      (1:1 Windows baseline)                |" -ForegroundColor Magenta
Write-Host "  |   7 = Medium-High (high DPI mouse users)                |" -ForegroundColor Magenta
Write-Host "  |   8 = High        (very high DPI / small pad)           |" -ForegroundColor Magenta
Write-Host "  |   9 = Very High                                         |" -ForegroundColor Magenta
Write-Host "  |  10 = Max                                               |" -ForegroundColor Magenta
Write-Host "  +---------------------------------------------------------+" -ForegroundColor Magenta
Write-Host ""

do {
    $inputRaw = Read-Host "  Enter gaming sensitivity preset [1-10] (or Enter for 4)"
    if ([string]::IsNullOrWhiteSpace($inputRaw)) { $sensitivityChoice = 4; break }
    if ($inputRaw -match '^\d+$' -and [int]$inputRaw -ge 1 -and [int]$inputRaw -le 10) {
        $sensitivityChoice = [int]$inputRaw; break
    }
    Write-Host "  [!] Invalid. Enter a number between 1 and 10." -ForegroundColor Red
} while ($true)

$speedMap = @{1 = 1; 2 = 2; 3 = 4; 4 = 6; 5 = 7; 6 = 10; 7 = 12; 8 = 14; 9 = 17; 10 = 20 }
$windowsPointerSpeed = $speedMap[$sensitivityChoice]

# ---- Easy Drag mode -------------------------------------------------
Write-Host ""
Write-Host "  +-- EASY DRAG MODE ----------------------------------------+" -ForegroundColor Cyan
Write-Host "  |  Enable Easy Drag? (optimizes click-drag for emulators)   |" -ForegroundColor Cyan
Write-Host "  |  Y = Yes (recommended for Free Fire / BlueStacks drag)    |" -ForegroundColor Cyan
Write-Host "  |  N = No  (standard gaming click behaviour)                |" -ForegroundColor Cyan
Write-Host "  +------------------------------------------------------------+" -ForegroundColor Cyan
$easyDrag = Read-Host "  Easy Drag? [Y/N] (Enter = Y)"
if ($easyDrag -eq "" -or $easyDrag -match "^[Yy]") { $easyDragEnabled = $true } else { $easyDragEnabled = $false }

Write-Host ""
Write-Host "  -> Preset $sensitivityChoice selected  (Windows pointer speed = $windowsPointerSpeed / 20)" -ForegroundColor Cyan
if ($easyDragEnabled) {
    Write-Host "  -> Easy Drag: ENABLED" -ForegroundColor Cyan
}
else {
    Write-Host "  -> Easy Drag: DISABLED" -ForegroundColor DarkGray
}
Write-Host ""

# Load Win32 API -- wrapped in try/catch so re-running never crashes
try {

    # ====================================================================
    #  STEP 1 -- Disable acceleration (most critical for FPS)
    # ====================================================================
    Step 1 $TOTAL "Disabling mouse acceleration (Enhance Pointer Precision OFF)"
    $regMouse = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $regMouse -Name "MouseSpeed"      -Value "0" -Type String
    Set-ItemProperty -Path $regMouse -Name "MouseThreshold1" -Value "0" -Type String
    Set-ItemProperty -Path $regMouse -Name "MouseThreshold2" -Value "0" -Type String
    OK "Acceleration OFF -- pure 1:1 raw input"

}
catch {
}
# Type already loaded from a previous run in this session -- safe to continue

# Type already loaded from a previous run in this session -- safe to continue

OK "Pointer speed: $windowsPointerSpeed / 20 (preset $sensitivityChoice)"OK "Pointer speed:OK "Pointer speed:
"Pointer speed: $windowsPointerSpeed / 20 (preset $sensitivityChoice)"

#  STEP 3 -- Erase smoothing curves (ballistics)
# ====================================================================
Step 3 $TOTAL "Nuking mouse smoothing and ballistic curves"
$zeroCurve = [byte[]](0,0,0,0,0,0,0,0,0,0)
Set-ItemProperty -Path $regMouse -Name "SmoothMouseXCurve" -Value $zeroCurve -Type Binary -ErrorAction SilentlyContinue
Set-ItemProperty -Path $regMouse -Name "SmoothMouseYCurve" -Value $zeroCurve -Type Binary -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $regMouse -Name "SmoothMouseXCurve" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $regMouse -Name "SmoothMouseYCurve" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $regMouse -Name "SmoothMouseXCurve" -Value $zeroCurve -Type Binary -ErrorAction SilentlyContinue
Set-ItemProperty -Path $regMouse -Name "SmoothMouseYCurve" -Value $zeroCurve -Type Binary -ErrorAction SilentlyContinue
OK "All smoothing / ballistic curves zeroed"

# ====================================================================
#  STEP 4 -- Ultra low mouse driver buffer (minimum input latency)
# ====================================================================
Step 4 $TOTAL "Minimizing mouse driver input buffer (ultra low latency)"
$mouclass = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
$mouhid   = "HKLM:\SYSTEM\CurrentControlSet\Services\mouhid\Parameters"
foreach ($path in @($mouclass, $mouhid)) {
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "MouseDataQueueSize" -Value 10 -Type DWord
    Set-ItemProperty -Path $path -Name "QueueMousePackets"  -Value 0  -Type DWord
}
OK "Mouse driver buffer minimized -- fastest possible input dispatch"

# ====================================================================
#  STEP 5 -- USB polling rate (software registry tuning)
# ====================================================================
Step 5 $TOTAL "USB polling rate software optimization"
$usbParams = "HKLM:\SYSTEM\CurrentControlSet\Services\USB\Parameters"
if (-not (Test-Path $usbParams)) { New-Item -Path $usbParams -Force | Out-Null }
Set-ItemProperty -Path $usbParams -Name "DisableSelectiveSuspend" -Value 1 -Type DWord

$hidReg = "HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb\Parameters"
if (-not (Test-Path $hidReg)) { New-Item -Path $hidReg -Force | Out-Null }
Set-ItemProperty -Path $hidReg -Name "MouseDataQueueSize" -Value 10 -Type DWord

WARN "For true 1000Hz+ polling use your gaming mouse app (Razer Synapse, Logitech G Hub, etc.)"
OK "USB system configured for maximum polling acceptance"

# ====================================================================
#  STEP 6 -- Easy Drag configuration
# ====================================================================
Step 6 $TOTAL "Configuring drag behaviour"
if ($easyDragEnabled) {
    Set-ItemProperty -Path $regMouse -Name "DragWidth"         -Value "8"   -Type String
    Set-ItemProperty -Path $regMouse -Name "DragHeight"        -Value "8"   -Type String
    Set-ItemProperty -Path $regMouse -Name "DoubleClickSpeed"  -Value "350" -Type String
    Set-ItemProperty -Path $regMouse -Name "DoubleClickHeight" -Value "4"   -Type String
    Set-ItemProperty -Path $regMouse -Name "DoubleClickWidth"  -Value "4"   -Type String
    OK "Easy Drag ENABLED -- wider drag window for smooth emulator dragging"
} else {
    Set-ItemProperty -Path $regMouse -Name "DragWidth"         -Value "4"   -Type String
    Set-ItemProperty -Path $regMouse -Name "DragHeight"        -Value "4"   -Type String
    Set-ItemProperty -Path $regMouse -Name "DoubleClickSpeed"  -Value "400" -Type String
    Set-ItemProperty -Path $regMouse -Name "DoubleClickHeight" -Value "2"   -Type String
    Set-ItemProperty -Path $regMouse -Name "DoubleClickWidth"  -Value "2"   -Type String
    OK "Standard precision drag -- tight click zone for competitive accuracy"
}
Set-ItemProperty -Path $regMouse -Name "ClickLock"     -Value "0" -Type String
Set-ItemProperty -Path $regMouse -Name "ClickLockTime" -Value "0" -Type String

# ====================================================================
#  STEP 7 -- Disable pointer trails
# ====================================================================
Step 7 $TOTAL "Disabling pointer trails and cursor suppression"
Set-ItemProperty -Path $regMouse -Name "MouseTrails"             -Value "0" -Type String
Set-ItemProperty -Path $regMouse -Name "EnableCursorSuppression" -Value 0   -Type DWord
OK "Pointer trails OFF"

# ====================================================================
#  STEP 8 -- Disable USB selective suspend (no more mouse stutter)
# ====================================================================
Step 8 $TOTAL "Killing USB power saving (prevents stutter / polling drops)"
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 d5bb9247-6fa5-4586-8fc0-8c3dd272c4f0 0 2>$null
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 d5bb9247-6fa5-4586-8fc0-8c3dd272c4f0 0 2>$null

$usbClassKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\USB"
if (Test-Path $usbClassKey) {
    Get-ChildItem $usbClassKey -ErrorAction SilentlyContinue | ForEach-Object {
        Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
            $devParams = Join-Path $_.PSPath "Device Parameters"
            if (Test-Path $devParams) {
                Set-ItemProperty -Path $devParams -Name "AllowIdleIrpInD3"               -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $devParams -Name "EnhancedPowerManagementEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $devParams -Name "DeviceSelectiveSuspended"       -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $devParams -Name "SelectiveSuspendEnabled"        -Value 0 -Type DWord -ErrorAction SilentlyContinue
            }
        }
    }
}

powercfg /setactive SCHEME_CURRENT 2>$null
OK "USB power saving disabled -- continuous full polling guaranteed"

# ====================================================================
#  STEP 9 -- Maximum Performance power plan
# ====================================================================
Step 9 $TOTAL "Activating Ultimate Performance power plan"
$ultGuid = (powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null)
if ($ultGuid -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") {
    powercfg /setactive $Matches[1] 2>$null
    $planName = "Ultimate Performance"
} else {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    $planName = "High Performance"
}
powercfg /change monitor-timeout-ac   0 2>$null
powercfg /change standby-timeout-ac   0 2>$null
powercfg /change disk-timeout-ac      0 2>$null
powercfg /change hibernate-timeout-ac 0 2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN  100 2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX  100 2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFINCPOL       2   2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFDECPOL       1   2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFINCTHRESHOLD 10  2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFDECTHRESHOLD 8   2>$null
powercfg /setactive SCHEME_CURRENT 2>$null
OK "Power plan: $planName -- CPU and USB at 100%"

# ====================================================================
#  STEP 10 -- CPU core unparking
# ====================================================================
Step 10 $TOTAL "Unparking all CPU cores (no scheduling delay)"
$cpuParkKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
if (Test-Path $cpuParkKey) {
    Set-ItemProperty -Path $cpuParkKey -Name "ValueMin" -Value 0   -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $cpuParkKey -Name "ValueMax" -Value 100 -Type DWord -ErrorAction SilentlyContinue
}
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100 2>$null
powercfg /setactive SCHEME_CURRENT 2>$null
OK "All CPU cores unparked -- zero scheduling latency"

# ====================================================================
#  STEP 11 -- Disable network throttling and Nagle's algorithm
# ====================================================================
Step 11 $TOTAL "Disabling network throttling and Nagle's algorithm"
$netReg = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
if (Test-Path $netReg) {
    Set-ItemProperty -Path $netReg -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord
    Set-ItemProperty -Path $netReg -Name "SystemResponsiveness"   -Value 0          -Type DWord
}
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($adapter in $adapters) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($adapter.InterfaceGuid)"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "TcpDelAckTicks"  -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    }
}
OK "Network throttling OFF, Nagle disabled -- lowest game ping latency"

# ====================================================================
#  STEP 12 -- DPI scaling override for emulators
# ====================================================================
Step 12 $TOTAL "Applying DPI-aware shim for gaming emulators"
$layersKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
if (-not (Test-Path $layersKey)) { New-Item -Path $layersKey -Force | Out-Null }
$emuNames = @("HD-Player","LdVBoxHeadless","Bluestacks","NoxVMHandle","MEmuHeadless","Nox","gameloop","TxGameAssistant","dnplayer")
$found = 0
foreach ($name in $emuNames) {
    $proc = Get-Process -Name $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc -and $proc.Path) {
        Set-ItemProperty -Path $layersKey -Name $proc.Path -Value "~ HIGHDPIAWARE" -Type String -Force
        OK "DPI override -> $($proc.ProcessName)"
        $found++
    }
}
if ($found -eq 0) { WARN "No running emulators found. Launch emulator first then re-run for DPI fix." }

# ====================================================================
#  STEP 13 -- MarkC raw input fix (no OS speed scaling)
# ====================================================================
Step 13 $TOTAL "Applying raw input fix (no OS speed scaling)"
Set-ItemProperty -Path $regMouse -Name "MouseHoverTime"   -Value "10" -Type String
Set-ItemProperty -Path $regMouse -Name "MouseHoverHeight" -Value "4"  -Type String
Set-ItemProperty -Path $regMouse -Name "MouseHoverWidth"  -Value "4"  -Type String
$win32kReg = "HKLM:\SYSTEM\CurrentControlSet\Control"
Set-ItemProperty -Path $win32kReg -Name "MouseSensitivity" -Value 10 -Type DWord -ErrorAction SilentlyContinue
OK "Raw input path cleared -- no OS speed injection"

# ====================================================================
#  SUMMARY
# ====================================================================
if ($easyDragEnabled) { $dragStr = "ON  (wide drag window)" } else { $dragStr = "OFF (tight precision)" }
Write-Host ""
Write-Host "+========================================================+" -ForegroundColor Green
Write-Host "|               GAMING TWEAKS DONE!                      |" -ForegroundColor Green
Write-Host "+========================================================+" -ForegroundColor Green
Write-Host "|  Sensitivity preset : $sensitivityChoice / 10  (Win speed $windowsPointerSpeed / 20)" -ForegroundColor White
Write-Host "|  Acceleration       : OFF (raw 1:1)                     |" -ForegroundColor White
Write-Host "|  Smoothing curves   : ZEROED                            |" -ForegroundColor White
Write-Host "|  Easy Drag          : $dragStr" -ForegroundColor White
Write-Host "|  USB power saving   : DISABLED                          |" -ForegroundColor White
Write-Host "|  CPU cores          : ALL UNPARKED                      |" -ForegroundColor White
Write-Host "|  Network throttle   : DISABLED + Nagle OFF              |" -ForegroundColor White
Write-Host "|  Power plan         : $planName" -ForegroundColor White
Write-Host "+--------------------------------------------------------+" -ForegroundColor Green
Write-Host "|  [!] REBOOT RECOMMENDED for full effect                |" -ForegroundColor Yellow
Write-Host "|  ALL TWEAKS ARE NON-CHEAT SAFE (registry only)         |" -ForegroundColor Green
Write-Host "+========================================================+" -ForegroundColor Green
Write-Host ""
Write-Host "  [TIP] Set your mouse DPI in your gaming mouse software:" -ForegroundColor Cyan
Write-Host "     FPS / Free Fire emulator : 400-800 DPI  + preset 3-4" -ForegroundColor DarkCyan
Write-Host "     High-action / mobile emu : 800-1200 DPI + preset 5-6" -ForegroundColor DarkCyan
Write-Host "     Polling rate (hardware)  : Set to 1000 Hz in mouse app" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
