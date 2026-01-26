import 'package:flutter/material.dart';
import 'screens/home/modern_home_screen.dart';
import 'screens/research/research_dashboard_screen.dart';
import 'screens/research/behavior_analysis_screen.dart';
import 'screens/research/feature_engineering_screen.dart';
import 'screens/research/model_comparison_screen.dart';
import 'screens/research/evaluation_dashboard_screen.dart';
import 'core/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Festio LK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ModernHomeScreen(),
      routes: {
        AppRoutes.researchDashboard: (context) => const ResearchDashboardScreen(),
        AppRoutes.researchBehavior: (context) => const BehaviorAnalysisScreen(),
        AppRoutes.researchFeatures: (context) => const FeatureEngineeringScreen(),
        AppRoutes.researchModels: (context) => const ModelComparisonScreen(),
        AppRoutes.researchEvaluation: (context) => const EvaluationDashboardScreen(),
      },
    );
  }
}
