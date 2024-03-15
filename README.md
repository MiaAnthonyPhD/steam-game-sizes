## Features

Provides install/download sizes for games owned by a given steam user. It is basic (I made it for myself), but anyone can use it if they wish as I couldn't find anything easier online.

## Usage

In order to run this project you will need lua, and [luasocket](https://lunarmodules.github.io/luasocket/). It also depends on the [Steam Web API](https://steamcommunity.com/dev) and the [SteamCMD API](https://www.steamcmd.net/). It will not work if either are offline.

### Step 1
Edit the config file and provide a Steam Web API key and the steamID number of the user whose games you wish to search in JSON format. For info on obtaining an API key see [here](https://steamcommunity.com/dev).

### Step 2
Run the included lua file:
```
lua run.lua
```
You should expect for this process to take 3-5 seconds per game. If `steam_data.json` is already present then it will only run for each additional game.

### Step 3
You should have a file named `data.csv` that can be opened in any spreadsheet software. The format is: 
```
APP ID, Game Title, Install Size, Download Size, Install Size Excluding DLC, Download Size Excluding DLC
```
All sizes are given in MB and are exclusively for the English and Windows version(s) of each game.

Note: some titles will be inaccurate due to abnormal tagging.

## License

This library is free software; you can redistribute it and/or modify it under the terms of the MIT license.
