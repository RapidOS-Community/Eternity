@echo off
:: Installing Game Boost.
:: xcopy /e /y /i "EternityResources\Eternity" "%WinDir%\Eternity"
:: xcopy /e /y /i "EternityResources\System32" "%WinDir%"

:: Deleting Game Boost.
rmdir /q /s "%WinDir%\Eternity"
del /q /f "%WinDir%\System32\EmptyStandbyList.exe"

:: Applying SSD/NVMe tweaks.
call "EternityResources/smartctl.exe" %systemdrive% -i | findstr /c:"Rotation Rate:" | findstr /c:"Solid State Device" >nul 2>&1 && set "STORAGE_TYPE=SSD/NVMe"
call "EternityResources/smartctl.exe" %systemdrive% -i | findstr /c:"NVMe Version:" >nul 2>&1 && set "STORAGE_TYPE=SSD/NVMe"

if "!STORAGE_TYPE!"=="SSD/NVMe" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f 
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d "4" /f 
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\rdyboost" /v "Start" /t REG_DWORD /d "4" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\FontCache" /v "Start" /t REG_DWORD /d "4" /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AlwaysUnloadDLL" /t REG_DWORD /d "1" /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout" /v "EnableAutoLayout" /t REG_DWORD /d "0" /f
    PowerShell -NoP -C "Optimize-Volume -DriveLetter C -ReTrim"
    PowerShell -NoP -C "Disable-MMAGent -MemoryCompression"
    PowerShell -NoP -C "Disable-MMAgent -PageCombining"
)

:: Installing Timer Resolution Service.
copy "EternityResources\SetTimerResolutionService.exe" "%WinDir%"
call "%WinDir%\SetTimerResolutionService.exe" -Install

:: Disabling HPET in Device Manager.
PowerShell -NonInteractive -NoLogo -NoP -C "Get-PnpDevice | Where-Object { $_.InstanceId -like 'ACPI\PNP0103\2&daba3ff&*' } | Disable-PnpDevice -Confirm:$false"