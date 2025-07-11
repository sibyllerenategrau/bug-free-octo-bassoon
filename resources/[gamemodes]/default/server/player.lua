--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Default Gamemode - Player Management
    Anti-Copyright Protection
--]]

-- Advanced player management functions

-- Give money to player
function GivePlayerMoney(playerId, amount, reason)
    local playerData = gamemodePlayers[playerId]
    if not playerData then
        return false
    end
    
    playerData.money = playerData.money + amount
    
    -- Update client
    TriggerClientEvent(DefaultGamemode.Events.playerData, playerId, playerData)
    
    -- Notify player
    if reason then
        TriggerClientEvent('chat:addMessage', playerId, {
            color = {0, 255, 100},
            multiline = true,
            args = {"[MONEY]", "You received $" .. amount .. " (" .. reason .. ")"}
        })
    end
    
    print("[DEFAULT GAMEMODE] Gave $" .. amount .. " to " .. GetPlayerName(playerId))
    return true
end

-- Take money from player
function TakePlayerMoney(playerId, amount, reason)
    local playerData = gamemodePlayers[playerId]
    if not playerData or playerData.money < amount then
        return false
    end
    
    playerData.money = playerData.money - amount
    
    -- Update client
    TriggerClientEvent(DefaultGamemode.Events.playerData, playerId, playerData)
    
    -- Notify player
    if reason then
        TriggerClientEvent('chat:addMessage', playerId, {
            color = {255, 165, 0},
            multiline = true,
            args = {"[MONEY]", "You lost $" .. amount .. " (" .. reason .. ")"}
        })
    end
    
    print("[DEFAULT GAMEMODE] Took $" .. amount .. " from " .. GetPlayerName(playerId))
    return true
end

-- Transfer money between players
function TransferMoney(fromPlayerId, toPlayerId, amount)
    local fromData = gamemodePlayers[fromPlayerId]
    local toData = gamemodePlayers[toPlayerId]
    
    if not fromData or not toData or fromData.money < amount then
        return false
    end
    
    -- Transfer money
    fromData.money = fromData.money - amount
    toData.money = toData.money + amount
    
    -- Update both clients
    TriggerClientEvent(DefaultGamemode.Events.playerData, fromPlayerId, fromData)
    TriggerClientEvent(DefaultGamemode.Events.playerData, toPlayerId, toData)
    
    -- Notify both players
    TriggerClientEvent('chat:addMessage', fromPlayerId, {
        color = {255, 165, 0},
        multiline = true,
        args = {"[TRANSFER]", "You sent $" .. amount .. " to " .. GetPlayerName(toPlayerId)}
    })
    
    TriggerClientEvent('chat:addMessage', toPlayerId, {
        color = {0, 255, 100},
        multiline = true,
        args = {"[TRANSFER]", "You received $" .. amount .. " from " .. GetPlayerName(fromPlayerId)}
    })
    
    return true
end

-- Handle player death
AddEventHandler('playerDied', function(playerId, killerId, deathCause)
    local playerData = gamemodePlayers[playerId]
    if not playerData then
        return
    end
    
    -- Increment death count
    playerData.deaths = playerData.deaths + 1
    
    -- Death penalty (lose some money)
    local penalty = math.min(playerData.money * 0.1, 500) -- 10% or $500 max
    if penalty > 0 then
        TakePlayerMoney(playerId, penalty, "death penalty")
    end
    
    -- Handle killer rewards
    if killerId and killerId ~= playerId and gamemodePlayers[killerId] then
        local killerData = gamemodePlayers[killerId]
        killerData.kills = killerData.kills + 1
        
        -- Give killer reward
        local reward = 100
        GivePlayerMoney(killerId, reward, "kill reward")
        
        -- Update killer data
        TriggerClientEvent(DefaultGamemode.Events.playerData, killerId, killerData)
    end
    
    -- Update player data
    TriggerClientEvent(DefaultGamemode.Events.playerData, playerId, playerData)
    
    print("[DEFAULT GAMEMODE] Player death: " .. GetPlayerName(playerId) .. " (Killer: " .. (killerId and GetPlayerName(killerId) or "Unknown") .. ")")
end)

-- Admin commands for player management
RegisterCommand('givemoney', function(source, args, rawCommand)
    if source ~= 0 then -- Only console
        return
    end
    
    if #args < 2 then
        print("Usage: givemoney <playerId> <amount> [reason]")
        return
    end
    
    local playerId = tonumber(args[1])
    local amount = tonumber(args[2])
    local reason = args[3] or "admin"
    
    if not playerId or not amount then
        print("Invalid arguments")
        return
    end
    
    if GivePlayerMoney(playerId, amount, reason) then
        print("Gave $" .. amount .. " to player " .. playerId)
    else
        print("Failed to give money to player " .. playerId)
    end
end, true)

RegisterCommand('takemoney', function(source, args, rawCommand)
    if source ~= 0 then -- Only console
        return
    end
    
    if #args < 2 then
        print("Usage: takemoney <playerId> <amount> [reason]")
        return
    end
    
    local playerId = tonumber(args[1])
    local amount = tonumber(args[2])
    local reason = args[3] or "admin"
    
    if not playerId or not amount then
        print("Invalid arguments")
        return
    end
    
    if TakePlayerMoney(playerId, amount, reason) then
        print("Took $" .. amount .. " from player " .. playerId)
    else
        print("Failed to take money from player " .. playerId)
    end
end, true)

RegisterCommand('setmoney', function(source, args, rawCommand)
    if source ~= 0 then -- Only console
        return
    end
    
    if #args < 2 then
        print("Usage: setmoney <playerId> <amount>")
        return
    end
    
    local playerId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not playerId or not amount or not gamemodePlayers[playerId] then
        print("Invalid arguments or player not in gamemode")
        return
    end
    
    gamemodePlayers[playerId].money = amount
    TriggerClientEvent(DefaultGamemode.Events.playerData, playerId, gamemodePlayers[playerId])
    
    print("Set player " .. playerId .. " money to $" .. amount)
end, true)

-- Player command to check stats
RegisterCommand('stats', function(source, args, rawCommand)
    local playerData = gamemodePlayers[source]
    if not playerData then
        return
    end
    
    local playTime = os.time() - playerData.joinTime
    local hours = math.floor(playTime / 3600)
    local minutes = math.floor((playTime % 3600) / 60)
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {100, 150, 255},
        multiline = true,
        args = {"[STATS]", "Money: $" .. playerData.money .. " | Kills: " .. playerData.kills .. " | Deaths: " .. playerData.deaths .. " | Playtime: " .. hours .. "h " .. minutes .. "m"}
    })
end, false)

-- Player command to transfer money
RegisterCommand('pay', function(source, args, rawCommand)
    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[PAY]", "Usage: /pay <playerId> <amount>"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId or not amount or amount <= 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[PAY]", "Invalid player ID or amount"}
        })
        return
    end
    
    if targetId == source then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[PAY]", "You cannot pay yourself"}
        })
        return
    end
    
    if not gamemodePlayers[targetId] then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[PAY]", "Target player not found or not in gamemode"}
        })
        return
    end
    
    if TransferMoney(source, targetId, amount) then
        print("[DEFAULT GAMEMODE] Money transfer: " .. GetPlayerName(source) .. " -> " .. GetPlayerName(targetId) .. " ($" .. amount .. ")")
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[PAY]", "Insufficient funds"}
        })
    end
end, false)

-- Export player management functions
exports('GivePlayerMoney', GivePlayerMoney)
exports('TakePlayerMoney', TakePlayerMoney)
exports('TransferMoney', TransferMoney)