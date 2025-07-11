--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Lobby System - FiveM Resource Manifest
    Anti-Copyright Protection
--]]

fx_version 'cerulean'
game 'gta5'

name 'HavocPvP Lobby System'
description 'Lobby system for multi-gamemode server with gamemode selection UI'
author 'HavocPvP Development Team'
version '1.0.0'

-- Client Scripts
client_scripts {
    'shared/config.lua',
    'client/main.lua',
    'client/ui.lua'
}

-- Server Scripts
server_scripts {
    'shared/config.lua',
    'server/main.lua'
}

-- UI Files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

-- Dependencies
dependencies {
    'spawnmanager'
}

-- Lua 5.4 compatibility
lua54 'yes'