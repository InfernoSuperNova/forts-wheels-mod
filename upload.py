import os
from steam.client import SteamClient
from steam.enums import EResult
from steam.webapi import WebAPI

# Initialize Steam Web API
api_key = "your_steam_api_key"
api = WebAPI(key=api_key)

# Define the workshop item details
item = {
    "title": "My Mod",
    "description": "This is a description of my mod.",
    "content_folder": "/path/to/your/mod/content",
    "preview_image": "/path/to/your/preview/image.png",
    "tags": ["Tag1", "Tag2"]
}

def upload_workshop_item(item):
    # Create a new workshop item
    response = api.ISteamRemoteStorage.CreatePublishedFile(
        appid=your_app_id,
        title=item["title"],
        description=item["description"],
        contentfolder=item["content_folder"],
        previewfile=item["preview_image"],
        tags=item["tags"]
    )

    if response["result"] == EResult.OK:
        print("Workshop item uploaded successfully!")
    else:
        print(f"Failed to upload workshop item: {response['result']}")

upload_workshop_item(item)