@echo off

xcopy /e /y /i "EternityResources\Eternity" "%WinDir%\Eternity"
xcopy /e /y /i "EternityResources\System32" "%WinDir%"

for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /format:value') do set "memTemp=%%a"
set /a "mem=%memTemp% + 1024000"
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "%mem%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /t REG_DWORD /d "0" /f

for /f "usebackq tokens=2 delims=\" %%a in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
:: If the "Volatile Environment" key exists, that means it is a proper user. Built in accounts/SIDs do not have this key.
  reg query "HKEY_USERS\%%a" | findstr /c:"Volatile Environment" /c:"AME_UserHive_"
    if not errorlevel 1 (
      if %memTemp% lss 9000000 (
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "3" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SnapAssist" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableBlurBehind" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "TurnOffSPIAnimations" /t REG_DWORD /d "1" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Policies\Microsoft\Windows\DWM" /v "DisallowAnimations" /t REG_DWORD /d "1" /f 
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\DWM" /v "ColorPrevalence" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\SOFTWARE\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d "0" /f
        reg add "HKU\%%a\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f
        reg add "HKU\%%a\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f
        reg add "HKU\%%a\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d "2" /f
        reg add "HKU\%%a\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "1" /f

        reg add "HKCR\Directory\Background\shell\01_Game" /v "HasLUAShield" /t REG_SZ /d "" /f
        reg add "HKCR\Directory\Background\shell\01_Game" /v "MUIVerb" /t REG_SZ /d "Game Boost" /f
        reg add "HKCR\Directory\Background\shell\01_Game" /v "Position" /t REG_SZ /d "Middle" /f
        reg add "HKCR\Directory\Background\shell\01_Game" /v "Icon" /t REG_EXPAND_SZ /d "%%SystemRoot%%\Eternity\GameBoost\game-boost.ico" /f
        reg add "HKCR\Directory\Background\shell\01_Game\command" /ve /t REG_EXPAND_SZ /d "WScript.exe %%SystemRoot%%\Eternity\GameBoost\1.vbs" /f
      )
    )
  )

:: WebThreatDefSvc
for /f %%i in ('reg query "HKLM\SYSTEM\ControlSet001\Services" /s /k "webthreatdefusersvc" /f 2^>nul ^| find /i "webthreatdefusersvc"') do (
  reg add "%%i" /v "Start" /t REG_DWORD /d "4" /f >NUL 2>nul
)

:: Applying SSD/NVMe tweaks
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

:: MSI Mode for USB, GPU, Network
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f

:: Disable DMA remapping
for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /s /f "DmaRemappingCompatible" ^| find /i "Services\" ') do (
    reg add "%%a" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
)

:: Installing Timer Resolution Service
copy "EternityResources\SetTimerResolutionService.exe" "%WinDir%"
call "%WinDir%\SetTimerResolutionService.exe" -Install

PowerShell -NonInteractive -NoLogo -NoP -C "Get-PnpDevice | Where-Object { $_.InstanceId -like 'ACPI\PNP0103\2&daba3ff&*' } | Disable-PnpDevice -Confirm:$false"

:: Delete Microsoft Edge's autorun
for /f "usebackq tokens=2 delims=\" %%a in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	reg query "HKU\%%a" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > nul 2>&1
	if not errorlevel 1 (
		CALL :USERREG "%%a"
	)
)

:USERREG
for /f "usebackq tokens=1 delims= " %%e in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" ^| findstr /i /c:"MicrosoftEdgeAutoLaunch"`) do (
  reg add "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%%e" /t REG_SZ /d "" /f
)