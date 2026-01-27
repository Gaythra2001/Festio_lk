"""
Generate sample training data for the recommendation system
"""

import random
from datetime import datetime, timedelta
from typing import List, Dict, Any


def generate_sample_interactions(
    n_users: int = 50,
    n_events: int = 100,
    n_interactions: int = 500
) -> List[Dict[str, Any]]:
    """
    Generate sample user-event interaction data for testing
    
    Args:
        n_users: Number of unique users
        n_events: Number of unique events
        n_interactions: Number of total interactions
    
    Returns:
        List of interaction dictionaries
    """
    interactions = []
    
    # Event categories and types for realistic simulation
    categories = ['music', 'food', 'sports', 'art', 'tech', 'cultural', 'educational']
    locations = ['Colombo', 'Kandy', 'Galle', 'Negombo', 'Jaffna', 'Anuradhapura']
    
    # Create event metadata
    events = []
    for i in range(n_events):
        events.append({
            'id': f'event_{i}',
            'category': random.choice(categories),
            'location': random.choice(locations),
            'base_rating': random.uniform(3.0, 5.0)
        })
    
    # Generate user preferences
    users = []
    for i in range(n_users):
        users.append({
            'id': f'user_{i}',
            'preferred_categories': random.sample(categories, k=random.randint(2, 4)),
            'preferred_location': random.choice(locations)
        })
    
    # Generate interactions based on preferences
    for _ in range(n_interactions):
        user = random.choice(users)
        event = random.choice(events)
        
        # Higher rating if preferences match
        base_rating = event['base_rating']
        
        # Category match bonus
        if event['category'] in user['preferred_categories']:
            base_rating += random.uniform(0.5, 1.0)
        
        # Location match bonus
        if event['location'] == user['preferred_location']:
            base_rating += random.uniform(0.2, 0.5)
        
        # Add some randomness
        rating = min(5.0, max(1.0, base_rating + random.uniform(-1.0, 0.5)))
        
        # Random timestamp in the past 30 days
        days_ago = random.randint(0, 30)
        timestamp = datetime.now() - timedelta(days=days_ago)
        
        interactions.append({
            'user_id': user['id'],
            'event_id': event['id'],
            'rating': round(rating, 2),
            'timestamp': timestamp.isoformat(),
            'interaction_type': random.choice(['view', 'click', 'booking'])
        })
    
    return interactions


def generate_sample_events() -> List[Dict[str, Any]]:
    """Generate sample event data"""
    categories = ['music', 'food', 'sports', 'art', 'tech', 'cultural', 'educational']
    locations = ['Colombo', 'Kandy', 'Galle', 'Negombo', 'Jaffna', 'Anuradhapura']
    
    events = []
    for i in range(100):
        events.append({
            'id': f'event_{i}',
            'title': f'Sample Event {i}',
            'category': random.choice(categories),
            'location': random.choice(locations),
            'price': random.uniform(500, 10000),
            'trust_score': random.uniform(60, 100),
            'organizer_id': f'org_{random.randint(1, 20)}'
        })
    
    return events


if __name__ == '__main__':
    # Generate and print sample data
    interactions = generate_sample_interactions(n_users=20, n_events=50, n_interactions=200)
    print(f"Generated {len(interactions)} sample interactions")
    print("\nSample interaction:")
    print(interactions[0])
    
    events = generate_sample_events()
    print(f"\nGenerated {len(events)} sample events")
    print("\nSample event:")
    print(events[0])
