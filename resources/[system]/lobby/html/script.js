/*
    ██╗  ██╗ █████╗ ██╗   ██╗ ██████╗  ██████╗██████╗ ██╗   ██╗██████╗ 
    ██║  ██║██╔══██╗██║   ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔══██╗
    ███████║███████║██║   ██║██║   ██║██║     ██████╔╝██║   ██║██████╔╝
    ██╔══██║██╔══██║╚██╗ ██╔╝██║   ██║██║     ██╔═══╝ ╚██╗ ██╔╝██╔═══╝ 
    ██║  ██║██║  ██║ ╚████╔╝ ╚██████╔╝╚██████╗██║      ╚████╔╝ ██║     
    ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ╚═════╝╚═╝       ╚═══╝  ╚═╝     
    
    HavocPvP Lobby UI JavaScript - Anti-Copyright Protection
*/

// Global variables
let gamemodes = [];
let isVisible = false;

// DOM elements
const mainContainer = document.getElementById('mainContainer');
const gamemodeGrid = document.getElementById('gamemodeGrid');
const loadingScreen = document.getElementById('loadingScreen');
const loadingMessage = document.getElementById('loadingMessage');

// Initialize UI when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('[LOBBY UI] DOM loaded, initializing...');
    
    // Hide UI initially
    hideUI();
    
    // Add event listeners
    addEventListeners();
});

// Add event listeners
function addEventListeners() {
    // Prevent context menu
    document.addEventListener('contextmenu', function(e) {
        e.preventDefault();
        return false;
    });
    
    // Handle escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            e.preventDefault();
            // Send escape event to FiveM client
            fetch(`https://${GetParentResourceName()}/escapePressed`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
        }
    });
}

// Show the UI
function showUI() {
    isVisible = true;
    mainContainer.style.display = 'flex';
    console.log('[LOBBY UI] UI shown');
}

// Hide the UI
function hideUI() {
    isVisible = false;
    mainContainer.style.display = 'none';
    console.log('[LOBBY UI] UI hidden');
}

// Show loading screen
function showLoading(message = 'Loading...') {
    loadingMessage.textContent = message;
    loadingScreen.style.display = 'flex';
    console.log('[LOBBY UI] Loading screen shown:', message);
}

// Hide loading screen
function hideLoading() {
    loadingScreen.style.display = 'none';
    console.log('[LOBBY UI] Loading screen hidden');
}

// Render gamemode cards
function renderGamemodes() {
    if (!gamemodeGrid) {
        console.error('[LOBBY UI] Gamemode grid element not found');
        return;
    }
    
    // Clear existing cards
    gamemodeGrid.innerHTML = '';
    
    // Create cards for each gamemode
    gamemodes.forEach(gamemode => {
        const card = createGamemodeCard(gamemode);
        gamemodeGrid.appendChild(card);
    });
    
    console.log('[LOBBY UI] Rendered', gamemodes.length, 'gamemode cards');
}

// Create a gamemode card element
function createGamemodeCard(gamemode) {
    const card = document.createElement('div');
    card.className = `gamemode-card ${gamemode.enabled ? '' : 'disabled'}`;
    card.dataset.gamemodeId = gamemode.id;
    
    // Determine status
    let status = 'available';
    let statusText = 'Available';
    
    if (!gamemode.enabled) {
        status = 'disabled';
        statusText = 'Coming Soon';
    } else if (gamemode.currentPlayers >= gamemode.maxPlayers) {
        status = 'full';
        statusText = 'Full';
    }
    
    card.innerHTML = `
        <div class="gamemode-icon">${gamemode.icon}</div>
        <div class="gamemode-title">${gamemode.name}</div>
        <div class="gamemode-description">${gamemode.description}</div>
        <div class="gamemode-players">Players: ${gamemode.currentPlayers || 0}/${gamemode.maxPlayers}</div>
        <div class="gamemode-status status-${status}">${statusText}</div>
    `;
    
    // Add click handler if enabled
    if (gamemode.enabled && status !== 'full') {
        card.addEventListener('click', function() {
            selectGamemode(gamemode.id);
        });
    }
    
    return card;
}

// Handle gamemode selection
function selectGamemode(gamemodeId) {
    console.log('[LOBBY UI] Gamemode selected:', gamemodeId);
    
    // Show loading screen
    showLoading('Connecting to gamemode...');
    
    // Send selection to FiveM client
    fetch(`https://${GetParentResourceName()}/selectGamemode`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            gamemodeId: gamemodeId
        })
    })
    .then(response => response.text())
    .then(data => {
        if (data === 'ok') {
            console.log('[LOBBY UI] Gamemode selection successful');
        } else {
            console.error('[LOBBY UI] Gamemode selection failed');
            hideLoading();
        }
    })
    .catch(error => {
        console.error('[LOBBY UI] Error selecting gamemode:', error);
        hideLoading();
    });
}

// Update gamemode data
function updateGamemodes(newGamemodes) {
    gamemodes = newGamemodes;
    renderGamemodes();
    console.log('[LOBBY UI] Gamemodes updated');
}

// Handle messages from FiveM client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch (data.type) {
        case 'showGamemodeSelection':
            gamemodes = data.gamemodes || [];
            renderGamemodes();
            showUI();
            break;
            
        case 'hideGamemodeSelection':
            hideUI();
            break;
            
        case 'updateGamemodes':
            updateGamemodes(data.gamemodes || []);
            break;
            
        case 'showLoading':
            showLoading(data.message);
            break;
            
        case 'hideLoading':
            hideLoading();
            break;
            
        default:
            console.log('[LOBBY UI] Unknown message type:', data.type);
            break;
    }
});

// Utility function to get parent resource name
function GetParentResourceName() {
    return window.GetParentResourceName ? window.GetParentResourceName() : 'lobby';
}

// Expose functions globally for debugging
window.LobbyUI = {
    showUI,
    hideUI,
    showLoading,
    hideLoading,
    selectGamemode,
    updateGamemodes,
    renderGamemodes
};

console.log('[LOBBY UI] JavaScript initialized');