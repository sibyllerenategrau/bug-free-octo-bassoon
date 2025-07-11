--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Lobby System - Shared Configuration
    Anti-Copyright Protection
--]]

Config = {}

-- Lobby Configuration
Config.Lobby = {
    -- Spawn coordinates for lobby (in the sky to prevent character loading)
    spawnCoords = vector4(0.0, 0.0, 1000.0, 0.0),
    
    -- Camera position for lobby view
    cameraCoords = vector3(0.0, 0.0, 1005.0),
    
    -- Time before showing gamemode selection UI (milliseconds)
    uiDelay = 500, -- Reduced from 2000 to 500ms for faster response
    
    -- Enable debug mode
    debug = true
}

-- Available Gamemodes
Config.Gamemodes = {
    {
        id = "default",
        name = "Default Gamemode",
        description = "Basic gamemode for testing purposes",
        icon = "🎮",
        maxPlayers = 32,
        enabled = true
    },
    {
        id = "roleplay",
        name = "Roleplay",
        description = "Immersive roleplay experience",
        icon = "🎭",
        maxPlayers = 64,
        enabled = true -- Enabled for testing
    },
    {
        id = "pvp",
        name = "PvP Arena",
        description = "Competitive player vs player combat",
        icon = "⚔️",
        maxPlayers = 16,
        enabled = true -- Enabled for testing
    }
}

-- Events
Config.Events = {
    -- Client to Server
    selectGamemode = "lobby:selectGamemode",
    playerReady = "lobby:playerReady",
    
    -- Server to Client
    gamemodeSelected = "lobby:gamemodeSelected",
    showUI = "lobby:showUI",
    hideUI = "lobby:hideUI",
    
    -- Gamemode Events
    joinGamemode = "gamemode:join",
    leaveGamemode = "gamemode:leave"
}