set "Current_Dir=%~dp0"

call "%Current_Dir%\Common.bat"

EmptyStandbyList workingsets
EmptyStandbyList priority0standbylist
EmptyStandbyList workingsets
EmptyStandbyList standbylist
EmptyStandbyList workingsets
EmptyStandbyList modifiedpagelist
EmptyStandbyList workingsets

"%SystemRoot%\Eternity\EcMenu.exe" /Admin /ReduceMemory
