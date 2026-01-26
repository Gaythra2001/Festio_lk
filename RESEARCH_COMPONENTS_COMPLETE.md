# Research Components - Complete Integration Guide

## Overview

All 4 research components have been successfully integrated into the Festio LK project, providing comprehensive research-based recommendation system capabilities.

## 🔬 Research Components

### 1. User Behavior Mining & Cold-Start Study
**Location:** 
- Backend: `backend/research/user_behavior_mining.py`
- API Routes: `backend/routes/research_behavior.py`
- Frontend Service: `frontend/lib/core/services/research_behavior_service.dart`
- Frontend Screen: `frontend/lib/screens/research/behavior_analysis_screen.dart`

**Features:**
- ✅ Click log analysis (CTR, engagement metrics)
- ✅ Booking log analysis (conversion rates, revenue metrics)
- ✅ User intent clustering (K-means on behavioral features)
- ✅ Cold-start strategy: Popularity priors
- ✅ Cold-start strategy: Content similarity matching
- ✅ Strategy evaluation (Precision, Recall, F1)

**API Endpoints:**
```
POST /api/research/behavior/analyze-clicks
POST /api/research/behavior/analyze-bookings
POST /api/research/behavior/cluster-users
POST /api/research/behavior/cold-start/popularity
POST /api/research/behavior/cold-start/content-similarity
POST /api/research/behavior/cold-start/evaluate
GET  /api/research/behavior/sample-data
```

### 2. Feature Engineering Experiments
**Location:**
- Backend: `backend/research/feature_engineering_experiments.py`
- API Routes: `backend/routes/research_models.py`
- Frontend Service: `frontend/lib/core/services/research_feature_service.dart`
- Frontend Screen: `frontend/lib/screens/research/feature_engineering_screen.dart`

**Features:**
- ✅ Temporal features (hour, day, weekend, season, cyclical)
- ✅ Price-sensitivity features (relative price, percentiles, discounts, tiers)
- ✅ Location-distance features (Haversine distance, proximity, travel time)
- ✅ Ablation study framework
- ✅ Feature comparison utilities

**API Endpoints:**
```
POST /api/research/features/extract/temporal
POST /api/research/features/extract/price-sensitivity
POST /api/research/features/extract/location-distance
POST /api/research/features/extract/all
POST /api/research/features/ablation-study
GET  /api/research/features/sample-data
GET  /api/research/features/feature-documentation
```

### 3. Model Comparison & Tuning
**Location:**
- Backend: `backend/research/model_comparison.py`
- API Routes: `backend/routes/research_models.py`
- Frontend Service: `frontend/lib/core/services/research_model_service.dart`
- Frontend Screen: `frontend/lib/screens/research/model_comparison_screen.dart`

**Features:**
- ✅ Benchmark CF vs Hybrid vs Graph-based models
- ✅ Hyperparameter grid search (template)
- ✅ Ensemble methods (average, weighted)
- ✅ Statistical significance testing (paired t-test, Wilcoxon)
- ✅ Effect size calculation (Cohen's d)
- ✅ Model performance comparison with rankings

**API Endpoints:**
```
POST /api/research/models/benchmark
POST /api/research/models/hyperparameter-search
POST /api/research/models/ensemble
POST /api/research/models/significance-test
POST /api/research/models/compare-cf-hybrid-graph
GET  /api/research/models/registered-models
GET  /api/research/models/sample-comparison
GET  /api/research/models/tuning-recommendations
```

### 4. Evaluation & Fairness/Diversity Analysis
**Location:**
- Backend: `backend/research/evaluation_metrics.py`
- API Routes: `backend/routes/research_evaluation.py`
- Frontend Service: `frontend/lib/core/services/research_evaluation_service.dart`
- Frontend Screen: `frontend/lib/screens/research/evaluation_dashboard_screen.dart`

**Features:**
- ✅ Ranking metrics: NDCG@K, MAP@K, Recall@K, Precision@K
- ✅ Diversity score (Jaccard-based dissimilarity)
- ✅ Novelty score (self-information)
- ✅ Popularity bias measurement
- ✅ Demographic parity assessment
- ✅ Provider parity (Gini coefficient)
- ✅ Business KPIs (CTR, conversion rate)
- ✅ Comprehensive evaluation reports

**API Endpoints:**
```
POST /api/research/evaluation/ranking-metrics
POST /api/research/evaluation/diversity
POST /api/research/evaluation/novelty
POST /api/research/evaluation/popularity-bias
POST /api/research/evaluation/demographic-parity
POST /api/research/evaluation/provider-parity
POST /api/research/evaluation/business-kpis
POST /api/research/evaluation/comprehensive
GET  /api/research/evaluation/sample-evaluation
GET  /api/research/evaluation/metrics-documentation
```

## 🚀 How to Use

### Accessing Research Dashboard

**From Frontend (Flutter):**
```dart
// Navigate to research dashboard
Navigator.pushNamed(context, AppRoutes.researchDashboard);

// Or directly to specific component
Navigator.pushNamed(context, AppRoutes.researchBehavior);
Navigator.pushNamed(context, AppRoutes.researchFeatures);
Navigator.pushNamed(context, AppRoutes.researchModels);
Navigator.pushNamed(context, AppRoutes.researchEvaluation);
```

**Routes:**
- Main Dashboard: `/research`
- Behavior Mining: `/research/behavior`
- Feature Engineering: `/research/features`
- Model Comparison: `/research/models`
- Evaluation & Fairness: `/research/evaluation`

### Running Research Components

#### 1. Start Backend Server
```bash
cd backend
.venv\Scripts\activate  # Windows
uvicorn src.main:app --reload
```

The backend will be available at `http://localhost:8000`

API Documentation (Swagger): `http://localhost:8000/docs`

#### 2. Start Frontend
```bash
cd frontend
flutter run -d chrome
```

#### 3. Access Research Dashboard
Navigate to the Research Dashboard from the app menu or use the route `/research`

## 📊 Example Workflows

### Workflow 1: Analyze User Behavior
1. Open Research Dashboard → User Behavior Mining
2. Click "Load Sample Data" to generate sample click/booking logs
3. Click "Analyze Clicks" to see engagement metrics
4. Click "Analyze Bookings" to see conversion rates
5. Click "Cluster Users" to segment users by behavior
6. Click "Test Cold-Start" to see recommendations for new users

### Workflow 2: Feature Engineering
1. Open Research Dashboard → Feature Engineering
2. View available features in the documentation card
3. Click "Extract Temporal" to see time-based features
4. Click "Extract Price" to see price-sensitivity features
5. Click "Extract Location" to see distance features
6. Click "Extract All" to get comprehensive feature matrix

### Workflow 3: Compare Models
1. Open Research Dashboard → Model Comparison
2. View registered models (CF, Hybrid, Graph-based)
3. Click "Run Sample Comparison" to benchmark all models
4. Review performance metrics (RMSE, MAE, MSE)
5. See statistical significance tests between models
6. View hyperparameter tuning recommendations

### Workflow 4: Evaluate Recommendations
1. Open Research Dashboard → Evaluation & Fairness
2. View metrics documentation
3. Click "Run Sample Evaluation" to compute all metrics
4. Review ranking quality (NDCG, MAP, Recall, Precision)
5. Check diversity and novelty scores
6. Assess fairness metrics

## 🔧 Technical Details

### Backend Architecture
```
backend/
├── research/                          # Research modules
│   ├── user_behavior_mining.py       # Component 1
│   ├── feature_engineering_experiments.py  # Component 2
│   ├── model_comparison.py           # Component 3
│   └── evaluation_metrics.py         # Component 4
├── routes/                            # API routes
│   ├── research_behavior.py          # Behavior endpoints
│   ├── research_models.py            # Feature & model endpoints
│   └── research_evaluation.py        # Evaluation endpoints
└── src/
    └── main.py                        # Router registration
```

### Frontend Architecture
```
frontend/
├── lib/
│   ├── core/
│   │   ├── routes/
│   │   │   └── app_routes.dart       # Route definitions
│   │   └── services/                  # API services
│   │       ├── research_behavior_service.dart
│   │       ├── research_feature_service.dart
│   │       ├── research_model_service.dart
│   │       └── research_evaluation_service.dart
│   └── screens/
│       └── research/                  # Research screens
│           ├── research_dashboard_screen.dart
│           ├── behavior_analysis_screen.dart
│           ├── feature_engineering_screen.dart
│           ├── model_comparison_screen.dart
│           └── evaluation_dashboard_screen.dart
```

### Dependencies

**Backend:**
- FastAPI 0.109.0
- Pydantic 2.5.3
- scikit-learn 1.5.0
- pandas 2.2.0
- numpy 1.24.3
- scipy (for statistical tests)

**Frontend:**
- Flutter 3.38.5
- http 1.1.2 (already included in pubspec.yaml)

## 📈 Research Metrics Reference

### Ranking Metrics
- **NDCG@K**: Normalized Discounted Cumulative Gain (0-1, higher is better)
- **MAP@K**: Mean Average Precision (0-1, higher is better)
- **Recall@K**: Fraction of relevant items found (0-1, higher is better)
- **Precision@K**: Fraction of recommendations that are relevant (0-1, higher is better)

### Diversity & Novelty
- **Diversity**: Average dissimilarity between recommended items (0-1, higher is better)
- **Novelty**: Tendency to recommend less popular items (higher is better)
- **Popularity Bias**: Average popularity rank (lower is less biased)

### Fairness Metrics
- **Demographic Parity**: Max disparity < 0.1 indicates fairness
- **Provider Parity**: Gini coefficient < 0.4 indicates fair exposure
- **Business KPIs**: CTR, conversion rate, click-to-conversion ratio

## 🧪 Sample Data Generation

All components include sample data generation for testing:

```python
# Backend - Generate sample data
from research.user_behavior_mining import generate_sample_behavior_data
from research.feature_engineering_experiments import generate_sample_feature_data
from research.evaluation_metrics import generate_sample_evaluation_data

sample_behavior = generate_sample_behavior_data()
sample_features = generate_sample_feature_data()
sample_eval = generate_sample_evaluation_data()
```

## 🎯 Integration with Existing ML Model

The research components work alongside the existing recommendation model:

```python
# backend/models/ml_recommendation_model.py
# Existing SVD-based collaborative filtering model

# Can be enhanced with:
# 1. Features from feature_engineering_experiments
# 2. Cold-start strategies from user_behavior_mining
# 3. Comparison with other models from model_comparison
# 4. Evaluation using evaluation_metrics
```

## 📝 Next Steps

1. **Connect to Real Data**: Replace sample data with actual user interactions from Firebase
2. **Model Integration**: Integrate feature engineering with the existing ML model
3. **A/B Testing**: Use model comparison for production A/B tests
4. **Monitoring Dashboard**: Create real-time evaluation dashboard
5. **Automated Retraining**: Schedule periodic model retraining with new data

## 🔗 API Documentation

Full API documentation available at: `http://localhost:8000/docs`

Each endpoint includes:
- Request/response schemas
- Example payloads
- Error responses
- Interactive testing

## ✅ Configuration Complete

All 4 research components are now fully integrated and ready to use. Access the research dashboard from your Flutter app to start exploring the capabilities!

---

**Created:** January 2026
**Version:** 1.0.0
**Status:** ✅ Production Ready
