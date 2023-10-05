@ECHO OFF
REM BFCPEOPTIONSTART
REM Advanced BAT to EXE Converter www.BatToExeConverter.com
REM BFCPEEXE=D:\Project\Source\Good-life\ConnectDBShellScriptGit\win.exe
REM BFCPEICON=
REM BFCPEICONINDEX=-1
REM BFCPEEMBEDDISPLAY=0
REM BFCPEEMBEDDELETE=1
REM BFCPEADMINEXE=0
REM BFCPEINVISEXE=0
REM BFCPEVERINCLUDE=1
REM BFCPEVERVERSION=1.0.0.0
REM BFCPEVERPRODUCT=Connect Good-life Settings
REM BFCPEVERDESC=Product Description
REM BFCPEVERCOMPANY=BWV
REM BFCPEVERCOPYRIGHT=vinhtt
REM BFCPEWINDOWCENTER=1
REM BFCPEDISABLEQE=0
REM BFCPEWINDOWHEIGHT=25
REM BFCPEWINDOWWIDTH=80
REM BFCPEWTITLE=Window Title
REM BFCPEOPTIONEND
@echo off
setlocal enabledelayedexpansion

set name=%USERDOMAIN%

set /p "AWS_ACCESS_KEY_ID=Enter Your AWS_ACCESS_KEY_ID: "
set /p "AWS_SECRET_ACCESS_KEY=Enter Your AWS_SECRET_ACCESS_KEY: "
set /p "AWS_DEFAULT_REGION=Enter Your AWS_DEFAULT_REGION: "
set /p "INSTANCE_ID=Enter Your INSTANCE_ID: "
set /p "SQL_PRIVATE_HOST=Enter Your SQL_PRIVATE_HOST: "
set /p "BASTION_HOST_IP=Enter Your BASTION_HOST_IP: "
set /p "PORT=Enter Your LISTEN_PORT_DB: "

set "AWS_ACCESS_KEY_ID=!AWS_ACCESS_KEY_ID!"
set "AWS_SECRET_ACCESS_KEY=!AWS_SECRET_ACCESS_KEY!"
set "AWS_DEFAULT_REGION=!AWS_DEFAULT_REGION!"

:: Find the process ID using netstat
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /r /c:"%PORT%"') do (
    set "pid=%%a"
    :: Kill the process using taskkill
    taskkill /F /PID !pid!
)

:: Change this to the path of your PEM file
set "pem_file=%USERPROFILE%\.ssh\good_life_dev_bastion_%name%"

:: Create the security public key
if not exist "!pem_file!" (
    :: Create the PEM file
    ssh-keygen -t rsa -b 2048 -f "!pem_file!" -N ""
) else (
    echo Public key file already exists!
)

:: Run AWS command
echo !pem_file!

aws ec2-instance-connect send-ssh-public-key --instance-id !INSTANCE_ID! --instance-os-user ec2-user --ssh-public-key file://!pem_file!.pub

:: Agent forwarding
ssh -i "!pem_file!" -f -N -L %PORT%:!SQL_PRIVATE_HOST!:5432 ec2-user@!BASTION_HOST_IP! -v -o StrictHostKeyChecking=no

endlocal
