Internet-connect wsus
Hyper-V VM on a laptop



## export the metadata
mkdir E:\EXPORT
cd "C:\Program Files\Update Services\Tools\"
wsusutil.exe export E:\EXPORT\export.xml.gz E:\EXPORT\export.log
Stop-Computer


## copy files to USB
Mount VHDX to host windows
robocopy the mounted virtual hard disk to USB

robocopy /MIR 




Install-WindowsFeature UpdateServices -Restart

cd "C:\Program Files\Update Services\Tools\"
wsusutil.exe postinstall CONTENT_DIR=E:\WSUS


robocopy

wsusutil.exe import export.xml.gz import.log