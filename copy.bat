@echo off
setlocal enabledelayedexpansion

rem Get the current script's parent folder
set "ScriptPath=%~dp0"
set "ParentFolder=%ScriptPath:~0,-1%"

rem Set the target directory
set "TargetDirectory=G:\SteamLibrary\steamapps\common\Forts\data\mods"

rem Set the desired name for the new folder
set "CustomFolderName=landcruisersMain"

rem Create the new folder in the specified target directory
set "NewFolder=%TargetDirectory%\%CustomFolderName%"
mkdir "%NewFolder%"

rem Use robocopy for faster and more efficient copying
robocopy "%ParentFolder%" "%NewFolder%" /E /NP /NFL /NDL /NJH /NJS /NC /NS /XD "%NewFolder%" /XD "%ParentFolder%"

echo Duplicate folder created at: %NewFolder%

rem Run LuaPlusC compiler on specific Lua scripts within the duplicated folder

set "stringfuscatorPath=G:\SteamLibrary\steamapps\common\Forts\modDevFolder\stringfuscator.py"
set "LuaPlusCPath=G:\SteamLibrary\steamapps\common\Forts\LuaPlusC.exe"

python "%stringfuscatorPath%" "%NewFolder%\scripts\game\premiumWheels.lua" "%NewFolder%\scripts\game\premiumWheels.lua"
"%LuaPlusCPath%" -o "%NewFolder%\scripts\game\premiumWheels.lua" "%NewFolder%\scripts\game\premiumWheels.lua"

python "%stringfuscatorPath%" "%NewFolder%\config\premiumIds.lua" "%NewFolder%\config\premiumIds.lua"
"%LuaPlusCPath%" -o "%NewFolder%\config\premiumIds.lua" "%NewFolder%\config\premiumIds.lua"

echo Compilation complete.
pause