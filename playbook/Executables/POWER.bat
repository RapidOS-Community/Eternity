@echo off

setlocal EnableDelayedExpansion
for /f "delims=:{}" %%i in ('wmic path Win32_systemenclosure get ChassisTypes^| findstr [0-9]') do set "CHASSIS=%%i"
for %%i in (8 9 10 11 12 14 18 21 13 31 32 30) do if "!CHASSIS!"=="%%i" set "DEVICE_TYPE=LAPTOP"
if "!DEVICE_TYPE!"=="LAPTOP" (set "POWER_SAVING=ON")

if "!POWER_SAVING!"=="OFF" (
:: Disable Advanced Configuration and Power Interface (ACPI) devices
    call toggleDev.cmd "ACPI Processor Aggregator" "Microsoft Windows Management Interface for ACPI"

    PowerShell -NoP -C "$usb_devices = @('Win32_USBController', 'Win32_USBControllerDevice', 'Win32_USBHub'); $power_device_enable = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi; foreach ($power_device in $power_device_enable){$instance_name = $power_device.InstanceName.ToUpper(); foreach ($device in $usb_devices){foreach ($hub in Get-WmiObject $device){$pnp_id = $hub.PNPDeviceID; if ($instance_name -like \"*$pnp_id*\"){$power_device.enable = $False; $power_device.psbase.put()}}}}"

    for %%a in (
        "AllowIdleIrpInD3"
        "D3ColdSupported"
        "DeviceSelectiveSuspended"
        "EnableIdlePowerManagement"
        "EnableSelectiveSuspend"
        "EnhancedPowerManagementEnabled"
        "IdleInWorkingState"
        "SelectiveSuspendEnabled"
        "SelectiveSuspendOn"
        "WaitWakeEnabled"
        "WakeEnabled"
        "WdfDirectedPowerTransitionEnable"
    ) do (
        for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "%%~a" ^| findstr "HKEY"') do (
            reg add "%%b" /v "%%~a" /t REG_DWORD /d "0" /f
        )
    )
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" /v "DefaultPnPCapabilities" /t REG_DWORD /d "24" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f
)
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "IdlePowerMode" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Storage" /v "StorageD3InModernStandby" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EventProcessorEnabled" /t REG_DWORD /d "0" /f

:: ReviOS
PowerShell -NonInteractive -NoLogo -NoP -C "& {$cpu = Get-CimInstance Win32_Processor; $cpuName = $cpu.Name; if ($cpu.Manufacturer -eq 'GenuineIntel') { if ($cpuName.Substring(0, 2) -eq 'In') { Write-Host 'Intel CPU older than 10th generation.' } else { $cpuGen = [int]($cpuName.Substring(0, 2)); if ($cpuGen -gt 11) {powercfg -changename 3ff9831b-6f80-4830-8178-736cd4229e7b 'Windows''s Ultimate Performance with optimized settings for 12th Intel CPUs.'; powercfg -s 3ff9831b-6f80-4830-8178-736cd4229e7b; powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 0; powercfg -setacvalueindex scheme_current sub_processor SCHEDPOLICY 2; powercfg /setactive scheme_current }}};}"