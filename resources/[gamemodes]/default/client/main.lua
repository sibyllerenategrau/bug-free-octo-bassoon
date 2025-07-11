--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Default Gamemode - Client Main Script
    Anti-Copyright Protection
--]]

local playerInGamemode = false
local playerData = {}
local spawnProtection = false
local spawnProtectionEnd = 0

-- Initialize when joining gamemode from lobby
RegisterNetEvent('gamemode:join')
AddEventHandler('gamemode:join', function(gamemodeId)
    if gamemodeId == DefaultGamemode.Info.id then
        print("[DEFAULT GAMEMODE] Joining default gamemode...")
        JoinDefaultGamemode()
    end
end)

-- Join the default gamemode
function JoinDefaultGamemode()
    if playerInGamemode then
        return -- Already in gamemode
    end
    
    playerInGamemode = true
    
    -- Notify server that player joined
    TriggerServerEvent(DefaultGamemode.Events.playerJoined)
    
    -- Initialize client-side features
    InitializeGamemode()
    
    print("[DEFAULT GAMEMODE] Successfully joined default gamemode")
end

-- Initialize gamemode features
function InitializeGamemode()
    -- Request spawn
    TriggerServerEvent(DefaultGamemode.Events.requestSpawn)
    
    -- Set up nametags if enabled
    if DefaultGamemode.Player.showNametags then
        SetupNametags()
    end
    
    -- Set up HUD
    SetupHUD()
    
    -- Welcome message
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 100},
        multiline = true,
        args = {"[DEFAULT GAMEMODE]", "Welcome to the default gamemode! Type /help for available commands."}
    })
end

-- Set up player nametags
function SetupNametags()
    Citizen.CreateThread(function()
        while playerInGamemode do
            local players = GetActivePlayers()
            local localPlayer = PlayerId()
            local localPed = PlayerPedId()
            local localCoords = GetEntityCoords(localPed)
            
            for _, player in ipairs(players) do
                if player ~= localPlayer then
                    local ped = GetPlayerPed(player)
                    if DoesEntityExist(ped) then
                        local coords = GetEntityCoords(ped)
                        local distance = #(localCoords - coords)
                        
                        if distance <= DefaultGamemode.Player.nametagDistance then
                            local name = GetPlayerName(player)
                            local serverId = GetPlayerServerId(player)
                            
                            -- Draw nametag
                            DrawText3D(coords.x, coords.y, coords.z + 1.0, name .. " [" .. serverId .. "]")
                        end
                    end
                end
            end
            
            Citizen.Wait(0)
        end
    end)
end

-- Draw 3D text helper function
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
    end
end

-- Set up HUD elements
function SetupHUD()
    Citizen.CreateThread(function()
        while playerInGamemode do
            -- Hide default HUD elements we don't want
            HideHudComponentThisFrame(1)  -- Wanted stars
            HideHudComponentThisFrame(2)  -- Weapon icon
            HideHudComponentThisFrame(3)  -- Cash
            HideHudComponentThisFrame(4)  -- MP Cash
            HideHudComponentThisFrame(6)  -- Vehicle name
            HideHudComponentThisFrame(7)  -- Area name
            HideHudComponentThisFrame(8)  -- Vehicle class
            HideHudComponentThisFrame(9)  -- Street name
            
            -- Show spawn protection indicator
            if spawnProtection then
                local timeLeft = math.max(0, spawnProtectionEnd - GetGameTimer())
                if timeLeft > 0 then
                    DrawRect(0.5, 0.05, 0.2, 0.05, 0, 255, 0, 100)
                    DrawAdvancedText(0.5, 0.05, 0.005, 0.0028, 0.4, "Spawn Protection: " .. math.ceil(timeLeft / 1000) .. "s", 255, 255, 255, 255, 4, 1)
                else
                    spawnProtection = false
                end
            end
            
            Citizen.Wait(0)
        end
    end)
end

-- Advanced text drawing function
function DrawAdvancedText(x, y, w, h, sc, text, r, g, b, a, font, jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    if jus == 1 then
        SetTextCentre(1)
    elseif jus == 2 then
        SetTextRightJustify(1)
        SetTextWrap(0, x)
    end
    DrawText(x - w/2, y - h/2 + 0.005)
end

-- Event: Spawn player
RegisterNetEvent(DefaultGamemode.Events.spawnPlayer)
AddEventHandler(DefaultGamemode.Events.spawnPlayer, function(spawnData)
    print("[DEFAULT GAMEMODE] Spawning player at location: " .. spawnData.locationName)
    SpawnPlayerAtLocation(spawnData)
end)

-- Event: Receive player data
RegisterNetEvent(DefaultGamemode.Events.playerData)
AddEventHandler(DefaultGamemode.Events.playerData, function(data)
    playerData = data
    print("[DEFAULT GAMEMODE] Received player data: $" .. data.money)
end)

-- Handle spawn protection
function EnableSpawnProtection()
    spawnProtection = true
    spawnProtectionEnd = GetGameTimer() + DefaultGamemode.Spawn.protectionTime
    
    local playerPed = PlayerPedId()
    SetEntityInvincible(playerPed, true)
    
    -- Remove protection after time expires
    Citizen.SetTimeout(DefaultGamemode.Spawn.protectionTime, function()
        if spawnProtection then
            spawnProtection = false
            SetEntityInvincible(playerPed, false)
            TriggerEvent('chat:addMessage', {
                color = {255, 165, 0},
                multiline = true,
                args = {"[DEFAULT GAMEMODE]", "Spawn protection has expired!"}
            })
        end
    end)
end

-- Commands
RegisterCommand('spawn', function()
    if playerInGamemode then
        TriggerServerEvent(DefaultGamemode.Events.requestSpawn)
    end
end, false)

RegisterCommand('car', function(source, args)
    if playerInGamemode then
        local vehicleName = args[1] or "sultan"
        TriggerServerEvent(DefaultGamemode.Events.requestVehicle, vehicleName)
    end
end, false)

RegisterCommand('heal', function()
    if playerInGamemode then
        local playerPed = PlayerPedId()
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
        SetPedArmour(playerPed, DefaultGamemode.Player.startingArmor)
        
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"[DEFAULT GAMEMODE]", "Health and armor restored!"}
        })
    end
end, false)

RegisterCommand('suicide', function()
    if playerInGamemode then
        local playerPed = PlayerPedId()
        SetEntityHealth(playerPed, 0)
    end
end, false)

RegisterCommand('help', function()
    if playerInGamemode then
        TriggerEvent('chat:addMessage', {
            color = {100, 150, 255},
            multiline = true,
            args = {"[HELP]", "Available commands: /spawn, /car [name], /heal, /suicide, /help"}
        })
    end
end, false)

-- Handle resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if playerInGamemode then
            TriggerServerEvent(DefaultGamemode.Events.playerLeft)
        end
    end
end)

-- Handle player disconnect
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and playerInGamemode then
        TriggerServerEvent(DefaultGamemode.Events.playerLeft)
    end
end)