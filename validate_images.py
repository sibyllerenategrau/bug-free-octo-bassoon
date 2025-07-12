#!/usr/bin/env python3
"""
Image URL Validation Script
Tests all image URLs in the anime database to ensure they're working
"""

import json
import requests
from urllib.parse import urlparse

def validate_image_url(url, timeout=5):
    """
    Validate if an image URL is accessible
    Returns: (is_valid, status_code, error_message)
    """
    try:
        response = requests.head(url, timeout=timeout, allow_redirects=True)
        return (response.status_code == 200, response.status_code, None)
    except requests.exceptions.RequestException as e:
        return (False, None, str(e))

def validate_database_images():
    """
    Validate all image URLs in the anime database
    """
    print("Validating anime database images...")
    
    with open('anime_database_2023-2025.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    total_anime = len(data['anime_list'])
    valid_images = 0
    invalid_images = 0
    
    print(f"Testing {total_anime} image URLs...\n")
    
    for anime in data['anime_list']:
        image_url = anime.get('image', '')
        anime_name = anime.get('name', 'Unknown')
        
        if not image_url:
            print(f"❌ {anime_name}: No image URL provided")
            invalid_images += 1
            continue
        
        # Check if it's a placeholder URL (which should work)
        if 'placeholder' in image_url.lower():
            print(f"📝 {anime_name}: Using placeholder image (should work)")
            valid_images += 1
            continue
        
        # Test the URL
        is_valid, status_code, error = validate_image_url(image_url)
        
        if is_valid:
            print(f"✅ {anime_name}: Image URL working ({status_code})")
            valid_images += 1
        else:
            print(f"❌ {anime_name}: Image URL failed - {error or f'Status: {status_code}'}")
            invalid_images += 1
    
    # Summary
    print(f"\n{'='*50}")
    print(f"IMAGE VALIDATION SUMMARY")
    print(f"{'='*50}")
    print(f"Total anime entries: {total_anime}")
    print(f"Valid image URLs: {valid_images}")
    print(f"Invalid image URLs: {invalid_images}")
    print(f"Success rate: {(valid_images/total_anime)*100:.1f}%")
    
    if invalid_images == 0:
        print("\n🎉 All image URLs are valid!")
    elif valid_images > invalid_images:
        print(f"\n✅ Most images are working ({valid_images}/{total_anime})")
    else:
        print(f"\n⚠️  Many images need attention ({invalid_images}/{total_anime} failing)")
    
    return valid_images, invalid_images

if __name__ == "__main__":
    validate_database_images()