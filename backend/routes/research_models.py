"""
Research API Routes - Model Comparison & Tuning
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
    Run comprehensive benchmark comparing multiple recommendation models.
    
    Tests:
    - Collaborative Filtering (CF)
    - Hybrid (CF + Content)
    - Graph-based
    
    Returns MAE, RMSE, training time, prediction time for each model.
    """
    try:
        results = model_comparator.benchmark_models(
            train_data=np.array(request.train_data),
            train_labels=np.array(request.train_labels),
            test_data=np.array(request.test_data),
            test_labels=np.array(request.test_labels),
            models_to_test=request.models_to_test
        )
        
        # Convert numpy types to Python types for JSON serialization
        serializable_results = {}
        for model_name, metrics in results.items():
            serializable_results[model_name] = {
                k: float(v) if isinstance(v, (np.floating, np.integer)) else v
                for k, v in metrics.items()
            }
        
        return {
            "status": "success",
            "benchmark_results": serializable_results,
            "models_tested": request.models_to_test,
            "test_samples": len(request.test_labels)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/hyperparameter-search")
async def hyperparameter_tuning(request: HyperparameterRequest):
    """
    Perform grid search hyperparameter tuning on a specified model.
    
    Returns:
    - Best parameters found
    - Best cross-validation score
    - All parameter combinations tested
    """
    try:
        best_params, best_score, all_results = model_comparator.hyperparameter_tuning(
            model_name=request.model_name,
            train_data=np.array(request.train_data),
            train_labels=np.array(request.train_labels),
            param_grid=request.param_grid
        )
        
        return {
            "status": "success",
            "model_name": request.model_name,
            "best_parameters": best_params,
            "best_cv_score": float(best_score),
            "all_results": [
                {
                    "params": r["params"],
                    "mean_score": float(r["mean_test_score"]),
                    "std_score": float(r["std_test_score"])
                }
                for r in all_results
            ],
            "total_combinations_tested": len(all_results)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/ensemble")
async def ensemble_predictions(request: EnsembleRequest):
    """
    Combine predictions from multiple models using ensemble methods.
    
    Methods:
    - average: Simple averaging
    - weighted: Weighted averaging based on model performance
    - voting: Majority voting (for classification)
    """
    try:
        predictions_dict = {
            k: np.array(v) for k, v in request.predictions.items()
        }
        
        ensemble_pred, weights = model_comparator.ensemble_models(
            predictions=predictions_dict,
            true_labels=np.array(request.true_labels),
            method=request.ensemble_method
        )
        
        # Convert to Python types
        ensemble_pred_list = [float(p) for p in ensemble_pred]
        weights_dict = {k: float(v) for k, v in weights.items()} if weights else None
        
        return {
            "status": "success",
            "ensemble_method": request.ensemble_method,
            "ensemble_predictions": ensemble_pred_list,
            "weights": weights_dict,
            "prediction_count": len(ensemble_pred_list)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/significance-test")
async def statistical_significance_test(request: SignificanceTestRequest):
    """
    Perform statistical significance test between two models.
    
    Tests:
    - paired_ttest: Paired t-test
    - wilcoxon: Wilcoxon signed-rank test
    """
    try:
        is_significant, p_value, test_stat = model_comparator.statistical_significance_test(
            predictions_a=np.array(request.predictions_a),
            predictions_b=np.array(request.predictions_b),
            true_labels=np.array(request.true_labels),
            test_type=request.test_type
        )
        
        return {
            "status": "success",
            "test_type": request.test_type,
            "is_significant": bool(is_significant),
            "p_value": float(p_value),
            "test_statistic": float(test_stat),
            "interpretation": "Models perform significantly differently" if is_significant else "No significant difference between models",
            "confidence_level": 0.95
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/compare-cf-hybrid-graph")
async def compare_three_models(request: CompareThreeModelsRequest):
    """
    Comprehensive comparison of CF, Hybrid, and Graph-based models.
    
    Includes:
    - Performance metrics for each
    - Statistical significance tests
    - Ranking and recommendations
    """
    try:
        cf_pred = np.array(request.cf_predictions)
        hybrid_pred = np.array(request.hybrid_predictions)
        graph_pred = np.array(request.graph_predictions)
        true_labels = np.array(request.true_labels)
        
        # Calculate errors for each model
        from sklearn.metrics import mean_absolute_error, mean_squared_error
        
        results = {
            "cf": {
                "mae": float(mean_absolute_error(true_labels, cf_pred)),
                "rmse": float(np.sqrt(mean_squared_error(true_labels, cf_pred)))
            },
            "hybrid": {
                "mae": float(mean_absolute_error(true_labels, hybrid_pred)),
                "rmse": float(np.sqrt(mean_squared_error(true_labels, hybrid_pred)))
            },
            "graph": {
                "mae": float(mean_absolute_error(true_labels, graph_pred)),
                "rmse": float(np.sqrt(mean_squared_error(true_labels, graph_pred)))
            }
        }
        
        # Rank by MAE
        ranked = sorted(results.items(), key=lambda x: x[1]["mae"])
        
        # Statistical tests
        cf_vs_hybrid = model_comparator.statistical_significance_test(cf_pred, hybrid_pred, true_labels)
        cf_vs_graph = model_comparator.statistical_significance_test(cf_pred, graph_pred, true_labels)
        hybrid_vs_graph = model_comparator.statistical_significance_test(hybrid_pred, graph_pred, true_labels)
        
        return {
            "status": "success",
            "performance_metrics": results,
            "ranking": [{"rank": i+1, "model": name, "mae": metrics["mae"]} for i, (name, metrics) in enumerate(ranked)],
            "statistical_tests": {
                "cf_vs_hybrid": {"is_significant": bool(cf_vs_hybrid[0]), "p_value": float(cf_vs_hybrid[1])},
                "cf_vs_graph": {"is_significant": bool(cf_vs_graph[0]), "p_value": float(cf_vs_graph[1])},
                "hybrid_vs_graph": {"is_significant": bool(hybrid_vs_graph[0]), "p_value": float(hybrid_vs_graph[1])}
            },
            "recommendation": f"Best model: {ranked[0][0]} (MAE: {ranked[0][1]['mae']:.4f})"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/registered-models")
async def get_registered_models():
    """
    Get list of all available models for benchmarking.
    """
    return {
        "status": "success",
        "available_models": ["cf", "hybrid", "graph"],
        "model_descriptions": {
            "cf": "Collaborative Filtering - User-item interaction matrix",
            "hybrid": "Hybrid Model - Combines CF with content features",
            "graph": "Graph-based - Uses network structure and relationships"
        }
    }


@router.get("/sample-comparison")
async def get_sample_comparison_data():
    """
    Generate sample data for model comparison testing.
    """
    try:
        sample_data = generate_sample_model_data()
        return {
            "status": "success",
            "data": sample_data
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/tuning-recommendations")
async def get_tuning_recommendations():
    """
    Get recommended hyperparameter ranges for different models.
    """
    return {
        "status": "success",
        "recommendations": {
            "cf": {
                "n_factors": [10, 20, 50, 100],
                "learning_rate": [0.001, 0.01, 0.1],
                "regularization": [0.001, 0.01, 0.1]
            },
            "hybrid": {
                "cf_weight": [0.3, 0.5, 0.7],
                "content_weight": [0.3, 0.5, 0.7],
                "n_factors": [10, 20, 50]
            },
            "graph": {
                "num_walks": [10, 20, 50],
                "walk_length": [5, 10, 20],
                "embedding_dim": [32, 64, 128]
            }
        }
    }


# Helper Functions
def generate_sample_model_data():
    """Generate sample data for model comparison"""
    np.random.seed(42)
    n_samples = 100
    n_features = 10
    
    # Generate synthetic train/test data
    X_train = np.random.randn(n_samples, n_features)
    y_train = np.random.randn(n_samples) * 0.5 + np.mean(X_train, axis=1)
    
    X_test = np.random.randn(n_samples // 4, n_features)
    y_test = np.random.randn(n_samples // 4) * 0.5 + np.mean(X_test, axis=1)
    
    # Generate sample predictions
    cf_pred = y_test + np.random.randn(len(y_test)) * 0.3
    hybrid_pred = y_test + np.random.randn(len(y_test)) * 0.2
    graph_pred = y_test + np.random.randn(len(y_test)) * 0.25
    
    return {
        "train_data": X_train.tolist(),
        "train_labels": y_train.tolist(),
        "test_data": X_test.tolist(),
        "test_labels": y_test.tolist(),
        "sample_predictions": {
            "cf": cf_pred.tolist(),
            "hybrid": hybrid_pred.tolist(),
            "graph": graph_pred.tolist()
        }
    }

