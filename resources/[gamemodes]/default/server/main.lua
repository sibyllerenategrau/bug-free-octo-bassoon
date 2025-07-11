--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Default Gamemode - Server Main Script
    Anti-Copyright Protection
--]]

-- Store players in this gamemode
local gamemodePlayers = {}

-- Initialize resource
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("[DEFAULT GAMEMODE SERVER] Resource started")
        
        -- Initialize any server-side systems here
        InitializeGamemode()
    end
end)

-- Initialize gamemode
function InitializeGamemode()
    print("[DEFAULT GAMEMODE SERVER] Initializing default gamemode...")
    
    -- Set up any server-side features
    SetupCommands()
    
    print("[DEFAULT GAMEMODE SERVER] Default gamemode initialized successfully")
end

-- Event: Player joined gamemode
RegisterNetEvent(DefaultGamemode.Events.playerJoined)
AddEventHandler(DefaultGamemode.Events.playerJoined, function()
    local source = source
    local playerName = GetPlayerName(source)
    
    print("[DEFAULT GAMEMODE SERVER] Player joined: " .. playerName .. " (ID: " .. source .. ")")
    
    -- Initialize player data
    InitializePlayer(source)
end)

-- Event: Player left gamemode
RegisterNetEvent(DefaultGamemode.Events.playerLeft)
AddEventHandler(DefaultGamemode.Events.playerLeft, function()
    local source = source
    local playerName = GetPlayerName(source)
    
    print("[DEFAULT GAMEMODE SERVER] Player left: " .. playerName .. " (ID: " .. source .. ")")
    
    -- Clean up player data
    CleanupPlayer(source)
end)

-- Initialize player in gamemode
function InitializePlayer(playerId)
    -- Create player data
    gamemodePlayers[playerId] = {
        name = GetPlayerName(playerId),
        money = DefaultGamemode.Player.startingMoney,
        joinTime = os.time(),
        deaths = 0,
        kills = 0
    }
    
    -- Send player data to client
    TriggerClientEvent(DefaultGamemode.Events.playerData, playerId, gamemodePlayers[playerId])
    
    -- Welcome message
    TriggerClientEvent('chat:addMessage', playerId, {
        color = {0, 255, 100},
        multiline = true,
        args = {"[DEFAULT GAMEMODE]", "Welcome " .. GetPlayerName(playerId) .. "! You have $" .. DefaultGamemode.Player.startingMoney .. " to start with."}
    })
end

-- Clean up player data
function CleanupPlayer(playerId)
    if gamemodePlayers[playerId] then
        gamemodePlayers[playerId] = nil
    end
end

-- Event: Player requests spawn
RegisterNetEvent(DefaultGamemode.Events.requestSpawn)
AddEventHandler(DefaultGamemode.Events.requestSpawn, function()
    local source = source
    
    if not gamemodePlayers[source] then
        print("[DEFAULT GAMEMODE SERVER] Spawn request from non-gamemode player: " .. GetPlayerName(source))
        return
    end
    
    SpawnPlayer(source)
end)

-- Spawn player at random location
function SpawnPlayer(playerId)
    local spawnLocation = DefaultGamemode.Spawn.locations[DefaultGamemode.Spawn.defaultLocation]
    
    -- Select random location if multiple available
    if #DefaultGamemode.Spawn.locations > 1 then
        spawnLocation = DefaultGamemode.Spawn.locations[math.random(1, #DefaultGamemode.Spawn.locations)]
    end
    
    -- Choose random player model
    local model = DefaultGamemode.Player.availableModels[math.random(1, #DefaultGamemode.Player.availableModels)]
    
    local spawnData = {
        coords = spawnLocation.coords,
        model = model,
        locationName = spawnLocation.name
    }
    
    -- Trigger client spawn
    TriggerClientEvent(DefaultGamemode.Events.spawnPlayer, playerId, spawnData)
    
    print("[DEFAULT GAMEMODE SERVER] Spawning player " .. GetPlayerName(playerId) .. " at " .. spawnLocation.name)
end

-- Event: Player requests vehicle
RegisterNetEvent(DefaultGamemode.Events.requestVehicle)
AddEventHandler(DefaultGamemode.Events.requestVehicle, function(vehicleName)
    local source = source
    
    if not gamemodePlayers[source] then
        return
    end
    
    SpawnVehicleForPlayer(source, vehicleName)
end)

-- Spawn vehicle for player
function SpawnVehicleForPlayer(playerId, vehicleName)
    local playerData = gamemodePlayers[playerId]
    if not playerData then
        return
    end
    
    -- Find vehicle in available list
    local vehicleData = nil
    for _, vehicle in ipairs(DefaultGamemode.Vehicles.availableVehicles) do
        if string.lower(vehicle.model) == string.lower(vehicleName) or string.lower(vehicle.name) == string.lower(vehicleName) then
            vehicleData = vehicle
            break
        end
    end
    
    if not vehicleData then
        TriggerClientEvent('chat:addMessage', playerId, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[VEHICLE]", "Vehicle '" .. vehicleName .. "' not found!"}
        })
        return
    end
    
    -- Check if player has enough money
    if playerData.money < vehicleData.price then
        TriggerClientEvent('chat:addMessage', playerId, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[VEHICLE]", "You need $" .. vehicleData.price .. " to spawn this vehicle!"}
        })
        return
    end
    
    -- Deduct money
    playerData.money = playerData.money - vehicleData.price
    
    -- Update client with new money amount
    TriggerClientEvent(DefaultGamemode.Events.playerData, playerId, playerData)
    
    -- Spawn vehicle on client
    TriggerClientEvent(DefaultGamemode.Events.spawnVehicle, playerId, vehicleData)
    
    print("[DEFAULT GAMEMODE SERVER] Spawning vehicle " .. vehicleData.name .. " for " .. GetPlayerName(playerId))
end

-- Set up server commands
function SetupCommands()
    -- Admin commands
    RegisterCommand('defaultstatus', function(source, args, rawCommand)
        if source == 0 then -- Console only
            print("=== DEFAULT GAMEMODE STATUS ===")
            print("Players in gamemode: " .. GetTableLength(gamemodePlayers))
            
            for playerId, playerData in pairs(gamemodePlayers) do
                print("  - " .. playerData.name .. " (ID: " .. playerId .. ") - Money: $" .. playerData.money)
            end
        end
    end, true)
    
    -- Player commands
    RegisterCommand('money', function(source, args, rawCommand)
        if gamemodePlayers[source] then
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 100},
                multiline = true,
                args = {"[MONEY]", "You have $" .. gamemodePlayers[source].money}
            })
        end
    end, false)
    
    RegisterCommand('vehicles', function(source, args, rawCommand)
        if gamemodePlayers[source] then
            local message = "Available vehicles: "
            for i, vehicle in ipairs(DefaultGamemode.Vehicles.availableVehicles) do
                message = message .. vehicle.name .. " ($" .. vehicle.price .. ")"
                if i < #DefaultGamemode.Vehicles.availableVehicles then
                    message = message .. ", "
                end
            end
            
            TriggerClientEvent('chat:addMessage', source, {
                color = {100, 150, 255},
                multiline = true,
                args = {"[VEHICLES]", message}
            })
        end
    end, false)
end

-- Handle player disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    if gamemodePlayers[source] then
        print("[DEFAULT GAMEMODE SERVER] Player " .. GetPlayerName(source) .. " disconnected from gamemode")
        CleanupPlayer(source)
    end
end)

-- Utility function to get table length
function GetTableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Export functions for other resources
exports('GetGamemodePlayers', function()
    return gamemodePlayers
end)

exports('GetPlayerData', function(playerId)
    return gamemodePlayers[playerId]
end)

exports('AddMoney', function(playerId, amount)
    if gamemodePlayers[playerId] then
        gamemodePlayers[playerId].money = gamemodePlayers[playerId].money + amount
        TriggerClientEvent(DefaultGamemode.Events.playerData, playerId, gamemodePlayers[playerId])
        return true
    end
    return false
end)

exports('RemoveMoney', function(playerId, amount)
    if gamemodePlayers[playerId] and gamemodePlayers[playerId].money >= amount then
        gamemodePlayers[playerId].money = gamemodePlayers[playerId].money - amount
        TriggerClientEvent(DefaultGamemode.Events.playerData, playerId, gamemodePlayers[playerId])
        return true
    end
    return false
end)