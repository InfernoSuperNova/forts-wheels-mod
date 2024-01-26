@echo off
setlocal enabledelayedexpansion

rem Get the current script's parent folder
set "ScriptPath=%~dp0"
set "ParentFolder=%ScriptPath:~0,-1%"

rem Set the target directory
set "TargetDirectory=C:\Program Files (x86)\Steam\steamapps\common\Forts\data\mods"

rem Set the desired name for the new folder
set "CustomFolderName=landcruisersMain"

rem Create the new folder in the specified target directory
set "NewFolder=%TargetDirectory%\%CustomFolderName%"
mkdir "%NewFolder%"

rem Copy all files and subfolders from the parent folder to the new folder
xcopy "%ParentFolder%\*" "%NewFolder%\" /E /C /I /Q /H /R /Y

rem Exclude the new folder itself from the copy
del /Q "%NewFolder%\%~NX0"

echo Duplicate folder created at: %NewFolder%

rem Run LuaPlusC compiler on specific Lua scripts within the duplicated folder

set "stringfuscatorPath=C:\Program Files (x86)\Steam\steamapps\common\Forts\modDevFolder\stringfuscator.py"
set "LuaPlusCPath=C:\Program Files (x86)\Steam\steamapps\common\Forts\LuaPlusC.exe"

python "%stringfuscatorPath%" "%NewFolder%\scripts\game\premiumWheels.lua" "%NewFolder%\scripts\game\premiumWheels.lua"
"%LuaPlusCPath%" -o "%NewFolder%\scripts\game\premiumWheels.lua" "%NewFolder%\scripts\game\premiumWheels.lua"

python "%stringfuscatorPath%" "%NewFolder%\config\premiumIds.lua" "%NewFolder%\config\premiumIds.lua"
"%LuaPlusCPath%" -o "%NewFolder%\config\premiumIds.lua" "%NewFolder%\config\premiumIds.lua"

echo Compilation complete.
pause