# Advanced AI Event Recommendation System - Research Documentation

## Executive Summary

This document describes the research-grade AI recommendation system implemented in the Festio event discovery application. The system employs multiple state-of-the-art machine learning algorithms and advanced data collection methods to provide highly personalized event recommendations to users in Sri Lanka.

## System Architecture

### Overview

The recommendation system consists of three main components:

1. **Data Collection Layer** - Collects explicit and implicit user feedback
2. **Recommendation Engine** - Processes data using multiple ML algorithms
3. **Chatbot Interface** - Provides conversational AI assistance

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface Layer                     │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │ Preferences  │  │   Chatbot    │  │  Event Cards    │  │
│  │     Form     │  │  Interface   │  │ (Recommended)   │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                   Application Layer                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │        RecommendationProvider (State Manager)        │  │
│  └──────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    Service Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │   Advanced   │  │   Chatbot    │  │    Behavior     │  │
│  │Recommendation│  │   Service    │  │    Tracking     │  │
│  │    Engine    │  │              │  │    Service      │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                      Data Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │   User       │  │   User       │  │     Events      │  │
│  │ Preferences  │  │  Behavior    │  │   & Bookings    │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Data Collection

### 1. Explicit User Feedback

**User Preferences Form** - Comprehensive 6-page questionnaire collecting:

#### Demographics (Page 1)
- Age, Gender, Religion
- Occupation, Education Level
- **Research Value**: Enables demographic-based segmentation and analysis

#### Location & Budget (Page 2)
- Primary location/district
- Preferred travel areas (multi-select)
- Maximum travel distance (5-200 km)
- Budget range (min/max in LKR)
- Budget flexibility (strict/flexible/very flexible)
- **Research Value**: Spatial analysis, economic profiling

#### Event Preferences (Page 3)
- Favorite event types (Music, Religious, Cultural, Sports, etc.)
- Music genres preferences
- Favorite artists (free-form text)
- Favorite venues
- Disliked event types
- **Research Value**: Content-based filtering, category preferences

#### Behavioral Preferences (Page 4)
- Preferred event time (morning/afternoon/evening/night)
- Preferred days of week
- Typical group size
- Family-friendly preference
- Indoor/Outdoor preferences
- Adventure level (1-5 scale)
- Social style (introverted/extroverted/ambivert)
- **Research Value**: Behavioral segmentation, temporal patterns

#### Cultural Preferences (Page 5)
- Observes Poya days (Buddhist full moon)
- Observes religious holidays
- Cultural interests (Traditional/Modern/Fusion, etc.)
- Language preference (English/Sinhala/Tamil)
- **Research Value**: Cultural analysis, religious event matching

#### Notification Settings (Page 6)
- Personalization consent
- Location-based recommendations consent
- Research data sharing consent
- Notification frequency (1-7 scale)
- **Research Value**: Consent management, engagement preferences

### 2. Implicit User Feedback

**User Behavior Tracking** - Automated collection of:

#### Engagement Metrics
- **Session Metrics**
  - Total sessions
  - Average session duration
  - Days active
  - Activity by hour of day
  - Activity by day of week

- **Event Interaction**
  - Event views (count per event)
  - Event clicks (count per event)
  - Time spent on each event (seconds)
  - Event shares
  - Event favorites/saves

- **Category Engagement**
  - Category views
  - Tag clicks
  - Time spent per category

#### Search Behavior
- Search queries (last 50)
- Search term frequency
- Clicked search results
- **Research Value**: Query analysis, intent detection

#### Booking Behavior
- Total bookings
- Cancelled bookings
- Average ticket price
- Bookings per month
- Bookings by category
- Bookings by day of week
- Bookings by time slot
- **Research Value**: Conversion analysis, revenue patterns

#### Performance Metrics
- Click-through rate (CTR)
- Booking conversion rate
- Abandoned events (viewed but not booked)
- Notification engagement
- **Research Value**: System performance evaluation

## Recommendation Algorithms

### Algorithm Architecture

The system employs a **Hybrid Ensemble Approach** combining multiple algorithms with weighted scores:

```
Total Score = 
    0.25 × Content-Based Score +
    0.25 × Collaborative Filtering Score +
    0.20 × Behavior-Based Score +
    0.15 × Preference-Based Score +
    0.10 × Contextual Score +
    0.05 × Diversity Score
```

### 1. Content-Based Filtering (CBF)

**Algorithm**: Feature-based similarity matching

**Features Analyzed**:
- Event category
- Event location
- Event tags
- Price range
- Organizer trust score

**Scoring Method**:
```
CBF_Score = 0.4 × Category_Match + 
            0.3 × Location_Match + 
            0.3 × Tag_Overlap
```

**Research Contribution**:
- Cold start problem mitigation
- New user recommendations
- Preference stability analysis

### 2. Collaborative Filtering (CF)

**Algorithm**: User-based collaborative filtering with Jaccard similarity

**Similarity Metric**:
```
Jaccard(User A, User B) = |Events_A ∩ Events_B| / |Events_A ∪ Events_B|
```

**Minimum Threshold**: At least 2 common events required

**Scoring Method**:
```
CF_Score = Σ(Similarity_i × HasBooked_i) / Σ(Similarity_i)
```

**Research Contribution**:
- Social proof integration
- Community behavior patterns
- Network effects analysis

### 3. Behavior-Based Scoring

**Algorithm**: Implicit feedback weighting

**Signals**:
- Event views: `min(views/5, 1.0) × 0.2`
- Time spent: `min(time/60, 1.0) × 0.3`
- Category engagement: `min(category_views/10, 1.0) × 0.25`
- Favorites/shares: `0.25` (strong signal)

**Research Contribution**:
- Implicit preference learning
- Engagement prediction
- Attention economics

### 4. Preference-Based Scoring

**Algorithm**: Direct preference matching

**Scoring Components**:
- Favorite event types: `0.25`
- Budget constraints: `0.15` (or heavy penalty if exceeded)
- Location preference: `0.20`
- Artist/venue matching: `0.15`
- Cultural/religious alignment: `0.15`
- Family-friendly matching: `0.10`

**Research Contribution**:
- Explicit vs implicit feedback comparison
- Preference drift analysis
- Cultural event personalization

### 5. Contextual Scoring

**Algorithm**: Time and location-aware recommendations

**Temporal Features**:
- Days until event (recency bias)
- Day of week preference
- Time of day preference
- Weekend boost
- Seasonal relevance

**Scoring**:
```
Context_Score = Recency_Score(0.3) + 
                DayOfWeek_Match(0.2) + 
                TimeOfDay_Match(0.2) + 
                Weekend_Bonus(0.15) + 
                Seasonal_Match(0.15)
```

**Research Contribution**:
- Temporal dynamics
- Contextual bandits
- Seasonal event patterns

### 6. Diversity Scoring

**Algorithm**: Anti-filter-bubble mechanism

**Method**:
- Penalize events similar to past bookings
- Reward new categories
- Reward new locations

**Scoring**:
```
Diversity_Score = 1.0 (new category) |
                  0.8 (new location) |
                  0.5 (similar to past)
```

**Research Contribution**:
- Filter bubble prevention
- Exploration-exploitation balance
- Serendipity in recommendations

### 7. Multi-Armed Bandit (MAB)

**Algorithm**: Epsilon-greedy exploration

**Parameters**:
- Epsilon (ε) = 0.15 (15% exploration)
- Temperature (τ) = 0.1 (softmax selection)

**Method**:
- 85% of time: Exploit (use scores with softmax probabilities)
- 15% of time: Explore (random selection)

**Softmax Formula**:
```
P(event_i) = exp((score_i - max_score) / τ) / Σ exp((score_j - max_score) / τ)
```

**Research Contribution**:
- Exploration strategy evaluation
- Cold start mitigation
- Long-tail event discovery

### 8. Diversity Re-Ranking

**Algorithm**: Post-processing for variety

**Method**:
1. Always include top 3 events (quality)
2. Then prioritize diversity:
   - Limit 2 events per category
   - Limit 2 events per location
3. Fill remaining with highest scores

**Research Contribution**:
- Post-hoc diversification
- User satisfaction correlation
- Category balance

## Quality Scoring

**Trust-based adjustments**:
```
Quality_Multiplier = 1.0 + (TrustScore / 200)
```

**Spam prevention**:
- Recent + low trust events: `0.5× penalty`

## AI Chatbot System

### Natural Language Processing (NLP)

**Intent Classification**:
- Greeting detection
- Event search
- Recommendation requests
- Event details queries
- Booking help
- Preference updates
- Feedback handling

**Entity Extraction**:
- Event categories (music, religious, cultural, etc.)
- Locations (Colombo, Kandy, Galle, etc.)
- Time references (today, tomorrow, this weekend)
- Budget constraints (LKR amounts)
- Event count (number of results)
- Price filters (free/paid)

**Regex Patterns**:
```dart
Greeting: r'\b(hi|hello|hey|greetings)\b'
Search: r'\b(search|find|look for|show me)\b'
Recommend: r'\b(recommend|suggest|what should|popular)\b'
```

### Dialogue Management

**Context Tracking**:
- Last intent
- Extracted entities
- Conversation history (last 20 messages)
- User preferences state

**Response Generation**:
- Template-based responses
- Dynamic event listings
- Explanation generation
- Quick reply suggestions

### Conversational Features

1. **Session Memory**: Remembers conversation context
2. **Multi-turn Dialogues**: Handles follow-up questions
3. **Personalization**: Uses user data for responses
4. **Suggestions**: Provides quick reply options
5. **Explanations**: Explains why events are recommended

## Research Methodology

### Data Privacy & Ethics

- **Consent Management**: Explicit opt-in for data collection
- **Privacy Controls**: User can disable tracking anytime
- **Data Minimization**: Only collect necessary data
- **Transparency**: Users can see why events are recommended

### Evaluation Metrics

#### 1. Recommendation Quality
- **Precision@K**: Accuracy of top-K recommendations
- **Recall@K**: Coverage of relevant events
- **Mean Average Precision (MAP)**: Overall ranking quality
- **Normalized Discounted Cumulative Gain (NDCG)**: Ranking quality with position weighting

#### 2. User Engagement
- **Click-Through Rate (CTR)**: Clicked recommendations / Total shown
- **Conversion Rate**: Bookings / Event views
- **Session Duration**: Time spent in app
- **Return Rate**: Users returning within 7 days

#### 3. Diversity Metrics
- **Category Coverage**: Unique categories in top-20
- **Intra-List Diversity**: Average dissimilarity in recommendations
- **Serendipity Score**: Unexpected but relevant recommendations

#### 4. Business Metrics
- **Revenue per User**: Average booking value
- **Booking Frequency**: Bookings per month
- **Cancellation Rate**: Cancelled bookings / Total bookings

### A/B Testing Framework

**Test Groups**:
- Control: Legacy recommendation engine
- Treatment: Advanced AI engine

**Metrics to Compare**:
- CTR improvement
- Conversion rate improvement
- User satisfaction (surveys)
- Engagement metrics

### Research Questions

1. **Algorithm Performance**: Which algorithm contributes most to recommendation quality?
2. **Cultural Factors**: How do cultural preferences affect event selection in Sri Lanka?
3. **Temporal Patterns**: What are the temporal event attendance patterns?
4. **Exploration vs Exploitation**: What is the optimal ε value for MAB?
5. **Chatbot Effectiveness**: Does conversational UI improve user engagement?
6. **Cold Start**: How quickly can the system learn new user preferences?

## Implementation Details

### Technology Stack

- **Language**: Dart (Flutter)
- **Backend**: Firebase (Firestore, Cloud Functions)
- **ML Framework**: Custom implementation (no external ML libraries)
- **State Management**: Provider pattern

### Performance Optimization

1. **Caching**: Store user preferences and behavior locally
2. **Batch Processing**: Update behavior metrics in batches
3. **Lazy Loading**: Load recommendations on-demand
4. **Incremental Updates**: Update scores incrementally, not full recalculation

### Scalability Considerations

- **Horizontal Scaling**: Stateless recommendation service
- **Data Partitioning**: User data sharded by userId
- **Async Processing**: Background behavior tracking
- **Rate Limiting**: Prevent abuse of chatbot API

## Future Enhancements

### Short-term (3-6 months)
1. **Matrix Factorization**: SVD for latent factor analysis
2. **Deep Learning Embeddings**: Event and user embeddings
3. **Graph Neural Networks**: Social network-based recommendations
4. **Multi-objective Optimization**: Balance multiple goals (diversity, accuracy, novelty)

### Medium-term (6-12 months)
1. **Reinforcement Learning**: Learn optimal recommendation strategy
2. **Causal Inference**: Understand cause-effect in user behavior
3. **Transfer Learning**: Learn from other event platforms
4. **Federated Learning**: Privacy-preserving collaborative learning

### Long-term (12+ months)
1. **Conversational Recommendations**: Full dialogue-based discovery
2. **Multi-modal Learning**: Incorporate images, videos, reviews
3. **Real-time Personalization**: Update recommendations in real-time
4. **Explainable AI (XAI)**: Better explanation of recommendations

## Research Output

### Expected Publications

1. **Conference Paper**: "Hybrid Recommendation System for Cultural Events in Developing Countries"
2. **Journal Article**: "Impact of Cultural Preferences on Event Discovery: A Sri Lankan Case Study"
3. **Workshop Paper**: "Conversational AI for Event Recommendations"

### Datasets

- **User Preferences Dataset**: Demographic and preference data
- **Behavioral Dataset**: Interaction logs and engagement metrics
- **Event Dataset**: Event metadata and features
- **Chatbot Conversations**: Dialogue corpus for NLP research

### Open Source Contributions

- Recommendation engine framework
- Cultural event ontology
- Multilingual NLP for Sinhala/Tamil/English

## Conclusion

This advanced AI recommendation system represents a significant research contribution in the domains of:
- Recommender systems
- Cultural computing
- Conversational AI
- Behavioral analytics

The system is designed to be:
- **Scalable**: Can handle millions of users
- **Accurate**: Multiple algorithms ensure quality
- **User-friendly**: Chatbot and simple interfaces
- **Privacy-conscious**: User control over data
- **Research-ready**: Comprehensive metrics and evaluation

## References

1. Ricci, F., Rokach, L., & Shapira, B. (2015). Recommender Systems Handbook. Springer.
2. Adomavicius, G., & Tuzhilin, A. (2005). Toward the Next Generation of Recommender Systems. IEEE TKDE.
3. Li, L., et al. (2010). A Contextual-Bandit Approach to Personalized News Article Recommendation. WWW.
4. Ziegler, C. N., et al. (2005). Improving Recommendation Lists Through Topic Diversification. WWW.
5. Jurafsky, D., & Martin, J. H. (2020). Speech and Language Processing. Pearson.

## Contact

For research inquiries, please contact the development team.

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Author**: Festio Research Team
