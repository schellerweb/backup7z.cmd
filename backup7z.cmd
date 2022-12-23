@echo off
::-----------------------------------------------------------------------------
::      File: backup7z.cmd
::    Author: H. Scheller
::    Update: 10.12.2022
::   Version: 1.07
::    Manual: doc/backup7z.pdf
::-----------------------------------------------------------------------------
::      Note: There is nothing to change on this script. Use the external 
::            INI-file and call this script with the INI-file as argument.
::-----------------------------------------------------------------------------
setlocal enableextensions enabledelayedexpansion
set _version=1.07
setx _dateformat /k "HKEY_CURRENT_USER\Control Panel\International\sShortDate" >NUL
if "%_dateformat:~0,1%"=="d" (set _ym=%date:~-4%%date:~-7,2%&&set _ymd=%date:~-4%%date:~-7,2%%date:~-10,2%)
if "%_dateformat:~0,1%"=="M" (set _ym=%date:~-4%%date:~-10,2%&&set _ymd=%date:~-4%%date:~-10,2%%date:~-7,2%)
set _hms=%time:~0,2%%time:~3,2%%time:~6,2%
set _hms=%_hms: =0%
set _start=%time%
set _ini=%~1
call :EVENT 1
if "%_ini%"=="" (call :EVENT 260)
if not exist "%_ini%" (call :EVENT 261)
if not exist "%ProgramFiles%\7-Zip\7z.exe" (call :EVENT 262)
call :READINI "%_ini%"
:: [Backup]
if "%backup_tasks%"=="" (call :EVENT 263)
if not exist "%backup_destination%" (call :EVENT 264)
call :LCASE %backup_type%
set backup_type=%__lcase%
if not "%backup_type%"=="zip" (if not "%backup_type%"=="7z" (set backup_type=zip&&call :EVENT 128))
if "%backup_type%"=="zip" (set _option=-tzip -mx=1 -mtc=on -bse0 -bso0 -bsp1 -w%TEMP%)
if "%backup_type%"=="7z" (set _option=-mx=1 -ms=off -mf=off -bse0 -bso0 -bsp1 -w%TEMP%)
if not "%backup_password%"=="" (set _option=-p%backup_password% %_option%)
if 1%backup_output% NEQ +1%backup_output% (set backup_output=1&&call :EVENT 129)
if %backup_output% lss 1 (set backup_output=1&&call :EVENT 129)
if %backup_output% gtr 30 (set backup_output=1&&call :EVENT 129)
:: [System]
if "%system_name%"=="" (set system_name=%COMPUTERNAME%)
if "%system_logfile%"=="" (set system_logfile=%~dp0%system_name%.log&&call :EVENT 130)
if "%system_shutdown%"=="" (set system_shutdown=0&&call :EVENT 131)
if 1%system_shutdown% NEQ +1%system_shutdown% (set system_shutdown=0&&call :EVENT 131)
if %system_shutdown% lss 0 (set system_shutdown=0&&call :EVENT 131)
if %system_shutdown% gtr 1 (set system_shutdown=0&&call :EVENT 131)
if "%system_shutdowntime%"=="" (set system_shutdowntime=120&&call :EVENT 132)
if 1%system_shutdowntime% NEQ +1%system_shutdowntime% (set system_shutdowntime=120&&call :EVENT 132)
if %system_shutdowntime% lss 30 (set system_shutdowntime=120&&call :EVENT 132)
if %system_shutdowntime% gtr 600 (set system_shutdowntime=120&&call :EVENT 132)
if "%system_wait%"=="" (set system_wait=0&&call :EVENT 133)
if 1%system_wait% NEQ +1%system_wait% (set system_wait=0&&call :EVENT 133)
if %system_wait% lss 0 (set system_wait=0&&call :EVENT 133)
if %system_wait% gtr 1 (set system_wait=0&&call :EVENT 133)
:: [SMTP]
if "%smtp_email%"=="" (set smtp_email=0&&call :EVENT 134)
if 1%smtp_email% NEQ +1%smtp_email% (set smtp_email=0&&call :EVENT 134)
if %smtp_email% lss 0 (set smtp_email=0&&call :EVENT 134)
if %smtp_email% gtr 1 (set smtp_email=0&&call :EVENT 134)
if "%smtp_host%"=="" (if %smtp_email%==1 (set smtp_email=0&&call :EVENT 135))
if "%smtp_port%"=="" (if %smtp_email%==1 (set smtp_email=0&&call :EVENT 136))
if "%smtp_username%"=="" (if %smtp_email%==1 (set smtp_email=0&&call :EVENT 137))
if "%smtp_password%"=="" (if %smtp_email%==1 (set smtp_email=0&&call :EVENT 138))
if "%smtp_sender%"=="" (if %smtp_email%==1 (set smtp_email=0&&call :EVENT 139))
if "%smtp_recipient%"=="" (if %smtp_email%==1 (set smtp_email=0&&call :EVENT 140))
set _syslog=%TEMP%\%system_name%_%_ymd%_%_hms%_sys.log
set _evtlog=%TEMP%\%system_name%_%_ymd%_%_hms%_evt.log
if %system_shutdown%==1 (set _shutdown=on) else (set _shutdown=off)
if %system_wait%==1 (set _wait=on) else (set _wait=off)
if %smtp_email%==1 (set _email=on) else (set _email=off)
if "%backup_password%"=="" (set _backuptype=%backup_type%) else (set _backuptype=%backup_type% [password protected])
set _prn[0]=%~n0 %_version%
set _prn[-]=--------------------------------------------------------------------------------
set _prn[1]= Settings: %_ini%
set _prn[2]=    Tasks: %backup_tasks%
set _prn[3]=    Dest.: %backup_destination%
set _prn[4]=     Type: %_backuptype%
set _prn[5]=   Output: %backup_output%
set _prn[6]=  LogFile: %system_logfile%
set _prn[7]= Shutdown: %_shutdown% %system_shutdowntime% sec.
set _prn[8]=     Wait: %_wait%
set _prn[9]=    Email: %_email%
set _prn[10]=     Host: %smtp_host%
set _prn[11]=     Port: %smtp_port%
set _prn[12]= Username: %smtp_username%
set _prn[13]=   Sender: %smtp_sender%
set _prn[14]=Recipient: %smtp_recipient%
echo %_prn[0]%&&echo %_prn[0]%>%_syslog%
echo %_prn[-]%&&echo %_prn[-]%>>%_syslog%
echo %_prn[1]%&&echo %_prn[1]%>>%_syslog%
echo %_prn[2]%&&echo %_prn[2]%>>%_syslog%
echo %_prn[3]%&&echo %_prn[3]%>>%_syslog%
echo %_prn[4]%&&echo %_prn[4]%>>%_syslog%
echo %_prn[5]%&&echo %_prn[5]%>>%_syslog%
echo %_prn[6]%&&echo %_prn[6]%>>%_syslog%
echo %_prn[7]%&&echo %_prn[7]%>>%_syslog%
echo %_prn[8]%&&echo %_prn[8]%>>%_syslog%
echo %_prn[9]%&&echo %_prn[9]%>>%_syslog%
if backup_email==1 (
	echo %_prn[10]%&&echo %_prn[10]%>>%_syslog%
	echo %_prn[11]%&&echo %_prn[11]%>>%_syslog%
	echo %_prn[12]%&&echo %_prn[12]%>>%_syslog%
	echo %_prn[13]%&&echo %_prn[13]%>>%_syslog%
	echo %_prn[14]%&&echo %_prn[14]%>>%_syslog%
)
echo %_prn[-]%&&echo %_prn[-]%>>%_syslog%
for /f "tokens=1,2,3 delims=;" %%A in (%backup_tasks%) do (
	set _tskTime=!time!
	set _tskName=%%A
	set _tskPath=%%B
	set _tskExcl=%%C
	set _tskName=!_tskName: =!
	if not "!_tskExcl!"=="" (set _tskExcl=!_tskExcl: =!)
	call :UCASE !_tskName!
	set _tskName=!__ucase!
	if exist "!_tskPath!" (
		call :OUTPUT %backup_output%
	    set _outPath=!backup_destination!\!_outPath!
	    if not exist "!_outPath!" (mkdir "!_outPath!")
	    set _inc=!_outPath!\!_inc!
	    set _com=!_outPath!\!_com!
	    set _exc=%TEMP%!_tskName!_%_ymd%.exc
	    if not "%backup_exclude%"=="" (if not "!_tskExcl!"=="" (set _tskExcl=%backup_exclude%,!_tskExcl!) else (set _tskExcl=%backup_exclude%))
	    if not "!_tskExcl!"=="" (call :EXCLUDE2FILE "!_tskExcl!" "!_exc!")
	    if not exist !_com! (
			set _tskFile=!_com!
			set _tskType=Complete
		    if exist "!_exc!" (
			    set _tskCmd= a "!_com!" "!_tskPath!" %_option% -xr0"@!_exc!"
		    ) else (
			    set _tskCmd= a "!_com!" "!_tskPath!" %_option%
		    )
	    ) else (
			set _tskFile=!_inc!
			set _tskType=Incremental
		    if exist !_inc! (
			    del !_inc!
		    )
		    if exist "!_exc!" (
			    set _tskCmd= u "!_com!" "!_tskPath!" %_option% -u- -up0q3r2x2y2z0w2^^!"!_inc!" -xr0"@!_exc!"
		    ) else (
			    set _tskCmd=" u "!_com!" "!_tskPath!" %_option% -u- -up0q3r2x2y2z0w2^^!"!_inc!"
		    )
	    )
	) else (
		set _tskPath=!_tskPath! [not found.]
		set _tskFile=-
		set _tskExcl=-
		set _tskType=-
		set _tskCmd=
		set _tskStatus=Path not found.
		call :EVENT 141
	)
	set _prn[1]=     Task: !_tskName!
	set _prn[2]=     Path: !_tskPath!
	set _prn[3]=  Exclude: !_tskExcl!
	set _prn[4]=     Type: !_tskType!
	set _prn[5]=     File: !_tskFile!
	echo !_prn[1]!&&echo !_prn[1]!>>%_syslog%
	echo !_prn[2]!&&echo !_prn[2]!>>%_syslog%
	echo !_prn[3]!&&echo !_prn[3]!>>%_syslog%
	echo !_prn[4]!&&echo !_prn[4]!>>%_syslog%
	echo !_prn[5]!&&echo !_prn[5]!>>%_syslog%
	if not "!_tskCmd!"=="" (
		if exist !_inc! (del !_inc!)
		call :EVENT 4
		"%ProgramFiles%\7-Zip\7z.exe" !_tskCmd!
		set _tskStatus=ok
		if errorlevel   1 (set _tskStatus=Warning some files are locked.&&call :EVENT 254)
		if errorlevel   2 (set _tskStatus=Fatal error.&&call :EVENT 256)
		if errorlevel   7 (set _tskStatus=Command line error.&&call :EVENT 257)
		if errorlevel   8 (set _tskStatus=Not enough memory.&&call :EVENT 258)
		if errorlevel 255 (set _tskStatus=User canceld.&&call :EVENT 259)		
	)
	call :RUNTIME "!_tskTime!"
	set _prn[6]=   Status: !_tskStatus!
	set _prn[7]=  Runtime: !__runtime!
	echo !_prn[6]!&&echo !_prn[6]!>>%_syslog%	
	echo !_prn[7]!&&echo !_prn[7]!>>%_syslog%	
	echo %_prn[-]%&&echo %_prn[-]%>>%_syslog%	
	call :EVENT 5
)
goto :END

:OUTPUT
::-----------------------------------------------------------------------------
:: Set _outpath, _com and _inc
:: Author: H. Scheller
:: Update: 6.12.2022
:: call :OUTPUT <backup_output>
::-----------------------------------------------------------------------------
if %~1==1 (set _outPath=!_ym!&&set _com=!system_name!_!_tskName!_!_ym!00.!backup_type!&&set _inc=!system_name!_!_tskName!_!_ymd!.!backup_type!)
if %~1==2 (set _outPath=!_ym!&&set _com=!system_name!_!_ym!00_!_tskName!.!backup_type!&&set _inc=!system_name!_!_ymd!_!_tskName!.!backup_type!)
if %~1==3 (set _outPath=!_ym!&&set _com=!_tskName!_!system_name!_!_ym!00.!backup_type!&&set _inc=!_tskName!_!system_name!_!_ymd!.!backup_type!)
if %~1==4 (set _outPath=!_ym!&&set _com=!_tskName!_!_ym!00_!system_name!.!backup_type!&&set _inc=!_tskName!_!_ymd!_!system_name!.!backup_type!)
if %~1==5 (set _outPath=!_ym!&&set _com=!_ym!00_!system_name!_!_tskName!.!backup_type!&&set _inc=!_ymd!_!system_name!_!_tskName!.!backup_type!)
if %~1==6 (set _outPath=!_ym!&&set _com=!_ym!00_!_tskName!_!system_name!.!backup_type!&&set _inc=!_ymd!_!_tskName!_!system_name!.!backup_type!)
if %~1==7 (set _outPath=!_ym!_!system_name!&&set _com=!system_name!_!_tskName!_!_ym!00.!backup_type!&&set _inc=!system_name!_!_tskName!_!_ymd!.!backup_type!)
if %~1==8 (set _outPath=!_ym!_!system_name!&&set _com=!system_name!_!_ym!00_!_tskName!.!backup_type!&&set _inc=!system_name!_!_ymd!_!_tskName!.!backup_type!)
if %~1==9 (set _outPath=!_ym!_!system_name!&&set _com=!_tskName!_!system_name!_!_ym!00.!backup_type!&&set _inc=!_tskName!_!system_name!_!_ymd!.!backup_type!)
if %~1==10 (set _outPath=!_ym!_!system_name!&&set _com=!_tskName!_!_ym!00_!system_name!.!backup_type!&&set _inc=!_tskName!_!_ymd!_!system_name!.!backup_type!)
if %~1==11 (set _outPath=!_ym!_!system_name!&&set _com=!_ym!00_!system_name!_!_tskName!.!backup_type!&&set _inc=!_ymd!_!system_name!_!_tskName!.!backup_type!)
if %~1==12 (set _outPath=!_ym!_!system_name!&&set _com=!_ym!00_!_tskName!_!system_name!.!backup_type!&&set _inc=!_ymd!_!_tskName!_!system_name!.!backup_type!)	
if %~1==13 (set _outPath=!system_name!_!_ym!&&set _com=!system_name!_!_tskName!_!_ym!00.!backup_type!&&set _inc=!system_name!_!_tskName!_!_ymd!.!backup_type!)
if %~1==14 (set _outPath=!system_name!_!_ym!&&set _com=!system_name!_!_ym!00_!_tskName!.!backup_type!&&set _inc=!system_name!_!_ymd!_!_tskName!.!backup_type!)
if %~1==15 (set _outPath=!system_name!_!_ym!&&set _com=!_tskName!_!system_name!_!_ym!00.!backup_type!&&set _inc=!_tskName!_!system_name!_!_ymd!.!backup_type!)
if %~1==16 (set _outPath=!system_name!_!_ym!&&set _com=!_tskName!_!_ym!00_!system_name!.!backup_type!&&set _inc=!_tskName!_!_ymd!_!system_name!.!backup_type!)
if %~1==17 (set _outPath=!system_name!_!_ym!&&set _com=!_ym!00_!system_name!_!_tskName!.!backup_type!&&set _inc=!_ymd!_!system_name!_!_tskName!.!backup_type!)
if %~1==18 (set _outPath=!system_name!_!_ym!&&set _com=!_ym!00_!_tskName!_!system_name!.!backup_type!&&set _inc=!_ymd!_!_tskName!_!system_name!.!backup_type!)	
if %~1==19 (set _outPath=!_ym!\!system_name!&&set _com=!system_name!_!_tskName!_!_ym!00.!backup_type!&&set _inc=!system_name!_!_tskName!_!_ymd!.!backup_type!)
if %~1==20 (set _outPath=!_ym!\!system_name!&&set _com=!system_name!_!_ym!00_!_tskName!.!backup_type!&&set _inc=!system_name!_!_ymd!_!_tskName!.!backup_type!)
if %~1==21 (set _outPath=!_ym!\!system_name!&&set _com=!_tskName!_!system_name!_!_ym!00.!backup_type!&&set _inc=!_tskName!_!system_name!_!_ymd!.!backup_type!)
if %~1==22 (set _outPath=!_ym!\!system_name!&&set _com=!_tskName!_!_ym!00_!system_name!.!backup_type!&&set _inc=!_tskName!_!_ymd!_!system_name!.!backup_type!)
if %~1==23 (set _outPath=!_ym!\!system_name!&&set _com=!_ym!00_!system_name!_!_tskName!.!backup_type!&&set _inc=!_ymd!_!system_name!_!_tskName!.!backup_type!)
if %~1==24 (set _outPath=!_ym!\!system_name!&&set _com=!_ym!00_!_tskName!_!system_name!.!backup_type!&&set _inc=!_ymd!_!_tskName!_!system_name!.!backup_type!)	
if %~1==25 (set _outPath=!system_name!\!_ym!&&set _com=!system_name!_!_tskName!_!_ym!00.!backup_type!&&set _inc=!system_name!_!_tskName!_!_ymd!.!backup_type!)
if %~1==26 (set _outPath=!system_name!\!_ym!&&set _com=!system_name!_!_ym!00_!_tskName!.!backup_type!&&set _inc=!system_name!_!_ymd!_!_tskName!.!backup_type!)
if %~1==27 (set _outPath=!system_name!\!_ym!&&set _com=!_tskName!_!system_name!_!_ym!00.!backup_type!&&set _inc=!_tskName!_!system_name!_!_ymd!.!backup_type!)
if %~1==28 (set _outPath=!system_name!\!_ym!&&set _com=!_tskName!_!_ym!00_!system_name!.!backup_type!&&set _inc=!_tskName!_!_ymd!_!system_name!.!backup_type!)
if %~1==29 (set _outPath=!system_name!\!_ym!&&set _com=!_ym!00_!system_name!_!_tskName!.!backup_type!&&set _inc=!_ymd!_!system_name!_!_tskName!.!backup_type!)
if %~1==30 (set _outPath=!system_name!\!_ym!&&set _com=!_ym!00_!_tskName!_!system_name!.!backup_type!&&set _inc=!_ymd!_!_tskName!_!system_name!.!backup_type!)
goto:EOF

:RUNTIME
::-----------------------------------------------------------------------------
:: Calc. runtime
:: Author: H. Scheller
:: Update: 21.11.2022
:: call :RUNTIME "<start>" output in __runtime
::-----------------------------------------------------------------------------
set __s=%~1
set __e=%time%
for /f "tokens=1-4 delims=:.," %%a in ("%__s%") do (set __shh=%%a & set /a __smm=100%%b %% 100 & set /a __sss=100%%c %% 100 & set /a __scs=100%%d %% 100)
for /f "tokens=1-4 delims=:.," %%a in ("%__e%") do (set __ehh=%%a & set /a __emm=100%%b %% 100 & set /a __ess=100%%c %% 100 & set /a __ecs=100%%d %% 100)
set /a __hh=%__ehh%-%__shh%
set /a __mm=%__emm%-%__smm%
set /a __ss=%__ess%-%__sss%
set /a __cs=%__ecs%-%__scs%
if %__cs% lss 0 set /a __ss = %__ss% - 1 & set /a __cs = 100%__cs%
if %__ss% lss 0 set /a __mm = %__mm% - 1 & set /a __ss = 60%__ss%
if %__mm% lss 0 set /a __hh = %__hh% - 1 & set /a __mm = 60%__mm%
if %__hh% lss 0 set /a __hh = 24%__hh%
if %__hh% LSS 10 set __hh=0%__hh%
if %__mm% LSS 10 set __mm=0%__mm%
if %__ss% LSS 10 set __ss=0%__ss%
if %__cs% LSS 10 set __cs=0%__cs%
set __runtime=%__hh%:%__mm%:%__ss%.%__cs%
goto:EOF

:READINI
::-----------------------------------------------------------------------------
:: Set variables & values from ini file
:: Author: H. Scheller
:: Update: 09.12.2022
:: call :READINI <inifile>
:: set Variable name to Section[Key] and check 
:: if typical boolean true/false on/off set to numeric 0/1
:: comment lines marked with ; (only possible on the beginning of a line)
::-----------------------------------------------------------------------------
for /f "tokens=1,2 delims==" %%a in (%~1) do (
	set __key=%%a
	set __key=!__key: =!
	if not "!__key:~0,1!"==";" (
		if "!__key:~0,1!"=="[" (
			if "!__key:~-1!"=="]" (
				set /a __c +=1
				set __sec=!__key:~1,-1!
				call :LCASE !__sec!
				set __sec=!__lcase!
			)
		) else (
			call :LCASE !__key!
			set __key=!__lcase!
			set __val=%%b
			if not "!__val!"=="" (
				call :LCASE !__val!
				set __lcase=!__lcase: =!
				if "!__lcase!"=="true" (set /a __val=1)
				if "!__lcase!"=="false" (set /a __val=0)
				if "!__lcase!"=="on" (set /a __val=1)
				if "!__lcase!"=="off" (set /a __val=0)
				if 1!__val! NEQ +1!__val! (
					if not "!__val!"==" =" (set !__sec!_!__key!=!__val!)
				) else (
					set /a !__sec!_!__key!=!__val!
				)
			)
		)
	)
)
goto:EOF

:LCASE
::-----------------------------------------------------------------------------
:: Set variables to lowercase
:: call :LCASE <Variable> output in variable __lcase
::-----------------------------------------------------------------------------
set __lcase=%~1
for %%a in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z" "Ä=ä" "Ö=ö" "Ü=ü") do (
    set "__lcase=!__lcase:%%~a!"
)
goto:EOF

:UCASE
::-----------------------------------------------------------------------------
:: Set variables to uppercase
:: call :UCASE <Variable> output in variable __ucase
::-----------------------------------------------------------------------------
set __ucase=%~1
for %%a in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z" "ä=Ä" "ö=Ö" "ü=Ü" "ß=SS") do (
    set "__ucase=!__ucase:%%~a!"
)
goto:EOF

:GETPATH
::-----------------------------------------------------------------------------
:: Get Path from a Path File String
:: Author: H. Scheller
:: Update: 22.11.2022
:: call :GETPATH <PathFile> output in variable __getpath
::-----------------------------------------------------------------------------
set __getpath=%~dp1
goto:EOF

:EXCLUDE2FILE
::-----------------------------------------------------------------------------
:: Replace comma with linefeed from <variable> and save it to file <file>
:: Author: H. Scheller
:: Update: 22.11.2022
:: call :EXCLUDE2FILE <variable> <file>
::-----------------------------------------------------------------------------
powershell.exe -Executionpolicy Bypass -command "&{$in='%~1';$out=$in.replace(',',[Environment]::NewLine); Set-Content -Path %~2 -Value $out;}"
goto:EOF

:EVENT
::-----------------------------------------------------------------------------
:: Write to EVENTLOG
:: Author: H. Scheller
:: Update: 08.12.2022
:: call :EVENT <id>
:: EVENT ID's
::   1-127 INFORMATION
:: 128-255 WARNING
:: 256-383 ERROR
:: 384-511 SUCCESS - NOT USED
::-----------------------------------------------------------------------------
set __evt=%~1
set __time=%time:~0,2%:%time:~3,2%:%time:~6,2%
set __time=%__time: =0%
set _evtlog=%TEMP%\%system_name%_%_ymd%_%_hms%_evt.log
if "%_dateformat:~0,1%"=="d" (set __datetime=%date:~-4%.%date:~-7,2%.%date:~-10,2% %__time%)
if "%_dateformat:~0,1%"=="M" (set __datetime=%date:~-4%.%date:~-10,2%.%date:~-7,2% %__time%)
if %__evt% gtr 0 (set __typ=INFORMATION)
if %__evt% gtr 127 (set __typ=WARNING)
if %__evt% gtr 254 (set __typ=ERROR)
if %__evt% gtr 383 (set __typ=SUCCESS)
:: INFORMATION 1-127
if %__evt%==1   (set __msg=Start %~n0 %_version% with Configuration:%_ini%.)
if %__evt%==2   (set __msg=Send email. Host:%_smtp_host%,Port: %smtp_port%,Username:%smtp_username%,Password:********,From:%smtp_sender%,Recipient:%smtp_recipient%.)
if %__evt%==3   (set __msg=System shutdown in %system_shutdowntimer% seconds.)
if %__evt%==4   (set __msg=Start Task:%_tskName%, Path:%_tskPath%, Exclude:%_tskExcl%, Type:%_tskType%, File:%_tskFile%.)
if %__evt%==5   (set __msg=End Task:%_tskName% Status:%_tskStatus% Runtime:%__runtime%.)
if %__evt%==32  (set __msg=End %~n0 Runtime: %__runtime%)
:: WARNING 128-255
if %__evt%==255 (set __msg=7-Zip [errorlevel=1] some files are locked.)
if %__evt%==128 (set __msg=Type in section [Backup] not valid. Set value to [zip].)
if %__evt%==129 (set __msg=Output in section [Backup] not valid. Set value to [1].)
if %__evt%==130 (set __msg=LogFile in section [System] not valid. Set value to [%~dp0%system_name%.log].)
if %__evt%==131 (set __msg=Shutdown in section [System] not valid. Set value to [0].)
if %__evt%==132 (set __msg=ShutdownTime in section [System] not valid. Set value to [120].)
if %__evt%==133 (set __msg=Wait in section [System] not valid. Set value to [0].)
if %__evt%==134 (set __msg=Email in section [SMTP] not valid. Set value to [0].)
if %__evt%==135 (set __msg=Host in section [SMTP] is empty. Set Email to [0].)
if %__evt%==136 (set __msg=Port in section [SMTP] is empty. Set Email to [0].)
if %__evt%==137 (set __msg=Username in section [SMTP] is empty. Set Email to [0].)
if %__evt%==138 (set __msg=Password in section [SMTP] is empty. Set Email to [0].)
if %__evt%==139 (set __msg=Sender in section [SMTP] is empty. Set Email to [0].)
if %__evt%==140 (set __msg=Recipient in section [SMTP] is empty. Set Email to [0].)
if %__evt%==141 (set __msg=Task:%_tskName%, Path:%_tskPath%, Exclude:%_tskExcl%, Type:%_tskType%, File:%_tskFile%.)
:: ERROR 256-383
if %__evt%==256 (set __msg=7-Zip [2] %_tskStatus%)
if %__evt%==257 (set __msg=7-Zip [7] %_tskStatus%)
if %__evt%==258 (set __msg=7-Zip [8] %_tskStatus%)
if %__evt%==259 (set __msg=7-Zip [255] %_tskStatus%)
if %__evt%==260 (set __msg=No configuration file was specified. Example: %~nx0 [ini file] )
if %__evt%==261 (set __msg=Configuration file: %_ini% not found.)
if %__evt%==262 (set __msg=7-Zip [%ProgramFiles%\7-Zip\7z.exe] not found.)
if %__evt%==263 (set __msg=Tasks [%backup_task%] in section [Backup] not valid.)
if %__evt%==264 (set __msg=Destination [%backup_destination%] in section [Backup] not found.)
if %__evt%==265 (set __msg=Send email error.)
eventcreate /T %__typ% /ID %__evt% /L APPLICATION /SO "%~n0 %_version%" /D "%__msg%">NUL
echo %__datetime%;%__typ%;%__evt%;"%__msg%">>%_evtlog%
if %__evt% gtr 254 (
	color 4F
	echo %~n0 %_version%
	echo --------------------------------------------------------------------------------
	echo ERROR   : %__evt%
	echo MESSAGE : %__msg%
	echo --------------------------------------------------------------------------------
	timeout /t 30
	goto :END
)
set __msg=
set __typ=
goto:EOF

:END
call :RUNTIME "%_start%"
set _prn[8]=  Runtime: %__runtime%
echo %_prn[8]%&&echo %_prn[8]%>>%_syslog%
set __time=%time:~0,2%:%time:~3,2%:%time:~6,2%
set __time=%__time: =0%
if "%_dateformat:~0,1%"=="d" (set __datetime=%date:~-4%.%date:~-7,2%.%date:~-10,2% %__time%)
if "%_dateformat:~0,1%"=="M" (set __datetime=%date:~-4%.%date:~-10,2%.%date:~-7,2% %__time%)
echo %__datetime%;%~n0 %_version%;%__runtime%;%system_name%>>%system_logfile%
if %smtp_email%==1 (
	powershell.exe -Executionpolicy Bypass -Command "Send-MailMessage -From '%smtp_sender%' -To @(%smtp_recipient%) -Subject '%system_name% %~f0' -Body (gc '%_syslog%' | out-string) -Attachments '%_evtlog%','%system_logfile%' -SmtpServer '%smtp_host%' -Credential (New-Object PSCredential('%smtp_username%',(ConvertTo-SecureString '%smtp_password%' -AsPlainText -Force))) -UseSSL -Port %smtp_port%"
	if %errorlevel% GTR 0 (call :EVENT 265) else (call :EVENT 2)
)
if %system_shutdown%==1 (
    %SystemRoot%\system32\shutdown.exe /s /t %system_shutdowntime% /c "Backup finished. The system will be shutdown in %system_shutdowntime% seconds."
	call :EVENT 3
)
call :EVENT 32
if not exist "%~dp0log" (mkdir "%~dp0log")
if exist "%_syslog%" (copy %_syslog% "%~dp0log" /y >NUL&&del %_syslog%)
if exist "%_evtlog%" (copy %_evtlog% "%~dp0log" /y >NUL&&del %_evtlog%)
if %system_wait%==1 (
	pause>nul|echo %~nx0 finished. Press any key to exit.
) else (
	timeout /t 5
)
endlocal
goto:EOF