# Anime Database 2023-2025

## Description

This JSON database contains a comprehensive list of the best anime series and movies from 2023 to 2025. The database includes detailed information about each anime including ratings, studios, creators, and episode counts.

## Database Structure

### Main Fields

Each anime entry contains the following information:

- **id**: Unique identifier for the anime
- **name**: English title of the anime
- **name_japanese**: Original Japanese title  
- **author**: Original creator/mangaka
- **studio**: Animation studio responsible for production
- **year**: Release year (2023-2025)
- **rating**: Average rating out of 10
- **genre**: Array of genre tags
- **seasons**: Total number of seasons
- **episodes**: Number of episodes in the specific season/entry
- **status**: Current status (Completed, Ongoing, Announced, Movie)
- **image**: URL to cover image
- **synopsis**: Brief description of the anime

### Statistics

The database includes comprehensive statistics:

- **Total Entries**: 28 anime
- **Year Distribution**: 
  - 2023: 12 entries
  - 2024: 12 entries  
  - 2025: 4 entries
- **Average Rating**: 8.8/10
- **Top Studios**: MAPPA (5), Ufotable (3), A-1 Pictures (2)
- **Movies Included**: 4 films

## Top Rated Anime

1. **Frieren: Beyond Journey's End** - 9.4/10
2. **Vinland Saga Season 2** - 9.3/10
3. **Demon Slayer: Swordsmith Village Arc** - 9.2/10
4. **One Piece: Egghead Arc** - 9.2/10
5. **Jujutsu Kaisen Season 2** - 9.1/10

## Data Validation

The database has been validated for:

- ✅ No duplicate entries
- ✅ Valid year ranges (2023-2025)
- ✅ Valid rating ranges (0-10)
- ✅ Required fields present
- ✅ Proper JSON syntax

## Usage

```javascript
// Load the database
const animeDB = require('./anime_database_2023-2025.json');

// Get all anime from 2024
const anime2024 = animeDB.anime_list.filter(anime => anime.year === 2024);

// Get highest rated anime
const topRated = animeDB.anime_list
  .sort((a, b) => b.rating - a.rating)
  .slice(0, 10);

// Get anime by studio
const mappaAnime = animeDB.anime_list.filter(anime => anime.studio === 'MAPPA');
```

## Data Sources

The anime information has been compiled from multiple reliable sources including:
- MyAnimeList (MAL)
- Official studio announcements
- Licensed streaming platforms
- Anime news websites

## Last Updated

December 28, 2024

## File Location

`anime_database_2023-2025.json`