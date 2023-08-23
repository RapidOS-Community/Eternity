FLTMC >NUL 2>&1 || (
	ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
	ECHO UAC.ShellExecute "%~FS0", "", "", "runas", 1 >> "%TEMP%\GetAdmin.vbs"
	CMD /U /C TYPE "%TEMP%\GetAdmin.vbs">"%TEMP%\GetAdminUnicode.vbs"
	CSCRIPT //NOLOGO "%TEMP%\GetAdminUnicode.vbs"
	DEL /F /Q "%TEMP%\GetAdmin.vbs" >NUL 2>&1
	DEL /F /Q "%TEMP%\GetAdminUnicode.vbs" >NUL 2>&1
	EXIT
)
