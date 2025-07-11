--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Lobby System - UI Management
    Anti-Copyright Protection
--]]

local isUIVisible = false

-- Show gamemode selection UI
function ShowGamemodeSelectionUI()
    if isUIVisible then
        if Config.Lobby.debug then
            print("[LOBBY UI] UI already visible, ignoring show request")
        end
        return
    end
    
    isUIVisible = true
    
    -- Enable NUI focus
    SetNuiFocus(true, true)
    
    if Config.Lobby.debug then
        print("[LOBBY UI] Sending gamemode data to UI:")
        for i, gamemode in ipairs(Config.Gamemodes) do
            print("  - " .. gamemode.name .. " (ID: " .. gamemode.id .. ", Enabled: " .. tostring(gamemode.enabled) .. ")")
        end
    end
    
    -- Send gamemode data to UI
    SendNUIMessage({
        type = "showGamemodeSelection",
        gamemodes = Config.Gamemodes
    })
    
    if Config.Lobby.debug then
        print("[LOBBY UI] Gamemode selection UI shown with " .. #Config.Gamemodes .. " gamemodes")
    end
end

-- Hide gamemode selection UI
function HideGamemodeSelectionUI()
    if not isUIVisible then
        return
    end
    
    isUIVisible = false
    
    -- Disable NUI focus
    SetNuiFocus(false, false)
    
    -- Hide UI
    SendNUIMessage({
        type = "hideGamemodeSelection"
    })
    
    if Config.Lobby.debug then
        print("[LOBBY UI] Gamemode selection UI hidden")
    end
end

-- Handle NUI messages from the UI
RegisterNUICallback('selectGamemode', function(data, cb)
    local gamemodeId = data.gamemodeId
    
    if Config.Lobby.debug then
        print("[LOBBY UI] Gamemode selected via UI: " .. tostring(gamemodeId))
    end
    
    -- Validate gamemode exists and is enabled
    local validGamemode = false
    for _, gamemode in ipairs(Config.Gamemodes) do
        if gamemode.id == gamemodeId and gamemode.enabled then
            validGamemode = true
            break
        end
    end
    
    if validGamemode then
        -- Send selection to server
        TriggerServerEvent(Config.Events.selectGamemode, gamemodeId)
        cb('ok')
    else
        if Config.Lobby.debug then
            print("[LOBBY UI] Invalid gamemode selected: " .. tostring(gamemodeId))
        end
        cb('error')
    end
end)

-- Handle UI close callback
RegisterNUICallback('closeUI', function(data, cb)
    if Config.Lobby.debug then
        print("[LOBBY UI] UI close requested")
    end
    
    -- For now, we don't allow closing the UI without selecting a gamemode
    -- This could be changed to allow reconnection or server disconnect
    cb('ok')
end)

-- Handle escape key to prevent UI closing
RegisterNUICallback('escapePressed', function(data, cb)
    if Config.Lobby.debug then
        print("[LOBBY UI] Escape key pressed in UI")
    end
    
    -- Ignore escape key presses for now
    cb('ok')
end)

-- Update UI with current gamemode information
function UpdateGamemodeUI()
    if not isUIVisible then
        return
    end
    
    SendNUIMessage({
        type = "updateGamemodes",
        gamemodes = Config.Gamemodes
    })
end

-- Show loading screen while transitioning
function ShowLoadingScreen(message)
    SendNUIMessage({
        type = "showLoading",
        message = message or "Loading..."
    })
end

-- Hide loading screen
function HideLoadingScreen()
    SendNUIMessage({
        type = "hideLoading"
    })
end

-- Console command to manually show UI for testing
RegisterCommand('showlobby', function()
    if Config.Lobby.debug then
        print("[LOBBY UI] Manual UI trigger via command")
    end
    ShowGamemodeSelectionUI()
end, false)

-- Console command to hide UI for testing
RegisterCommand('hidelobby', function()
    if Config.Lobby.debug then
        print("[LOBBY UI] Manual UI hide via command")
    end
    HideGamemodeSelectionUI()
end, false)

-- Export functions for other resources
exports('ShowGamemodeSelectionUI', ShowGamemodeSelectionUI)
exports('HideGamemodeSelectionUI', HideGamemodeSelectionUI)
exports('UpdateGamemodeUI', UpdateGamemodeUI)
exports('ShowLoadingScreen', ShowLoadingScreen)
exports('HideLoadingScreen', HideLoadingScreen)