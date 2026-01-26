""""""













































































































































































































































































































































































    }        }            }                "Conversion Rate": "Percentage of recommendations leading to bookings"                "CTR": "Click-through rate - Percentage of recommendations clicked",            "business_kpis": {            },                "Provider Parity": "Fairness of exposure distribution across providers (Gini coefficient)"                "Demographic Parity": "Similarity of recommendation quality across user groups",            "fairness": {            },                "Popularity Bias": "Average popularity rank of recommendations (lower is less biased)"                "Novelty": "Tendency to recommend less popular items (higher is better)",                "Diversity": "How different recommended items are from each other (0-1, higher is better)",            "diversity_novelty": {            },                "Precision@K": "Fraction of top K that are relevant"                "Recall@K": "Fraction of relevant items found in top K",                "MAP@K": "Mean Average Precision - Average precision across all relevant items",                "NDCG@K": "Normalized Discounted Cumulative Gain - Measures ranking quality with position discount",            "ranking_metrics": {        "metrics": {        "status": "success",    return {    """    Get documentation for all evaluation metrics.    """async def get_metrics_documentation():@router.get("/metrics-documentation")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "evaluation_report": report            },                "total_interactions": sample_data['total_interactions']                "total_items": len(sample_data['item_features']),                "relevant_count": len(sample_data['relevant']),                "recommended_count": len(sample_data['recommended']),            "data_summary": {            "note": "Sample evaluation with synthetic data",            "status": "success",        return {                )            sample_data['total_interactions']            sample_data['item_popularity'],            sample_data['item_features'],            sample_data['k_values'],            sample_data['relevant'],            sample_data['recommended'],        report = evaluator.comprehensive_evaluation(                item_popularity_str = {str(k): v for k, v in sample_data['item_popularity'].items()}        item_features_str = {str(k): v for k, v in sample_data['item_features'].items()}        # Convert int keys to str for JSON                sample_data = generate_sample_evaluation_data()    try:    """    Demonstrates all evaluation metrics with example data.        Generate sample evaluation with synthetic data.    """async def get_sample_evaluation():@router.get("/sample-evaluation")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "evaluation_report": report            "status": "success",        return {                )            request.total_interactions            item_popularity,            item_features,            request.k_values,            request.relevant,            request.recommended,        report = evaluator.comprehensive_evaluation(                item_popularity = {int(k): v for k, v in request.item_popularity.items()}        item_features = {int(k): v for k, v in request.item_features.items()}        # Convert string keys to int    try:    """    Returns ranking metrics, diversity, novelty, and bias measurements.        Run comprehensive evaluation with all metrics.    """async def comprehensive_evaluation(request: ComprehensiveEvalRequest):@router.post("/comprehensive")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "business_kpis": kpis            "status": "success",        return {                )            conversions_set            user_interactions,            request.recommended,        kpis = evaluator.business_kpis(                conversions_set = set(request.conversions)        user_interactions = {int(k): v for k, v in request.user_interactions.items()}        # Convert string keys to int    try:    """    Returns click-through rate and conversion metrics.        Calculate business KPIs (CTR, conversion rate).    """async def calculate_business_kpis(request: BusinessKPIRequest):@router.post("/business-kpis")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "interpretation": "Gini coefficient < 0.4 indicates fair exposure distribution"            "provider_parity": parity,            "status": "success",        return {                )            request.provider_catalog_sizes            item_providers,            request.recommended,        parity = evaluator.provider_parity(                item_providers = {int(k): v for k, v in request.item_providers.items()}        # Convert string keys to int    try:    """    Returns provider exposure analysis and Gini coefficient.        Assess fairness across content providers (e.g., event organizers).    """async def assess_provider_parity(request: ProviderParityRequest):@router.post("/provider-parity")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "interpretation": "Lower disparity indicates better fairness across groups"            "is_fair": max_disparity < 0.1,            "max_disparity": max_disparity,            "group_scores": group_scores,            "status": "success",        return {                max_disparity = max(mean_scores) - min(mean_scores) if mean_scores else 0        mean_scores = [v['mean_score'] for v in group_scores.values()]        import numpy as np        # Calculate disparity                        }                    "count": len(scores)                    "median_score": float(np.median(scores)),                    "std_score": float(np.std(scores)),                    "mean_score": float(np.mean(scores)),                group_scores[group_name] = {                import numpy as np            if scores:                            scores.append(score)                score = evaluator.ndcg_at_k(rec, rel, request.k)            for rec, rel in zip(rec_lists, relevant_lists):            scores = []                            continue            if len(rec_lists) != len(relevant_lists):                        relevant_lists = request.group_relevant.get(group_name, [])        for group_name, rec_lists in request.group_recommendations.items():                group_scores = {}        # For simplicity, we'll calculate NDCG for each group manually                    return evaluator.ndcg_at_k(rec_list, relevant_list, request.k)        def metric_func(rec_list, relevant_list):        # Create a simple metric function wrapper    try:    """    Checks if recommendation quality is similar across demographic groups.        Assess demographic parity across user groups.    """async def assess_demographic_parity(request: DemographicParityRequest):@router.post("/demographic-parity")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "interpretation": "Lower score means less bias toward popular items"            "popularity_bias": bias,            "status": "success",        return {                bias = evaluator.popularity_bias(request.recommended, item_popularity)                item_popularity = {int(k): v for k, v in request.item_popularity.items()}        # Convert string keys to int    try:    """    Measures tendency to recommend popular items.        Calculate popularity bias in recommendations.    """async def calculate_popularity_bias(request: PopularityBiasRequest):@router.post("/popularity-bias")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "interpretation": "Higher score means recommendations include more novel/less popular items"            "novelty_score": novelty,            "status": "success",        return {                )            request.total_interactions            item_popularity,            request.recommended,        novelty = evaluator.novelty_score(                item_popularity = {int(k): v for k, v in request.item_popularity.items()}        # Convert string keys to int    try:    """    Novelty rewards recommending less popular (long-tail) items.        Calculate novelty of recommendations.    """async def calculate_novelty(request: NoveltyRequest):@router.post("/novelty")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "interpretation": "Higher score means more diverse recommendations"            "diversity_score": diversity,            "status": "success",        return {                diversity = evaluator.diversity_score(request.recommended, item_features)                item_features = {int(k): v for k, v in request.item_features.items()}        # Convert string keys to int    try:    """    Measures how different the recommended items are from each other.        Calculate diversity of recommendations based on item features.    """async def calculate_diversity(request: DiversityRequest):@router.post("/diversity")        raise HTTPException(status_code=500, detail=str(e))    except Exception as e:        }            "metrics": results            "status": "success",        return {                    }                "precision": evaluator.precision_at_k(request.recommended, request.relevant, k)                "recall": evaluator.recall_at_k(request.recommended, request.relevant, k),                "map": evaluator.map_at_k(request.recommended, request.relevant, k),                "ndcg": evaluator.ndcg_at_k(request.recommended, request.relevant, k),            results[f"k={k}"] = {        for k in request.k_values:                results = {}    try:    """    Returns comprehensive ranking quality metrics.        Calculate ranking metrics (NDCG, MAP, Recall, Precision) at multiple K values.    """async def calculate_ranking_metrics(request: RankingMetricsRequest):@router.post("/ranking-metrics")    total_interactions: int    item_popularity: Dict[str, int]    item_features: Dict[str, List[str]]    k_values: List[int] = [5, 10, 20]    relevant: List[int]    recommended: List[int]class ComprehensiveEvalRequest(BaseModel):    conversions: List[int]    user_interactions: Dict[str, str]  # Changed from Dict[int, str]    recommended: List[int]class BusinessKPIRequest(BaseModel):    provider_catalog_sizes: Dict[str, int]    item_providers: Dict[str, str]  # Changed from Dict[int, str]    recommended: List[int]class ProviderParityRequest(BaseModel):    k: int = 10    group_relevant: Dict[str, List[List[int]]]    group_recommendations: Dict[str, List[List[int]]]class DemographicParityRequest(BaseModel):    item_popularity: Dict[str, int]  # Changed from Dict[int, int]    recommended: List[int]class PopularityBiasRequest(BaseModel):    total_interactions: int    item_popularity: Dict[str, int]  # Changed from Dict[int, int]    recommended: List[int]class NoveltyRequest(BaseModel):    item_features: Dict[str, List[str]]  # Changed from Dict[int, List[Any]]    recommended: List[int]class DiversityRequest(BaseModel):    k_values: List[int] = [5, 10, 20]    relevant: List[int]    recommended: List[int]class RankingMetricsRequest(BaseModel):# Request Modelsevaluator = RecommendationEvaluator()# Global instancerouter = APIRouter(prefix="/api/research/evaluation", tags=["Research - Evaluation"])from research.evaluation_metrics import RecommendationEvaluator, generate_sample_evaluation_datasys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))import osimport sysfrom typing import List, Dict, Any, Optional, Setfrom pydantic import BaseModelfrom fastapi import APIRouter, HTTPException"""Research API Routes - Evaluation & Fairness/Diversity AnalysisResearch API Routes - Model Comparison & Tuning
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import sys
import os
import numpy as np  # type: ignore

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from research.model_comparison import ModelComparator, DummyCFModel, DummyHybridModel, DummyGraphModel

router = APIRouter(prefix="/api/research/models", tags=["Research - Models"])

# Global instance
model_comparator = ModelComparator()


# Request Models
class BenchmarkRequest(BaseModel):
    train_data: List[List[float]]
    train_labels: List[float]
    test_data: List[List[float]]
    test_labels: List[float]
    models_to_test: List[str] = ["cf", "hybrid", "graph"]


class HyperparameterRequest(BaseModel):
    model_name: str
    train_data: List[List[float]]
    train_labels: List[float]
    param_grid: Dict[str, List[Any]]


class EnsembleRequest(BaseModel):
    predictions: Dict[str, List[float]]
    true_labels: List[float]
    ensemble_method: str = "average"


class SignificanceTestRequest(BaseModel):
    predictions_a: List[float]
    predictions_b: List[float]
    true_labels: List[float]
    test_type: str = "paired_ttest"


class CompareThreeModelsRequest(BaseModel):
    cf_predictions: List[float]
    hybrid_predictions: List[float]
    graph_predictions: List[float]
    true_labels: List[float]


@router.post("/benchmark")
async def benchmark_models(request: BenchmarkRequest):
    """
    Benchmark multiple recommendation models.
    
    Tests CF, Hybrid, and Graph-based models on provided data.
    Returns performance metrics and rankings.
    """
    try:
        # Convert to numpy arrays
        X_train = np.array(request.train_data)
        y_train = np.array(request.train_labels)
        X_test = np.array(request.test_data)
        y_test = np.array(request.test_labels)
        
        # Register dummy models for demonstration
        comparator = ModelComparator()
        
        if "cf" in request.models_to_test:
            comparator.register_model("Collaborative_Filtering", DummyCFModel())
        if "hybrid" in request.models_to_test:
            comparator.register_model("Hybrid", DummyHybridModel())
        if "graph" in request.models_to_test:
            comparator.register_model("Graph_Based", DummyGraphModel())
        
        # Run benchmark
        results = comparator.benchmark_models(X_train, y_train, X_test, y_test)
        
        return {
            "status": "success",
            "benchmark_results": results
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/hyperparameter-search")
async def hyperparameter_search(request: HyperparameterRequest):
    """
    Perform grid search for hyperparameter tuning.
    
    Note: Requires model with sklearn-compatible interface.
    """
    try:
        # This is a template response - requires proper model integration
        return {
            "status": "info",
            "message": "Hyperparameter search requires specific model integration",
            "template_response": {
                "model_name": request.model_name,
                "best_params": request.param_grid,
                "best_score": 0.0,
                "cv_results": {
                    "mean_test_scores": [],
                    "std_test_scores": [],
                    "params": []
                }
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/ensemble")
async def create_ensemble(request: EnsembleRequest):
    """
    Create ensemble from multiple model predictions.
    
    Supports methods: 'average', 'weighted'
    Returns ensemble performance and comparison with individual models.
    """
    try:
        # Convert to numpy
        predictions = {k: np.array(v) for k, v in request.predictions.items()}
        y_test = np.array(request.true_labels)
        
        comparator = ModelComparator()
        results = comparator.ensemble_models(predictions, y_test, request.ensemble_method)
        
        return {
            "status": "success",
            "ensemble_results": results
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/significance-test")
async def statistical_significance_test(request: SignificanceTestRequest):
    """
    Test statistical significance between two models.
    
    Performs paired t-test or Wilcoxon test to determine if performance
    difference is statistically significant.
    """
    try:
        predictions_a = np.array(request.predictions_a)
        predictions_b = np.array(request.predictions_b)
        y_test = np.array(request.true_labels)
        
        comparator = ModelComparator()
        results = comparator.statistical_significance_test(
            predictions_a, predictions_b, y_test, request.test_type
        )
        
        return {
            "status": "success",
            "significance_test": results
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/compare-cf-hybrid-graph")
async def compare_three_models(request: CompareThreeModelsRequest):
    """
    Comprehensive comparison of CF vs Hybrid vs Graph-based recommenders.
    
    Includes performance metrics and statistical significance tests.
    """
    try:
        cf_preds = np.array(request.cf_predictions)
        hybrid_preds = np.array(request.hybrid_predictions)
        graph_preds = np.array(request.graph_predictions)
        y_test = np.array(request.true_labels)
        
        comparator = ModelComparator()
        results = comparator.compare_cf_hybrid_graph(cf_preds, hybrid_preds, graph_preds, y_test)
        
        return {
            "status": "success",
            "comparison": results
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/registered-models")
async def get_registered_models():
    """
    List all registered models and their configurations.
    """
    return {
        "status": "success",
        "available_models": [
            {
                "name": "Collaborative Filtering",
                "key": "cf",
                "description": "User-item collaborative filtering using matrix factorization"
            },
            {
                "name": "Hybrid",
                "key": "hybrid",
                "description": "Combines collaborative filtering with content-based features"
            },
            {
                "name": "Graph-Based",
                "key": "graph",
                "description": "Graph neural network approach for recommendations"
            }
        ]
    }


@router.get("/sample-comparison")
async def get_sample_comparison():
    """
    Generate sample model comparison with synthetic data.
    """
    try:
        np.random.seed(42)
        
        # Generate synthetic predictions
        n_samples = 100
        y_true = np.random.uniform(1, 5, n_samples)
        
        cf_preds = y_true + np.random.normal(0, 1, n_samples)
        hybrid_preds = y_true + np.random.normal(0, 0.8, n_samples)
        graph_preds = y_true + np.random.normal(0, 1.2, n_samples)
        
        comparator = ModelComparator()
        results = comparator.compare_cf_hybrid_graph(cf_preds, hybrid_preds, graph_preds, y_true)
        
        return {
            "status": "success",
            "note": "Sample comparison with synthetic data",
            "comparison": results
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/tuning-recommendations")
async def get_tuning_recommendations():
    """
    Get recommendations for hyperparameter tuning ranges.
    """
    return {
        "status": "success",
        "tuning_guides": {
            "collaborative_filtering": {
                "n_factors": [10, 20, 50, 100],
                "learning_rate": [0.001, 0.01, 0.1],
                "regularization": [0.01, 0.1, 1.0]
            },
            "hybrid": {
                "cf_weight": [0.3, 0.5, 0.7],
                "content_weight": [0.3, 0.5, 0.7],
                "n_factors": [20, 50, 100]
            },
            "graph_based": {
                "n_layers": [2, 3, 4],
                "hidden_dim": [32, 64, 128],
                "dropout": [0.1, 0.3, 0.5]
            }
        }
    }
