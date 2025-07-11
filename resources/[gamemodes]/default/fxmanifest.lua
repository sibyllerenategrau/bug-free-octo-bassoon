--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Default Gamemode - FiveM Resource Manifest
    Anti-Copyright Protection
--]]

fx_version 'cerulean'
game 'gta5'

name 'HavocPvP Default Gamemode'
description 'Default gamemode with basic spawn and gameplay functionality'
author 'HavocPvP Development Team'
version '1.0.0'

-- Client Scripts
client_scripts {
    'shared/config.lua',
    'client/main.lua',
    'client/spawn.lua'
}

-- Server Scripts
server_scripts {
    'shared/config.lua',
    'server/main.lua',
    'server/player.lua'
}

-- Dependencies
dependencies {
    'spawnmanager',
    'lobby'
}

-- Lua 5.4 compatibility
lua54 'yes'