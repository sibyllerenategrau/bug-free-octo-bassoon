--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Default Gamemode - Spawn Management
    Anti-Copyright Protection
--]]

-- Spawn player at specified location
function SpawnPlayerAtLocation(spawnData)
    local playerPed = PlayerPedId()
    local coords = spawnData.coords
    
    -- Set player model if specified
    if spawnData.model then
        RequestModel(spawnData.model)
        while not HasModelLoaded(spawnData.model) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), spawnData.model)
        SetModelAsNoLongerNeeded(spawnData.model)
    end
    
    -- Update ped reference after potential model change
    playerPed = PlayerPedId()
    
    -- Set position and heading
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(playerPed, coords.w)
    
    -- Set health and armor
    SetEntityHealth(playerPed, DefaultGamemode.Spawn.startingHealth)
    SetPedArmour(playerPed, DefaultGamemode.Spawn.startingArmor)
    
    -- Give starting weapons
    RemoveAllPedWeapons(playerPed, true)
    for _, weaponData in ipairs(DefaultGamemode.Player.startingWeapons) do
        GiveWeaponToPed(playerPed, GetHashKey(weaponData.weapon), weaponData.ammo, false, true)
    end
    
    -- Enable spawn protection
    EnableSpawnProtection()
    
    -- Clear any wanted level
    ClearPlayerWantedLevel(PlayerId())
    
    -- Fade in
    DoScreenFadeIn(1000)
    
    -- Success message
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 100},
        multiline = true,
        args = {"[SPAWN]", "Spawned at " .. spawnData.locationName .. "!"}
    })
    
    print("[DEFAULT GAMEMODE] Player spawned at: " .. spawnData.locationName)
end

-- Event: Spawn vehicle
RegisterNetEvent(DefaultGamemode.Events.spawnVehicle)
AddEventHandler(DefaultGamemode.Events.spawnVehicle, function(vehicleData)
    SpawnVehicleForPlayer(vehicleData)
end)

-- Spawn vehicle for player
function SpawnVehicleForPlayer(vehicleData)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Find a suitable spawn location
    local spawnCoords = FindVehicleSpawnLocation(playerCoords)
    
    if not spawnCoords then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[VEHICLE]", "Could not find a suitable spawn location!"}
        })
        return
    end
    
    -- Request vehicle model
    local modelHash = GetHashKey(vehicleData.model)
    RequestModel(modelHash)
    
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end
    
    -- Create vehicle
    local vehicle = CreateVehicle(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    
    -- Set vehicle properties
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    
    -- Put player in vehicle
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    
    -- Clean up model
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Success message
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 100},
        multiline = true,
        args = {"[VEHICLE]", "Spawned " .. vehicleData.name .. "!"}
    })
    
    print("[DEFAULT GAMEMODE] Vehicle spawned: " .. vehicleData.name)
end

-- Find a suitable vehicle spawn location
function FindVehicleSpawnLocation(playerCoords)
    local testCoords = {
        -- Try positions around the player
        vector4(playerCoords.x + 5.0, playerCoords.y, playerCoords.z, 0.0),
        vector4(playerCoords.x - 5.0, playerCoords.y, playerCoords.z, 180.0),
        vector4(playerCoords.x, playerCoords.y + 5.0, playerCoords.z, 270.0),
        vector4(playerCoords.x, playerCoords.y - 5.0, playerCoords.z, 90.0),
        vector4(playerCoords.x + 10.0, playerCoords.y, playerCoords.z, 0.0),
        vector4(playerCoords.x - 10.0, playerCoords.y, playerCoords.z, 180.0),
    }
    
    for _, coords in ipairs(testCoords) do
        if IsPositionSuitable(coords) then
            return coords
        end
    end
    
    -- If no position found around player, use predefined locations
    for _, coords in ipairs(DefaultGamemode.Vehicles.spawnLocations) do
        if IsPositionSuitable(coords) then
            return coords
        end
    end
    
    return nil
end

-- Check if position is suitable for vehicle spawn
function IsPositionSuitable(coords)
    -- Check if position is clear
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 70)
    if DoesEntityExist(vehicle) then
        return false
    end
    
    -- Check if position is on ground
    local groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    if math.abs(coords.z - groundZ) > 5.0 then
        return false
    end
    
    return true
end

-- Handle player death and respawn
AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
    print("[DEFAULT GAMEMODE] Player died, preparing respawn...")
    
    -- Wait a moment before respawn
    Citizen.SetTimeout(3000, function()
        TriggerServerEvent(DefaultGamemode.Events.requestSpawn)
    end)
end)

-- Handle player killed event
AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathCause)
    if killerId then
        local killerName = GetPlayerName(GetPlayerFromServerId(killerId))
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DEATH]", "You were killed by " .. killerName}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DEATH]", "You died"}
        })
    end
    
    print("[DEFAULT GAMEMODE] Player was killed")
end)

-- Export spawn functions for other resources
exports('SpawnPlayerAtLocation', SpawnPlayerAtLocation)
exports('SpawnVehicleForPlayer', SpawnVehicleForPlayer)
exports('FindVehicleSpawnLocation', FindVehicleSpawnLocation)