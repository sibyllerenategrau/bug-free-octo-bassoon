--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Lobby System - Server Main Script
    Anti-Copyright Protection
--]]

-- Store players currently in lobby
local playersInLobby = {}

-- Store gamemode player counts
local gamemodePlayers = {}

-- Initialize gamemode player counts
Citizen.CreateThread(function()
    for _, gamemode in ipairs(Config.Gamemodes) do
        gamemodePlayers[gamemode.id] = 0
    end
    
    if Config.Lobby.debug then
        print("[LOBBY SERVER] Initialized gamemode player counts")
    end
end)

-- Event: Player is ready in lobby
RegisterNetEvent(Config.Events.playerReady)
AddEventHandler(Config.Events.playerReady, function()
    local source = source
    local playerName = GetPlayerName(source)
    
    if Config.Lobby.debug then
        print("[LOBBY SERVER] Player ready: " .. playerName .. " (ID: " .. source .. ")")
    end
    
    -- Add player to lobby
    playersInLobby[source] = {
        name = playerName,
        joinTime = os.time(),
        selectedGamemode = nil
    }
    
    -- Wait for UI delay then show gamemode selection
    Citizen.SetTimeout(Config.Lobby.uiDelay, function()
        if playersInLobby[source] then -- Check if player is still connected
            TriggerClientEvent(Config.Events.showUI, source)
            
            if Config.Lobby.debug then
                print("[LOBBY SERVER] Showing UI to player: " .. playerName)
            end
        end
    end)
end)

-- Event: Player selected a gamemode
RegisterNetEvent(Config.Events.selectGamemode)
AddEventHandler(Config.Events.selectGamemode, function(gamemodeId)
    local source = source
    local playerName = GetPlayerName(source)
    
    if Config.Lobby.debug then
        print("[LOBBY SERVER] Player " .. playerName .. " selected gamemode: " .. tostring(gamemodeId))
    end
    
    -- Validate player is in lobby
    if not playersInLobby[source] then
        if Config.Lobby.debug then
            print("[LOBBY SERVER] Player not in lobby: " .. playerName)
        end
        return
    end
    
    -- Validate gamemode
    local selectedGamemode = nil
    for _, gamemode in ipairs(Config.Gamemodes) do
        if gamemode.id == gamemodeId then
            selectedGamemode = gamemode
            break
        end
    end
    
    if not selectedGamemode then
        if Config.Lobby.debug then
            print("[LOBBY SERVER] Invalid gamemode: " .. tostring(gamemodeId))
        end
        return
    end
    
    -- Check if gamemode is enabled
    if not selectedGamemode.enabled then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[LOBBY]", "This gamemode is currently disabled."}
        })
        return
    end
    
    -- Check player count limits
    local currentPlayers = gamemodePlayers[gamemodeId] or 0
    if currentPlayers >= selectedGamemode.maxPlayers then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 165, 0},
            multiline = true,
            args = {"[LOBBY]", "This gamemode is currently full. Please try another one."}
        })
        return
    end
    
    -- Update player data
    playersInLobby[source].selectedGamemode = gamemodeId
    
    -- Increment gamemode player count
    gamemodePlayers[gamemodeId] = currentPlayers + 1
    
    -- Notify client that gamemode was selected successfully
    TriggerClientEvent(Config.Events.gamemodeSelected, source, gamemodeId)
    
    -- Remove player from lobby after a short delay
    Citizen.SetTimeout(1000, function()
        RemovePlayerFromLobby(source, gamemodeId)
    end)
    
    if Config.Lobby.debug then
        print("[LOBBY SERVER] Player " .. playerName .. " joining gamemode: " .. gamemodeId)
    end
end)

-- Remove player from lobby system
function RemovePlayerFromLobby(playerId, gamemodeId)
    if playersInLobby[playerId] then
        playersInLobby[playerId] = nil
        
        if Config.Lobby.debug then
            print("[LOBBY SERVER] Removed player from lobby: " .. GetPlayerName(playerId))
        end
    end
end

-- Handle player disconnection
AddEventHandler('playerDropped', function(reason)
    local source = source
    local playerName = GetPlayerName(source)
    
    if playersInLobby[source] then
        local gamemode = playersInLobby[source].selectedGamemode
        
        -- Decrease gamemode player count if player was in a gamemode
        if gamemode and gamemodePlayers[gamemode] then
            gamemodePlayers[gamemode] = math.max(0, gamemodePlayers[gamemode] - 1)
        end
        
        -- Remove from lobby
        playersInLobby[source] = nil
        
        if Config.Lobby.debug then
            print("[LOBBY SERVER] Player disconnected from lobby: " .. playerName .. " (Reason: " .. reason .. ")")
        end
    end
end)

-- Admin command to check lobby status
RegisterCommand('lobbystatus', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("=== LOBBY STATUS ===")
        print("Players in lobby: " .. GetTableLength(playersInLobby))
        
        for playerId, playerData in pairs(playersInLobby) do
            print("  - " .. playerData.name .. " (ID: " .. playerId .. ") - Selected: " .. tostring(playerData.selectedGamemode))
        end
        
        print("\nGamemode player counts:")
        for gamemodeId, count in pairs(gamemodePlayers) do
            print("  - " .. gamemodeId .. ": " .. count .. " players")
        end
    end
end, true)

-- Utility function to get table length
function GetTableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Export functions for other resources
exports('GetPlayersInLobby', function()
    return playersInLobby
end)

exports('GetGamemodePlayers', function()
    return gamemodePlayers
end)

exports('RemovePlayerFromLobby', RemovePlayerFromLobby)