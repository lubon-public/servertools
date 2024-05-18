# servertools
Installation instructions:  
download git portable version 64 bit https://git-scm.com/download/win  
install in c:\program files\lubonscripts\gitportable  
install powershell 7.4: https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.msi  
Open cmd box  
cd Downloads  
msiexec.exe /package PowerShell-7.4.2-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=0 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=0 ENABLE_PSREMOTING=0 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1  
cd c:\program files\lubonscripts  
gitportable\git-cmd.exe  
run git clone https://github.com/lubon-public/servertools.git   
exit



