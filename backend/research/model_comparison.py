"""
Model Comparison & Tuning Module
Benchmarks CF vs hybrid vs graph-based recommenders.
Performs hyperparameter search and ensemble trials.
Documents wins with statistical significance tests.
"""

from typing import Dict, Any, List, Optional, Tuple, Callable
import numpy as np  # type: ignore
import pandas as pd  # type: ignore
from sklearn.model_selection import train_test_split, GridSearchCV  # type: ignore
from sklearn.metrics import mean_squared_error, mean_absolute_error  # type: ignore
from scipy import stats  # type: ignore
import json
import time


class ModelComparator:
    """Compares different recommendation models and tunes hyperparameters."""
    
    def __init__(self):
        self.models = {}
        self.results = {}
        self.best_params = {}
        
    def register_model(self, name: str, model_instance: Any, param_grid: Optional[Dict] = None):
        """
        Register a model for comparison.
        
        Args:
            name: Model identifier
            model_instance: Model object with fit/predict methods
            param_grid: Hyperparameter grid for tuning
        """
        self.models[name] = {
            "instance": model_instance,
            "param_grid": param_grid or {}
        }
    
    def benchmark_models(
        self,
        X_train: Any,
        y_train: Any,
        X_test: Any,
        y_test: Any,
        metrics: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        Benchmark all registered models.
        
        Args:
            X_train, y_train: Training data
            X_test, y_test: Test data
            metrics: List of metric names to compute
            
        Returns:
            Benchmark results for all models
        """
        if metrics is None:
            metrics = ['mse', 'mae', 'rmse']
        
        benchmark_results = {}
        
        for model_name, model_info in self.models.items():
            print(f"Benchmarking {model_name}...")
            
            model = model_info['instance']
            
            # Training
            start_time = time.time()
            model.fit(X_train, y_train)
            train_time = time.time() - start_time
            
            # Prediction
            start_time = time.time()
            y_pred = model.predict(X_test)
            predict_time = time.time() - start_time
            
            # Calculate metrics
            result = {
                "train_time_seconds": train_time,
                "predict_time_seconds": predict_time,
            }
            
            if 'mse' in metrics:
                result['mse'] = mean_squared_error(y_test, y_pred)
            if 'mae' in metrics:
                result['mae'] = mean_absolute_error(y_test, y_pred)
            if 'rmse' in metrics:
                result['rmse'] = np.sqrt(mean_squared_error(y_test, y_pred))
            
            benchmark_results[model_name] = result
        
        # Rank models by RMSE
        ranked = sorted(benchmark_results.items(), key=lambda x: x[1].get('rmse', float('inf')))
        benchmark_results['ranking'] = [{"model": name, "rmse": info['rmse']} for name, info in ranked]
        
        self.results = benchmark_results
        return benchmark_results
    
    def hyperparameter_search(
        self,
        model_name: str,
        X_train: Any,
        y_train: Any,
        cv: int = 5,
        scoring: str = 'neg_mean_squared_error'
    ) -> Dict[str, Any]:
        """
        Perform grid search for hyperparameter tuning.
        
        Args:
            model_name: Name of registered model
            X_train, y_train: Training data
            cv: Cross-validation folds
            scoring: Scoring metric
            
        Returns:
            Best parameters and cross-validation results
        """
        if model_name not in self.models:
            return {"error": f"Model {model_name} not registered"}
        
        model_info = self.models[model_name]
        param_grid = model_info['param_grid']
        
        if not param_grid:
            return {"error": f"No parameter grid defined for {model_name}"}
        
        model = model_info['instance']
        
        # Grid search
        grid_search = GridSearchCV(
            estimator=model,
            param_grid=param_grid,
            cv=cv,
            scoring=scoring,
            n_jobs=-1,
            verbose=1
        )
        
        grid_search.fit(X_train, y_train)
        
        results = {
            "model_name": model_name,
            "best_params": grid_search.best_params_,
            "best_score": -grid_search.best_score_,  # Negate because we use neg_mse
            "cv_results": {
                "mean_test_scores": grid_search.cv_results_['mean_test_score'].tolist(),
                "std_test_scores": grid_search.cv_results_['std_test_score'].tolist(),
                "params": [str(p) for p in grid_search.cv_results_['params']]
            }
        }
        
        self.best_params[model_name] = grid_search.best_params_
        return results
    
    def ensemble_models(
        self,
        model_predictions: Dict[str, np.ndarray],
        y_test: np.ndarray,
        ensemble_method: str = 'average'
    ) -> Dict[str, Any]:
        """
        Create ensemble from multiple model predictions.
        
        Args:
            model_predictions: Dict of {model_name: predictions_array}
            y_test: True labels
            ensemble_method: 'average', 'weighted', or 'stacking'
            
        Returns:
            Ensemble results and performance
        """
        predictions = list(model_predictions.values())
        model_names = list(model_predictions.keys())
        
        if ensemble_method == 'average':
            # Simple average
            ensemble_pred = np.mean(predictions, axis=0)
            
        elif ensemble_method == 'weighted':
            # Weight by inverse RMSE
            weights = []
            for pred in predictions:
                rmse = np.sqrt(mean_squared_error(y_test, pred))
                weights.append(1.0 / (rmse + 1e-6))
            
            weights = np.array(weights) / np.sum(weights)
            ensemble_pred = np.average(predictions, axis=0, weights=weights)
            
        else:
            # Default to average
            ensemble_pred = np.mean(predictions, axis=0)
        
        # Evaluate ensemble
        ensemble_mse = mean_squared_error(y_test, ensemble_pred)
        ensemble_mae = mean_absolute_error(y_test, ensemble_pred)
        ensemble_rmse = np.sqrt(ensemble_mse)
        
        # Compare to individual models
        individual_scores = {}
        for name, pred in model_predictions.items():
            individual_scores[name] = {
                "mse": mean_squared_error(y_test, pred),
                "rmse": np.sqrt(mean_squared_error(y_test, pred))
            }
        
        return {
            "ensemble_method": ensemble_method,
            "ensemble_metrics": {
                "mse": ensemble_mse,
                "mae": ensemble_mae,
                "rmse": ensemble_rmse
            },
            "individual_models": individual_scores,
            "improvement_over_best": {
                "best_individual_rmse": min([s['rmse'] for s in individual_scores.values()]),
                "ensemble_rmse": ensemble_rmse,
                "improvement": min([s['rmse'] for s in individual_scores.values()]) - ensemble_rmse
            }
        }
    
    def statistical_significance_test(
        self,
        predictions_A: np.ndarray,
        predictions_B: np.ndarray,
        y_test: np.ndarray,
        test_type: str = 'paired_ttest'
    ) -> Dict[str, Any]:
        """
        Test statistical significance between two models.
        
        Args:
            predictions_A: Predictions from model A
            predictions_B: Predictions from model B
            y_test: True labels
            test_type: Type of test ('paired_ttest', 'wilcoxon')
            
        Returns:
            Statistical test results
        """
        # Calculate errors for each model
        errors_A = np.abs(predictions_A - y_test)
        errors_B = np.abs(predictions_B - y_test)
        
        if test_type == 'paired_ttest':
            # Paired t-test
            statistic, p_value = stats.ttest_rel(errors_A, errors_B)
            test_name = "Paired T-Test"
            
        elif test_type == 'wilcoxon':
            # Wilcoxon signed-rank test (non-parametric)
            statistic, p_value = stats.wilcoxon(errors_A, errors_B)
            test_name = "Wilcoxon Signed-Rank Test"
            
        else:
            return {"error": f"Unknown test type: {test_type}"}
        
        # Determine significance
        significance_level = 0.05
        is_significant = p_value < significance_level
        
        # Calculate effect size (Cohen's d)
        mean_diff = np.mean(errors_A - errors_B)
        pooled_std = np.sqrt((np.var(errors_A) + np.var(errors_B)) / 2)
        cohens_d = mean_diff / pooled_std if pooled_std > 0 else 0
        
        return {
            "test_name": test_name,
            "statistic": float(statistic),
            "p_value": float(p_value),
            "is_significant": is_significant,
            "significance_level": significance_level,
            "cohens_d": float(cohens_d),
            "interpretation": self._interpret_significance(p_value, cohens_d),
            "model_A_mean_error": float(np.mean(errors_A)),
            "model_B_mean_error": float(np.mean(errors_B))
        }
    
    def _interpret_significance(self, p_value: float, cohens_d: float) -> str:
        """Interpret statistical significance results."""
        if p_value >= 0.05:
            return "No statistically significant difference between models"
        
        effect_size = "small" if abs(cohens_d) < 0.5 else "medium" if abs(cohens_d) < 0.8 else "large"
        
        if cohens_d > 0:
            return f"Model A significantly worse than Model B (p={p_value:.4f}, {effect_size} effect)"
        else:
            return f"Model A significantly better than Model B (p={p_value:.4f}, {effect_size} effect)"
    
    def compare_cf_hybrid_graph(
        self,
        cf_predictions: np.ndarray,
        hybrid_predictions: np.ndarray,
        graph_predictions: np.ndarray,
        y_test: np.ndarray
    ) -> Dict[str, Any]:
        """
        Specific comparison for CF vs Hybrid vs Graph-based recommenders.
        
        Args:
            cf_predictions: Collaborative filtering predictions
            hybrid_predictions: Hybrid model predictions
            graph_predictions: Graph-based model predictions
            y_test: True labels
            
        Returns:
            Comprehensive comparison results
        """
        models = {
            "Collaborative_Filtering": cf_predictions,
            "Hybrid": hybrid_predictions,
            "Graph_Based": graph_predictions
        }
        
        results = {}
        
        # Calculate metrics for each
        for name, preds in models.items():
            results[name] = {
                "mse": mean_squared_error(y_test, preds),
                "mae": mean_absolute_error(y_test, preds),
                "rmse": np.sqrt(mean_squared_error(y_test, preds))
            }
        
        # Pairwise significance tests
        comparisons = {}
        
        # CF vs Hybrid
        comparisons['CF_vs_Hybrid'] = self.statistical_significance_test(
            cf_predictions, hybrid_predictions, y_test
        )
        
        # CF vs Graph
        comparisons['CF_vs_Graph'] = self.statistical_significance_test(
            cf_predictions, graph_predictions, y_test
        )
        
        # Hybrid vs Graph
        comparisons['Hybrid_vs_Graph'] = self.statistical_significance_test(
            hybrid_predictions, graph_predictions, y_test
        )
        
        # Find best model
        best_model = min(results.items(), key=lambda x: x[1]['rmse'])
        
        return {
            "model_metrics": results,
            "pairwise_comparisons": comparisons,
            "best_model": {
                "name": best_model[0],
                "metrics": best_model[1]
            },
            "ranking": sorted(results.items(), key=lambda x: x[1]['rmse'])
        }


# Example: Dummy model classes for testing
class DummyCFModel:
    """Dummy collaborative filtering model."""
    def fit(self, X, y):
        self.mean = np.mean(y)
        return self
    
    def predict(self, X):
        return np.full(len(X), self.mean) + np.random.normal(0, 1, len(X))


class DummyHybridModel:
    """Dummy hybrid model."""
    def fit(self, X, y):
        self.mean = np.mean(y)
        return self
    
    def predict(self, X):
        return np.full(len(X), self.mean) + np.random.normal(0, 0.8, len(X))


class DummyGraphModel:
    """Dummy graph-based model."""
    def fit(self, X, y):
        self.mean = np.mean(y)
        return self
    
    def predict(self, X):
        return np.full(len(X), self.mean) + np.random.normal(0, 1.2, len(X))
