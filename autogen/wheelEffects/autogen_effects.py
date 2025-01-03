import os
import shutil
import copy
import ast

def get_folders_in_directory(directory):
    """Returns a list of folder names in the given directory."""
    folders = []
    for entry in os.scandir(directory):
        if entry.is_dir():
            folders.append(entry.name)
    return folders

def get_files_in_directory(directory):
    """Returns a list of file names in the given directory."""
    files = []
    for entry in os.scandir(directory):
        if entry.is_file():
            files.append(entry.name)
    return files

def ensure_directories_exist(*directories):
    """Ensures that the given directories exist, printing a message if they do not."""
    for directory in directories:
        if not os.path.exists(directory):
            print(f"Directory does not exist: {directory}")





def main():
    # Get the directory containing this script
    scriptPath = os.path.dirname(os.path.abspath(__file__))

    # Define directories
    effectsDirectory = os.path.abspath(os.path.join(scriptPath, "../../effects"))
    mediaDirectory = os.path.join(effectsDirectory, "wheels")
    templatesDirectory = os.path.abspath(os.path.join(scriptPath, "templates"))
    wheelDefinitionsPath = os.path.join(scriptPath, "../../scripts/game/WheelTypeDefinitions.lua")

    # Ensure directories exist
    ensure_directories_exist(effectsDirectory, mediaDirectory, templatesDirectory)

    # Get templates and folders
    wheelTypes = get_folders_in_directory(mediaDirectory)

    # Print the directory being checked
    print("Checking directory:", mediaDirectory)

    # Print the list of folders found and copy templates
    if not wheelTypes:
        print("No folders found.")
    else:
        copy_and_replace_templates(wheelTypes, mediaDirectory, templatesDirectory, effectsDirectory, wheelDefinitionsPath)




def copy_and_replace_templates(wheelTypes, mediaDirectory, templatesDirectory, outputDirectory, wheelDefinitionsPath):
    """Copies templates to the output directory, replacing [placeholder] with folder names."""
    os.makedirs(outputDirectory, exist_ok=True)

    wheelTemplates = wheel_type_definitions
    

    for wheelType in wheelTypes:

        # Check if the folder contains a wheel, sprocket, track, or track link

        wheelTemplate = copy.deepcopy(wheel_template_default)

        for entry in os.scandir(os.path.join(mediaDirectory, wheelType)):
            if entry.is_file():
                if "wheel" in entry.name:
                    write_template_to_output(templatesDirectory, outputDirectory, wheelType, "wheel_[placeholder].lua")
                    write_template_to_output(templatesDirectory, outputDirectory, wheelType, "wheel_[placeholder]_large.lua")
                    write_template_to_output(templatesDirectory, outputDirectory, wheelType, "wheel_[placeholder]_extraLarge.lua")
                    wheelTemplate["wheel"]["small"] = f"/effects/wheel_{wheelType}.lua"
                    wheelTemplate["wheel"]["medium"] = f"/effects/wheel_{wheelType}.lua"
                    wheelTemplate["wheel"]["large"] = f"/effects/wheel_{wheelType}_large.lua"
                    wheelTemplate["wheel"]["extraLarge"] = f"/effects/wheel_{wheelType}_extraLarge.lua"

                if "sprocket" in entry.name:
                    write_template_to_output(templatesDirectory, outputDirectory, wheelType, "track_sprocket_[placeholder].lua")
                    write_template_to_output(templatesDirectory, outputDirectory, wheelType, "track_sprocket_[placeholder]_large.lua")
                    write_template_to_output(templatesDirectory, outputDirectory, wheelType, "track_sprocket_[placeholder]_extraLarge.lua")
                    wheelTemplate["sprocket"]["small"] = f"/effects/track_sprocket_{wheelType}.lua"
                    wheelTemplate["sprocket"]["medium"] = f"/effects/track_sprocket_{wheelType}.lua"
                    wheelTemplate["sprocket"]["large"] = f"/effects/track_sprocket_{wheelType}_large.lua"
                    wheelTemplate["sprocket"]["extraLarge"] = f"/effects/track_sprocket_{wheelType}_extraLarge.lua"

                if "track" in entry.name:
                    write_template_to_output(templatesDirectory, outputDirectory, wheelType, "track_[placeholder].lua")
                    wheelTemplate["track"] = f"/effects/track_{wheelType}.lua"
                if "tracklink" in entry.name:
                    write_template_to_output(templatesDirectory, outputDirectory, wheelType, "track_link_[placeholder].lua")
                    wheelTemplate["trackLink"] = f"/effects/track_link_{wheelType}.lua"
        
        wheelTemplates[wheelType] = wheelTemplate
    lua_tbl = convert_dict_into_lua_table(wheelTemplates, 1)

    output = wheel_type_definitions_start_boilerplate + lua_tbl + wheel_type_definitions_end_boilerplate
    # Write the wheel type definitions to the output file
    with open(wheelDefinitionsPath, 'w') as file:
        file.write(output)

def write_template_to_output(templatesDirectory, outputDirectory, folder, template):
    templatePath = os.path.join(templatesDirectory, template)
    outputTemplateName = template.replace("[placeholder]", folder)
    outputPath = os.path.join(outputDirectory, outputTemplateName)
    print("Copying template", template, "to", outputPath)
    try:
        with open(templatePath, 'r') as file:
            content = file.read()
        content = content.replace("[placeholder]", folder)
        with open(outputPath, 'w') as file:
            file.write(content)
    except Exception as e:
        print(f"Failed to copy {templatePath} to {outputPath}: {e}")



wheel_type_definitions_start_boilerplate = ''' -- This file is automatically generated by autogen_effects.py
function LoadWheelTypeDefinitions()
    WheelTable = 
'''
wheel_type_definitions_end_boilerplate = ''' 
end
'''


wheel_template_default = {
    "sprocket": {
        "small": "/effects/track_sprocket.lua",
        "medium": "/effects/track_sprocket.lua",
        "large": "/effects/track_sprocket_large.lua",
        "extraLarge": "/effects/track_sprocket_extraLarge.lua",
    },
    "wheel": {
        "small": "/effects/wheel.lua",
        "medium": "/effects/wheel.lua",
        "large": "/effects/wheel_large.lua",
        "extraLarge": "/effects/wheel_extraLarge.lua",
    },
    "track": "/effects/track.lua",
    "trackLink": "/effects/track_link.lua",
}

wheel_type_definitions = {
    1: {
        "sprocket": {
            "small": "/effects/track_sprocket_blue.lua",
            "medium": "/effects/track_sprocket_blue.lua",
            "large": "/effects/track_sprocket_blue_large.lua",
            "extraLarge": "/effects/track_sprocket_blue_extraLarge.lua",
        },
        "wheel": {
            "small": "/effects/wheel_blue.lua",
            "medium": "/effects/wheel_blue.lua",
            "large": "/effects/wheel_blue_large.lua",
            "extraLarge": "/effects/wheel_blue_extraLarge.lua",
        },
        "track": "/effects/track.lua",
        "trackLink": "/effects/track_link.lua",
    },
    2: {
        "sprocket": {
            "small": "/effects/track_sprocket_red.lua",
            "medium": "/effects/track_sprocket_red.lua",
            "large": "/effects/track_sprocket_red_large.lua",
            "extraLarge": "/effects/track_sprocket_red_extraLarge.lua",
        },
        "wheel": {
            "small": "/effects/wheel_red.lua",
            "medium": "/effects/wheel_red.lua",
            "large": "/effects/wheel_red_large.lua",
            "extraLarge": "/effects/wheel_red_extraLarge.lua",
        },
        "track": "/effects/track.lua",
        "trackLink": "/effects/track_link.lua",
    },
    "Default": {
        "sprocket": {
            "small": "/effects/track_sprocket.lua",
            "medium": "/effects/track_sprocket.lua",
            "large": "/effects/track_sprocket_large.lua",
            "extraLarge": "/effects/track_sprocket_extraLarge.lua",
        },
        "wheel": {
            "small": "/effects/wheel.lua",
            "medium": "/effects/wheel.lua",
            "large": "/effects/wheel_large.lua",
            "extraLarge": "/effects/wheel_extraLarge.lua",
        },
        "track": "/effects/track.lua",
        "trackLink": "/effects/track_link.lua",
    }
}



def convert_dict_into_lua_table(dictionary, indent=0):
    """Converts a dictionary into a string representing a Lua table."""
    result = "{\n"
    for key, value in dictionary.items():
        if isinstance(key, int):
            result += "    " * (indent + 1) + f"[{key}] = "
        else:
            result += "    " * (indent + 1) + f"[\"{key}\"] = "
        if isinstance(value, dict):
            result += convert_dict_into_lua_table(value, indent + 1)
        elif isinstance(value, str):
            result += f"\"{value}\""
        result += ",\n"
    result += "    " * indent + "}"
    return result

if __name__ == "__main__":
    main()

