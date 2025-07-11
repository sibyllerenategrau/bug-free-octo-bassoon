--[[
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    Default Gamemode - Shared Configuration
    Anti-Copyright Protection
--]]

DefaultGamemode = {}

-- Gamemode Information
DefaultGamemode.Info = {
    id = "default",
    name = "Default Gamemode",
    description = "Basic gamemode with free roam and basic features",
    version = "1.0.0"
}

-- Spawn Configuration
DefaultGamemode.Spawn = {
    -- Available spawn locations (Los Santos area)
    locations = {
        {
            name = "Los Santos Airport",
            coords = vector4(-1037.88, -2738.47, 20.17, 330.0),
            description = "International Airport"
        },
        {
            name = "Vinewood Hills",
            coords = vector4(-1288.36, 306.82, 84.94, 150.0),
            description = "Scenic hills with great views"
        },
        {
            name = "Beach Pier",
            coords = vector4(-1798.85, -1220.27, 13.02, 310.0),
            description = "Peaceful beach location"
        },
        {
            name = "Downtown",
            coords = vector4(-259.31, -938.44, 31.22, 205.0),
            description = "City center with all amenities"
        },
        {
            name = "Grove Street",
            coords = vector4(88.87, -1965.36, 21.12, 315.0),
            description = "Classic neighborhood"
        }
    },
    
    -- Default spawn if no preference
    defaultLocation = 1,
    
    -- Allow players to choose spawn location
    allowChoice = true,
    
    -- Spawn protection time (milliseconds)
    protectionTime = 10000,
    
    -- Starting health and armor
    startingHealth = 200,
    startingArmor = 100
}

-- Player Configuration
DefaultGamemode.Player = {
    -- Starting money
    startingMoney = 5000,
    
    -- Enable PvP
    pvpEnabled = true,
    
    -- Weapon loadout
    startingWeapons = {
        {weapon = "WEAPON_PISTOL", ammo = 100},
        {weapon = "WEAPON_KNIFE", ammo = 1}
    },
    
    -- Player models (both male and female options)
    availableModels = {
        "mp_m_freemode_01", -- Male
        "mp_f_freemode_01"  -- Female
    },
    
    -- Enable nametags
    showNametags = true,
    nametagDistance = 50.0
}

-- Vehicle Configuration
DefaultGamemode.Vehicles = {
    -- Allow personal vehicles
    allowPersonalVehicles = true,
    
    -- Vehicle spawn locations
    spawnLocations = {
        vector4(-1036.0, -2731.0, 20.17, 240.0), -- Airport
        vector4(-1290.0, 304.0, 84.5, 150.0),    -- Vinewood
        vector4(-1800.0, -1218.0, 13.0, 310.0),  -- Beach
        vector4(-261.0, -936.0, 31.2, 205.0),    -- Downtown
        vector4(86.0, -1963.0, 21.1, 315.0)      -- Grove Street
    },
    
    -- Available vehicles for spawning
    availableVehicles = {
        {name = "Sultan", model = "sultan", price = 0},
        {name = "Elegy", model = "elegy2", price = 0},
        {name = "Kuruma", model = "kuruma", price = 0},
        {name = "Zentorno", model = "zentorno", price = 1000},
        {name = "T20", model = "t20", price = 2000},
        {name = "Sanchez", model = "sanchez", price = 0},
        {name = "PCJ-600", model = "pcj", price = 500}
    }
}

-- Events
DefaultGamemode.Events = {
    -- Client to Server
    playerJoined = "default:playerJoined",
    playerLeft = "default:playerLeft",
    requestSpawn = "default:requestSpawn",
    requestVehicle = "default:requestVehicle",
    
    -- Server to Client
    spawnPlayer = "default:spawnPlayer",
    spawnVehicle = "default:spawnVehicle",
    playerData = "default:playerData",
    
    -- Shared Events
    playerKilled = "default:playerKilled",
    playerDamaged = "default:playerDamaged"
}

-- Chat Commands
DefaultGamemode.Commands = {
    -- General commands
    {name = "spawn", description = "Open spawn menu"},
    {name = "car", description = "Spawn a vehicle"},
    {name = "tp", description = "Teleport to coordinates"},
    {name = "heal", description = "Restore health and armor"},
    {name = "suicide", description = "Kill yourself"},
    
    -- Admin commands
    {name = "kick", description = "Kick a player", adminOnly = true},
    {name = "ban", description = "Ban a player", adminOnly = true},
    {name = "god", description = "Toggle god mode", adminOnly = true}
}