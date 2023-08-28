set "Current_Dir=%~dp0"

call "%Current_Dir%\common.bat"
call "%Current_Dir%\boost.bat"

EmptyStandbyList priority0standbylist
EmptyStandbyList standbylist
EmptyStandbyList modifiedpagelist
EmptyStandbyList workingsets

"%SystemRoot%\Eternity\EcMenu.exe" /Admin /ReduceMemory