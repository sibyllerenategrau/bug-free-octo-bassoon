--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Lobby System - Client Main Script
    Anti-Copyright Protection
--]]

local playerInLobby = false
local lobbyCamera = nil
local playerPed = nil

-- Initialize the lobby system when player spawns
AddEventHandler('playerSpawned', function()
    if Config.Lobby.debug then
        print("[LOBBY] Player spawned, initializing lobby system...")
    end
    
    -- Wait a moment for player to fully load
    Citizen.Wait(1000)
    
    -- Initialize lobby for new player
    InitializeLobby()
end)

-- Initialize lobby system
function InitializeLobby()
    if playerInLobby then
        return -- Already in lobby
    end
    
    playerInLobby = true
    playerPed = PlayerPedId()
    
    -- Freeze player immediately to prevent movement
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false, false)
    SetEntityInvincible(playerPed, true)
    
    -- Disable player controls
    DisableAllControlActions()
    
    -- Set player to lobby location (high in the sky)
    SetEntityCoords(playerPed, Config.Lobby.spawnCoords.x, Config.Lobby.spawnCoords.y, Config.Lobby.spawnCoords.z, false, false, false, true)
    SetEntityHeading(playerPed, Config.Lobby.spawnCoords.w)
    
    -- Setup lobby camera
    SetupLobbyCamera()
    
    -- Notify server that player is ready
    TriggerServerEvent(Config.Events.playerReady)
    
    if Config.Lobby.debug then
        print("[LOBBY] Player initialized in lobby system")
    end
end

-- Setup camera for lobby view
function SetupLobbyCamera()
    -- Destroy existing camera if any
    if lobbyCamera then
        DestroyCam(lobbyCamera, false)
    end
    
    -- Create new camera
    lobbyCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    -- Set camera position and rotation
    SetCamCoord(lobbyCamera, Config.Lobby.cameraCoords.x, Config.Lobby.cameraCoords.y, Config.Lobby.cameraCoords.z)
    SetCamRot(lobbyCamera, -90.0, 0.0, 0.0, 2)
    SetCamFov(lobbyCamera, 50.0)
    
    -- Activate camera
    SetCamActive(lobbyCamera, true)
    RenderScriptCams(true, true, 1000, true, true)
    
    if Config.Lobby.debug then
        print("[LOBBY] Lobby camera setup complete")
    end
end

-- Disable all player controls during lobby
function DisableAllControlActions()
    Citizen.CreateThread(function()
        while playerInLobby do
            -- Disable all control groups
            for i = 0, 2 do
                DisableAllControlActions(i)
            end
            
            -- Specifically disable some important controls
            DisableControlAction(0, 1, true) -- Camera X
            DisableControlAction(0, 2, true) -- Camera Y
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
            
            Citizen.Wait(0)
        end
    end)
end

-- Event: Show gamemode selection UI
RegisterNetEvent(Config.Events.showUI)
AddEventHandler(Config.Events.showUI, function()
    if Config.Lobby.debug then
        print("[LOBBY] Showing gamemode selection UI")
    end
    
    -- Show UI
    ShowGamemodeSelectionUI()
end)

-- Event: Hide UI and join selected gamemode
RegisterNetEvent(Config.Events.gamemodeSelected)
AddEventHandler(Config.Events.gamemodeSelected, function(gamemodeId)
    if Config.Lobby.debug then
        print("[LOBBY] Gamemode selected: " .. tostring(gamemodeId))
    end
    
    -- Hide UI
    HideGamemodeSelectionUI()
    
    -- Leave lobby and join gamemode
    LeaveLobby(gamemodeId)
end)

-- Leave lobby system and join gamemode
function LeaveLobby(gamemodeId)
    if not playerInLobby then
        return
    end
    
    playerInLobby = false
    
    -- Destroy lobby camera
    if lobbyCamera then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(lobbyCamera, false)
        lobbyCamera = nil
    end
    
    -- Re-enable player
    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true, false)
    SetEntityInvincible(playerPed, false)
    
    -- Trigger gamemode join event
    TriggerEvent(Config.Events.joinGamemode, gamemodeId)
    
    if Config.Lobby.debug then
        print("[LOBBY] Player left lobby, joining gamemode: " .. tostring(gamemodeId))
    end
end

-- Handle resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Clean up camera
        if lobbyCamera then
            RenderScriptCams(false, false, 0, false, false)
            DestroyCam(lobbyCamera, false)
        end
        
        -- Re-enable player if still in lobby
        if playerInLobby and playerPed then
            FreezeEntityPosition(playerPed, false)
            SetEntityVisible(playerPed, true, false)
            SetEntityInvincible(playerPed, false)
        end
    end
end)