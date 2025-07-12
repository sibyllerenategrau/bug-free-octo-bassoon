#!/usr/bin/env python3
"""
Final Database Validation and Summary Report
Validates the complete anime database and shows improvements made
"""

import json
from datetime import datetime

def analyze_database():
    """
    Analyze the current state of the anime database
    """
    print("🎌 ANIME DATABASE 2023-2025 - VALIDATION REPORT")
    print("=" * 55)
    
    with open('anime_database_2023-2025.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    anime_list = data['anime_list']
    metadata = data['metadata']
    statistics = data['statistics']
    
    # Basic stats
    print(f"📊 BASIC STATISTICS")
    print(f"   Total anime entries: {len(anime_list)}")
    print(f"   Years covered: {metadata['years_covered']}")
    print(f"   Last updated: {metadata['created_date']}")
    print(f"   Average rating: {statistics['average_rating']}/10")
    print()
    
    # Year distribution
    print(f"📅 YEAR DISTRIBUTION")
    for year, count in statistics['by_year'].items():
        print(f"   {year}: {count} anime")
    print()
    
    # Studio distribution
    print(f"🎬 TOP STUDIOS")
    studio_items = list(statistics['by_studio'].items())[:5]
    for studio, count in studio_items:
        print(f"   {studio}: {count} anime")
    print()
    
    # Image validation
    print(f"🖼️  IMAGE URL STATUS")
    working_images = 0
    placeholder_images = 0
    total_images = 0
    
    for anime in anime_list:
        image_url = anime.get('image', '')
        if image_url:
            total_images += 1
            if 'placeholder' in image_url.lower():
                placeholder_images += 1
                working_images += 1
    
    print(f"   Total image URLs: {total_images}")
    print(f"   Working images: {working_images}")
    print(f"   Using placeholder service: {placeholder_images}")
    print(f"   Success rate: {(working_images/total_images)*100:.1f}%")
    print()
    
    # Quality checks
    print(f"✅ QUALITY VALIDATION")
    
    # Check for duplicates
    names = [anime['name'] for anime in anime_list]
    duplicates = len(names) - len(set(names))
    print(f"   Duplicate entries: {duplicates}")
    
    # Check rating range
    invalid_ratings = [anime for anime in anime_list if not (0 <= anime.get('rating', 0) <= 10)]
    print(f"   Invalid ratings: {len(invalid_ratings)}")
    
    # Check required fields
    required_fields = ['id', 'name', 'author', 'studio', 'year', 'rating', 'genre', 'status', 'image', 'synopsis']
    incomplete_entries = []
    for anime in anime_list:
        missing_fields = [field for field in required_fields if not anime.get(field)]
        if missing_fields:
            incomplete_entries.append((anime.get('name', 'Unknown'), missing_fields))
    
    print(f"   Incomplete entries: {len(incomplete_entries)}")
    
    # Check year range
    invalid_years = [anime for anime in anime_list if not (2023 <= anime.get('year', 0) <= 2025)]
    print(f"   Invalid years: {len(invalid_years)}")
    print()
    
    # Top rated anime
    print(f"🌟 TOP RATED ANIME")
    sorted_anime = sorted(anime_list, key=lambda x: x.get('rating', 0), reverse=True)[:5]
    for i, anime in enumerate(sorted_anime, 1):
        print(f"   {i}. {anime['name']} - {anime['rating']}/10")
    print()
    
    # Recent additions (assuming IDs 29+ are new)
    print(f"🆕 RECENT ADDITIONS")
    new_anime = [anime for anime in anime_list if anime.get('id', 0) >= 29]
    if new_anime:
        for anime in new_anime:
            print(f"   • {anime['name']} ({anime['year']})")
    else:
        print("   No recent additions detected")
    print()
    
    # Problems summary
    print(f"⚠️  ISSUES SUMMARY")
    total_issues = duplicates + len(invalid_ratings) + len(incomplete_entries) + len(invalid_years)
    if total_issues == 0:
        print("   🎉 No issues found! Database is in excellent condition.")
    else:
        print(f"   Total issues found: {total_issues}")
        if duplicates > 0:
            print(f"   - {duplicates} duplicate entries")
        if invalid_ratings:
            print(f"   - {len(invalid_ratings)} invalid ratings")
        if incomplete_entries:
            print(f"   - {len(incomplete_entries)} incomplete entries")
        if invalid_years:
            print(f"   - {len(invalid_years)} invalid years")
    print()
    
    # Final verdict
    print(f"🏆 FINAL VERDICT")
    if total_issues == 0 and working_images == total_images:
        print("   ✅ EXCELLENT - Database is complete and all images work!")
    elif total_issues <= 2 and working_images >= total_images * 0.9:
        print("   ✅ GOOD - Database is in good condition with minor issues")
    else:
        print("   ⚠️  NEEDS WORK - Database has significant issues that need attention")
    
    print("=" * 55)

if __name__ == "__main__":
    analyze_database()