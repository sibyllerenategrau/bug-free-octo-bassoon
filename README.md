# HavocPvP Multi-Gamemode FiveM Server

```
██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
```

A well-structured FiveM server with a lobby system and multiple gamemode support. Players join a lobby first, where they can select their preferred gamemode before being redirected to the appropriate game instance.

## Features

### 🎮 Lobby System
- **Player Interception**: Players don't spawn their character immediately upon joining
- **Gamemode Selection**: Beautiful UI for choosing between available gamemodes
- **Seamless Transition**: Smooth switching between lobby and gamemode
- **Player Management**: Server-side tracking of players in lobby vs gamemodes

### 🏆 Default Gamemode
- **Free Roam**: Open world exploration and interaction
- **Multiple Spawn Locations**: 5 different spawn points across Los Santos
- **Vehicle Spawning**: Command-based vehicle spawning system
- **Economy System**: Basic money system with transactions
- **PvP Combat**: Player vs player combat with kill rewards
- **Player Stats**: Tracking of kills, deaths, money, and playtime

### 🎨 Quality UI/UX
- **Modern Design**: Clean, responsive interface with gradients and animations
- **Interactive Cards**: Hover effects and visual feedback
- **Loading States**: Smooth transitions with loading indicators
- **Mobile Responsive**: Works on different screen sizes

## Structure

```
/
├── server.cfg                 # FiveM server configuration
├── resources/
│   ├── [system]/
│   │   └── lobby/            # Lobby system resource
│   │       ├── fxmanifest.lua
│   │       ├── client/       # Client-side lobby logic
│   │       ├── server/       # Server-side lobby management
│   │       ├── shared/       # Shared configuration
│   │       └── html/         # UI files (HTML/CSS/JS)
│   └── [gamemodes]/
│       └── default/          # Default gamemode resource
│           ├── fxmanifest.lua
│           ├── client/       # Client-side gamemode logic
│           ├── server/       # Server-side gamemode management
│           └── shared/       # Shared gamemode configuration
```

## Installation

1. **Download/Clone** this repository to your FiveM server directory
2. **Configure** your server.cfg file (replace license key and Steam Web API key)
3. **Start** the server with the included configuration
4. **Connect** to the server and experience the lobby system

## Configuration

### Server Settings
Edit `server.cfg` to customize:
- Server name and description
- Maximum players
- License key and Steam Web API key
- Resource loading order

### Lobby Settings
Edit `resources/[system]/lobby/shared/config.lua` to customize:
- Available gamemodes
- Spawn coordinates for lobby
- UI delay timing
- Debug settings

### Gamemode Settings
Edit `resources/[gamemodes]/default/shared/config.lua` to customize:
- Spawn locations
- Starting money and weapons
- Available vehicles
- Player settings

## Commands

### Player Commands
- `/spawn` - Open spawn menu
- `/car [vehicle]` - Spawn a vehicle
- `/heal` - Restore health and armor
- `/money` - Check current money
- `/stats` - View player statistics
- `/pay [id] [amount]` - Transfer money to another player
- `/vehicles` - List available vehicles
- `/help` - Show available commands

### Admin Commands (Console Only)
- `/lobbystatus` - Show lobby status and player counts
- `/defaultstatus` - Show default gamemode status
- `/givemoney [id] [amount] [reason]` - Give money to player
- `/takemoney [id] [amount] [reason]` - Take money from player
- `/setmoney [id] [amount]` - Set player money amount

## Development

### Adding New Gamemodes
1. Create a new folder in `resources/[gamemodes]/`
2. Follow the structure of the default gamemode
3. Add your gamemode to the lobby configuration
4. Implement the `gamemode:join` event handler

### Customizing the UI
The lobby UI is built with HTML, CSS, and JavaScript:
- `html/index.html` - Structure
- `html/style.css` - Styling and animations
- `html/script.js` - Interactive functionality

### Code Standards
- All scripts include HavocPvP ASCII art header (anti-copyright)
- Comprehensive comments in English
- Clean, modular code structure
- Event-driven architecture
- Proper error handling

## Contributing

When contributing to this project:
1. Maintain the ASCII art headers in all files
2. Comment your code thoroughly in English
3. Follow the existing code structure and patterns
4. Test your changes with the lobby system

## License

This project includes anti-copyright protection via ASCII art headers. The HavocPvP branding is part of the project identity.
