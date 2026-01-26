"""
Evaluation & Fairness/Diversity Analysis Module
Tracks NDCG/MAP/Recall@K, plus diversity, novelty, and popularity-bias metrics.
Assesses demographic/provider parity and business KPIs (CTR, conversion).
"""

from typing import Dict, Any, List, Optional, Set, Tuple
import numpy as np  # type: ignore
import pandas as pd  # type: ignore
from collections import defaultdict, Counter
import math


class RecommendationEvaluator:
    """Comprehensive evaluation metrics for recommendation systems."""
    
    def __init__(self):
        self.metrics_history = []
        
    def ndcg_at_k(self, recommended: List[int], relevant: List[int], k: int) -> float:
        """
        Calculate Normalized Discounted Cumulative Gain at K.
        
        Args:
            recommended: List of recommended item IDs (ordered)
            relevant: List of relevant item IDs
            k: Cutoff position
            
        Returns:
            NDCG@K score
        """
        recommended_k = recommended[:k]
        relevant_set = set(relevant)
        
        # DCG calculation
        dcg = 0.0
        for i, item_id in enumerate(recommended_k):
            if item_id in relevant_set:
                # Relevance is 1 if relevant, 0 otherwise
                rel = 1
                dcg += rel / math.log2(i + 2)  # i+2 because i is 0-indexed
        
        # IDCG calculation (ideal DCG)
        ideal_relevance = [1] * min(len(relevant), k)
        idcg = sum([rel / math.log2(i + 2) for i, rel in enumerate(ideal_relevance)])
        
        if idcg == 0:
            return 0.0
        
        return dcg / idcg
    
    def map_at_k(self, recommended: List[int], relevant: List[int], k: int) -> float:
        """
        Calculate Mean Average Precision at K.
        
        Args:
            recommended: List of recommended item IDs (ordered)
            relevant: List of relevant item IDs
            k: Cutoff position
            
        Returns:
            MAP@K score
        """
        recommended_k = recommended[:k]
        relevant_set = set(relevant)
        
        if not relevant_set:
            return 0.0
        
        score = 0.0
        num_hits = 0
        
        for i, item_id in enumerate(recommended_k):
            if item_id in relevant_set:
                num_hits += 1
                precision_at_i = num_hits / (i + 1)
                score += precision_at_i
        
        return score / min(len(relevant), k)
    
    def recall_at_k(self, recommended: List[int], relevant: List[int], k: int) -> float:
        """
        Calculate Recall at K.
        
        Args:
            recommended: List of recommended item IDs (ordered)
            relevant: List of relevant item IDs
            k: Cutoff position
            
        Returns:
            Recall@K score
        """
        if not relevant:
            return 0.0
        
        recommended_k = set(recommended[:k])
        relevant_set = set(relevant)
        
        hits = len(recommended_k & relevant_set)
        return hits / len(relevant_set)
    
    def precision_at_k(self, recommended: List[int], relevant: List[int], k: int) -> float:
        """
        Calculate Precision at K.
        
        Args:
            recommended: List of recommended item IDs (ordered)
            relevant: List of relevant item IDs
            k: Cutoff position
            
        Returns:
            Precision@K score
        """
        if k == 0:
            return 0.0
        
        recommended_k = set(recommended[:k])
        relevant_set = set(relevant)
        
        hits = len(recommended_k & relevant_set)
        return hits / k
    
    def diversity_score(self, recommended: List[int], item_features: Dict[int, List[Any]]) -> float:
        """
        Calculate diversity of recommendations based on item features.
        
        Measures how different the recommended items are from each other.
        
        Args:
            recommended: List of recommended item IDs
            item_features: Dict mapping item_id to feature list
            
        Returns:
            Diversity score (higher = more diverse)
        """
        if len(recommended) < 2:
            return 0.0
        
        # Calculate pairwise dissimilarity
        dissimilarities = []
        
        for i in range(len(recommended)):
            for j in range(i + 1, len(recommended)):
                item_i = recommended[i]
                item_j = recommended[j]
                
                if item_i not in item_features or item_j not in item_features:
                    continue
                
                # Jaccard distance for categorical features
                features_i = set(item_features[item_i])
                features_j = set(item_features[item_j])
                
                if len(features_i | features_j) == 0:
                    dissimilarity = 0
                else:
                    dissimilarity = 1 - (len(features_i & features_j) / len(features_i | features_j))
                
                dissimilarities.append(dissimilarity)
        
        if not dissimilarities:
            return 0.0
        
        return np.mean(dissimilarities)
    
    def novelty_score(
        self,
        recommended: List[int],
        item_popularity: Dict[int, int],
        total_interactions: int
    ) -> float:
        """
        Calculate novelty of recommendations.
        
        Novelty rewards recommending less popular (long-tail) items.
        
        Args:
            recommended: List of recommended item IDs
            item_popularity: Dict mapping item_id to interaction count
            total_interactions: Total number of interactions in the system
            
        Returns:
            Novelty score (higher = more novel/less popular items)
        """
        if not recommended or total_interactions == 0:
            return 0.0
        
        novelty_scores = []
        
        for item_id in recommended:
            popularity = item_popularity.get(item_id, 0)
            probability = popularity / total_interactions
            
            if probability > 0:
                # Self-information: -log2(p)
                novelty = -math.log2(probability)
            else:
                novelty = math.log2(total_interactions)  # Maximum novelty for unseen items
            
            novelty_scores.append(novelty)
        
        return np.mean(novelty_scores)
    
    def popularity_bias(
        self,
        recommended: List[int],
        item_popularity: Dict[int, int]
    ) -> float:
        """
        Calculate popularity bias in recommendations.
        
        Measures tendency to recommend popular items.
        
        Args:
            recommended: List of recommended item IDs
            item_popularity: Dict mapping item_id to interaction count
            
        Returns:
            Average popularity rank (lower = less biased toward popular items)
        """
        if not recommended:
            return 0.0
        
        # Sort items by popularity
        sorted_items = sorted(item_popularity.items(), key=lambda x: x[1], reverse=True)
        item_rank = {item_id: rank for rank, (item_id, _) in enumerate(sorted_items)}
        
        # Calculate average rank of recommended items
        ranks = [item_rank.get(item_id, len(item_rank)) for item_id in recommended]
        
        return np.mean(ranks)
    
    def demographic_parity(
        self,
        recommendations_by_group: Dict[str, List[List[int]]],
        metric_func: callable,
        **metric_kwargs
    ) -> Dict[str, Any]:
        """
        Assess demographic parity across user groups.
        
        Checks if recommendation quality is similar across demographic groups.
        
        Args:
            recommendations_by_group: Dict of {group_name: list_of_recommendation_lists}
            metric_func: Metric function to evaluate (e.g., ndcg_at_k)
            **metric_kwargs: Additional arguments for metric function
            
        Returns:
            Parity analysis across groups
        """
        group_scores = {}
        
        for group_name, rec_lists in recommendations_by_group.items():
            scores = [metric_func(rec, **metric_kwargs) for rec in rec_lists]
            group_scores[group_name] = {
                "mean_score": np.mean(scores),
                "std_score": np.std(scores),
                "median_score": np.median(scores),
                "count": len(scores)
            }
        
        # Calculate disparity
        mean_scores = [v['mean_score'] for v in group_scores.values()]
        max_disparity = max(mean_scores) - min(mean_scores) if mean_scores else 0
        
        return {
            "group_scores": group_scores,
            "max_disparity": max_disparity,
            "coefficient_of_variation": np.std(mean_scores) / np.mean(mean_scores) if np.mean(mean_scores) > 0 else 0,
            "is_fair": max_disparity < 0.1  # Threshold for fairness
        }
    
    def provider_parity(
        self,
        recommendations: List[int],
        item_providers: Dict[int, str],
        provider_catalog_sizes: Dict[str, int]
    ) -> Dict[str, Any]:
        """
        Assess fairness across content providers (e.g., event organizers).
        
        Args:
            recommendations: List of recommended item IDs
            item_providers: Dict mapping item_id to provider_id
            provider_catalog_sizes: Dict mapping provider_id to catalog size
            
        Returns:
            Provider exposure analysis
        """
        provider_counts = Counter([item_providers.get(item_id) for item_id in recommendations if item_id in item_providers])
        
        provider_exposure = {}
        for provider_id, catalog_size in provider_catalog_sizes.items():
            recommended_count = provider_counts.get(provider_id, 0)
            exposure_rate = recommended_count / len(recommendations) if recommendations else 0
            catalog_share = catalog_size / sum(provider_catalog_sizes.values())
            
            provider_exposure[provider_id] = {
                "recommended_count": recommended_count,
                "exposure_rate": exposure_rate,
                "catalog_size": catalog_size,
                "catalog_share": catalog_share,
                "exposure_vs_catalog": exposure_rate / catalog_share if catalog_share > 0 else 0
            }
        
        # Calculate Gini coefficient for exposure inequality
        exposure_rates = [v['exposure_rate'] for v in provider_exposure.values()]
        gini = self._gini_coefficient(exposure_rates)
        
        return {
            "provider_exposure": provider_exposure,
            "gini_coefficient": gini,
            "is_fair": gini < 0.4  # Threshold for fairness
        }
    
    def _gini_coefficient(self, values: List[float]) -> float:
        """Calculate Gini coefficient for inequality measurement."""
        if not values or all(v == 0 for v in values):
            return 0.0
        
        sorted_values = sorted(values)
        n = len(sorted_values)
        cumsum = np.cumsum(sorted_values)
        
        return (2 * sum((i + 1) * val for i, val in enumerate(sorted_values))) / (n * sum(sorted_values)) - (n + 1) / n
    
    def business_kpis(
        self,
        recommendations: List[int],
        user_interactions: Dict[int, str],
        conversions: Set[int]
    ) -> Dict[str, float]:
        """
        Calculate business KPIs (CTR, conversion rate).
        
        Args:
            recommendations: List of recommended item IDs
            user_interactions: Dict of {item_id: interaction_type} (e.g., 'click', 'view')
            conversions: Set of item IDs that led to conversions (bookings)
            
        Returns:
            Business metrics
        """
        total_recommendations = len(recommendations)
        
        if total_recommendations == 0:
            return {"ctr": 0.0, "conversion_rate": 0.0, "clicks": 0, "conversions": 0}
        
        # Count clicks
        clicks = sum(1 for item_id in recommendations if user_interactions.get(item_id) in ['click', 'view'])
        
        # Count conversions
        conversion_count = sum(1 for item_id in recommendations if item_id in conversions)
        
        ctr = clicks / total_recommendations
        conversion_rate = conversion_count / total_recommendations
        
        return {
            "total_recommendations": total_recommendations,
            "clicks": clicks,
            "conversions": conversion_count,
            "ctr": ctr,
            "conversion_rate": conversion_rate,
            "click_to_conversion": conversion_count / clicks if clicks > 0 else 0
        }
    
    def comprehensive_evaluation(
        self,
        recommended: List[int],
        relevant: List[int],
        k_values: List[int],
        item_features: Dict[int, List[Any]],
        item_popularity: Dict[int, int],
        total_interactions: int
    ) -> Dict[str, Any]:
        """
        Run comprehensive evaluation with all metrics.
        
        Args:
            recommended: List of recommended item IDs
            relevant: List of relevant item IDs
            k_values: List of K values to evaluate
            item_features: Item feature dictionary
            item_popularity: Item popularity counts
            total_interactions: Total interaction count
            
        Returns:
            Complete evaluation report
        """
        report = {
            "ranking_metrics": {},
            "diversity_novelty": {},
            "timestamp": pd.Timestamp.now().isoformat()
        }
        
        # Ranking metrics at different K
        for k in k_values:
            report["ranking_metrics"][f"k={k}"] = {
                "ndcg": self.ndcg_at_k(recommended, relevant, k),
                "map": self.map_at_k(recommended, relevant, k),
                "recall": self.recall_at_k(recommended, relevant, k),
                "precision": self.precision_at_k(recommended, relevant, k)
            }
        
        # Diversity and novelty
        report["diversity_novelty"] = {
            "diversity": self.diversity_score(recommended, item_features),
            "novelty": self.novelty_score(recommended, item_popularity, total_interactions),
            "popularity_bias": self.popularity_bias(recommended, item_popularity)
        }
        
        self.metrics_history.append(report)
        return report


# Example usage
def generate_sample_evaluation_data() -> Dict[str, Any]:
    """Generate sample data for evaluation testing."""
    np.random.seed(42)
    
    # Sample recommendations and relevance
    recommended = list(range(1, 21))  # Top 20 recommended items
    relevant = [2, 5, 7, 12, 15, 18]  # Truly relevant items
    
    # Item features (categories)
    item_features = {
        i: [f"category_{np.random.randint(1, 6)}", f"tag_{np.random.randint(1, 10)}"]
        for i in range(1, 51)
    }
    
    # Item popularity
    item_popularity = {i: np.random.randint(10, 1000) for i in range(1, 51)}
    
    total_interactions = sum(item_popularity.values())
    
    return {
        "recommended": recommended,
        "relevant": relevant,
        "item_features": item_features,
        "item_popularity": item_popularity,
        "total_interactions": total_interactions,
        "k_values": [5, 10, 20]
    }
