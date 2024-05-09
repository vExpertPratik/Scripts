#First save the Windows update KB number of the updates you want to uninstall in a txt file under C:\New Folder\list.txt
#Now save the uninstall.bat file with below content in the same folder & run the bat file as Administrator
#This will reboot the server so it requires downtime

@echo off

for /f %%i in (‘type c:\list.txt’) do (
echo “Uninstalling KB%%i”

wusa /uninstall /kb:%%i /quiet /norestart

)

echo “Uninstallations Complete.”
echo.echo “Rebooting…”
echo.
shutdown /r