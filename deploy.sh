#!/bin/bash

# Get the current script's parent folder
ScriptPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ParentFolder="$ScriptPath"

# Set the target directory
TargetDirectory="/home/deltawing/.steam/debian-installation/steamapps/common/Forts/data/mods"

# Set the desired name for the new folder
CustomFolderName="landcruisersMain"

# Create the new folder in the specified target directory
NewFolder="$TargetDirectory/$CustomFolderName"
mkdir -p "$NewFolder"

# copy the itemversion.lua file from the deploy location to the project location
cp "$NewFolder/itemversion.lua" "$ParentFolder/itemversion.lua"

# clear the entire new folder
rm -rf "$NewFolder"

# Use rsync for faster and more efficient copying
rsync -a --exclude="$NewFolder" --exclude="$ParentFolder" "$ParentFolder/" "$NewFolder"

echo "Duplicate folder created at: $NewFolder"

# Run LuaPlusC compiler on specific Lua scripts within the duplicated folder

stringfuscatorPath="/home/deltawing/.steam/debian-installation/steamapps/common/Forts/modDevFolder/stringfuscator.py"
LuaPlusCPath="/home/deltawing/.steam/debian-installation/steamapps/common/Forts/LuaPlusC.exe"

python3 "$stringfuscatorPath" "$NewFolder/scripts/game/premiumWheels.lua" "$NewFolder/scripts/game/premiumWheels.lua"
DISPLAY= wine "$LuaPlusCPath" -o "$NewFolder/scripts/game/premiumWheels.lua" "$NewFolder/scripts/game/premiumWheels.lua"

python3 "$stringfuscatorPath" "$NewFolder/config/premiumIds.lua" "$NewFolder/config/premiumIds.lua"
DISPLAY= wine "$LuaPlusCPath" -o "$NewFolder/config/premiumIds.lua" "$NewFolder/config/premiumIds.lua"

# Remove this deploy.sh script from the new folder
rm "$NewFolder/deploy.sh"
rm "$NewFolder/copy.bat"
rm "$NewFolder/upload.py"

# Finally, run generation files

python3 "$NewFolder/autogen/wheelEffects/autogen_effects.py"

echo "Compilation complete."
