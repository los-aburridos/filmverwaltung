@echo off
call ve\scripts\activate.bat

:: Coffee
start ve\node.exe ve\node_modules\coffcript\bin\coffee -c -o static\js -w static\js\coffee\

:: Server
ve\scripts\python runserver.py

pause