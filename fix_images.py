#!/usr/bin/env python3
"""
Final Image URL Fix Script
Updates all anime entries to use reliable placeholder images
"""

import json
from urllib.parse import quote

def generate_reliable_image_url(anime_name, anime_id):
    """
    Generate a reliable placeholder image URL for anime
    Uses via.placeholder.com which is very reliable
    """
    # Clean the name for URL encoding
    clean_name = anime_name[:25].replace(":", "").replace("!", "").strip()
    encoded_name = quote(clean_name.replace(" ", "+"))
    
    # Create a consistent color scheme based on anime ID
    colors = [
        ("2c3e50", "ecf0f1"),  # Dark blue / Light gray
        ("8e44ad", "f8c471"),  # Purple / Yellow
        ("e74c3c", "f8f9fa"),  # Red / White
        ("27ae60", "2c3e50"),  # Green / Dark
        ("f39c12", "2c3e50"),  # Orange / Dark
        ("3498db", "ecf0f1"),  # Blue / Light
        ("1abc9c", "2c3e50"),  # Teal / Dark
        ("e67e22", "ecf0f1"),  # Orange / Light
    ]
    
    bg_color, text_color = colors[anime_id % len(colors)]
    
    return f"https://via.placeholder.com/225x350/{bg_color}/{text_color}?text={encoded_name}"

def fix_all_images():
    """
    Fix all image URLs in the database to use reliable sources
    """
    print("Fixing all image URLs to use reliable sources...")
    
    with open('anime_database_2023-2025.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    fixed_count = 0
    
    for anime in data['anime_list']:
        old_url = anime['image']
        new_url = generate_reliable_image_url(anime['name'], anime['id'])
        anime['image'] = new_url
        
        print(f"Fixed: {anime['name']}")
        print(f"  New URL: {new_url}")
        fixed_count += 1
    
    # Save the updated database
    with open('anime_database_2023-2025.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Fixed {fixed_count} image URLs")
    print("All images now use reliable placeholder service")
    
    return fixed_count

if __name__ == "__main__":
    fix_all_images()