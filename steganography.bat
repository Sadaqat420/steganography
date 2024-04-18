@echo off
setlocal EnableDelayedExpansion

rem Set file names
set /p image="Enter image file name (with extension): "
set /p text="Enter text file name (with extension): "

rem Convert text file to binary
set "binary="
for /F "usebackq tokens=1 delims=" %%a in ("%text%") do (
    set "line=%%a"
    for %%b in ("!line!") do (
        for /L %%i in (0,1,7) do (
            set /A "byte=1<<%%i,mask=byte&%%~tb"
            if !mask! neq 0 (
                set "binary=!binary!1"
            ) else (
                set "binary=!binary!0"
            )
        )
    )
)

rem Embed binary data into image
set /A index=0
for /F "usebackq tokens=1* delims=:" %%a in (`findstr /o "^" "%image%"`) do (
    set "char=%%b"
    set /A "byte=1<<7-index%%8,mask=byte&!char:~0,1!"
    if !index! lss 8 (
        if !mask! neq 0 (
            set "char=!char:~0,1!!binary:~0,1!!char:~2!"
        ) else (
            set "char=!char:~0,1!!char:~2!"
        )
        set /A "index+=1"
        set "binary=!binary:~1!"
    )
    set "encoded=!encoded!!char!"
)

rem Save encoded image
setlocal DisableDelayedExpansion
> "%image%.encoded" (
    echo !encoded!
)

echo Text file hidden inside image.
pause
