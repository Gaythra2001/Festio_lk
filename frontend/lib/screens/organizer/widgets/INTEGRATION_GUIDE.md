/// AI Revenue Optimizer Integration Example for Organizer Dashboard
/// This file demonstrates how to integrate the AI Revenue Optimizer Card into your dashboard
/// 
/// To integrate into your dashboard:
/// 1. Add this import at the top of your dashboard file:
///    import 'widgets/ai_revenue_optimizer_card.dart';
/// 
/// 2. Add the widget to your dashboard in the build method or in a scrollable list:
/// 
/// Example usage in a Column/ListView:
/// 
/// AIRevenueOptimizerCard(
///   eventId: _selectedEventId,
///   eventCategory: _eventCategory,
///   daysBeforeEvent: _daysUntilEvent.toInt(),
///   venueCapacity: _venueCapacity,
///   currentPrice: _currentPrice,
///   apiBaseUrl: 'http://localhost:8000', // or your actual API URL
///   onPriceUpdated: (newPrice) {
///     setState(() {
///       _currentPrice = newPrice;
///       // Optionally refresh analytics here
///       _loadAnalytics();
///     });
///   },
/// ),
/// 
/// Integration Points:
/// 
/// 1. In the Widget Tree:
///    Add the AIRevenueOptimizerCard to your dashboard's main Column/ListView
///    This is typically after your existing analytics cards
/// 
/// 2. Data Parameters:
///    - eventId: String - The unique event identifier
///    - eventCategory: String - Event category (e.g., 'Festival', 'Concert', 'Workshop')
///    - daysBeforeEvent: int - Days remaining until event (0-365)
///    - venueCapacity: int - Total venue capacity
///    - currentPrice: double - Current ticket price in LKR
///    - apiBaseUrl: String - API server base URL (optional, defaults to 'http://localhost:8000')
/// 
/// 3. Callbacks:
///    - onPriceUpdated: Function(double) - Called when user applies AI recommendation
///      Updates the event's ticket price
/// 
/// 4. Backend API Endpoints Used:
///    - GET /api/ai-optimization/ml/categories
///      Fetches event category mappings
///    - POST /api/ai-optimization/ml/optimize
///      Gets price recommendation from ML model
///    - POST /api/ai-optimization/ml/apply-recommendation
///      Applies recommendation and logs to database
///    - POST /api/ai-optimization/ml/reject-recommendation
///      Logs rejection of recommendation
///    - GET /api/ai-optimization/ml/analytics/{event_id}
///      Retrieves AI optimization history
/// 
/// 5. Features:
///    - Real-time AI model predictions
///    - Multiple pricing scenarios tested (1000-5000 LKR range)
///    - Revenue impact visualization
///    - Price change percentage indicators
///    - Model type displayed (RandomForest/GradientBoosting)
///    - Event details sidebar
///    - Error handling and retry functionality
///    - Loading states with progress indicators
///    - Analytics logging for each recommendation
/// 
/// 6. Customization Options:
///    - Modify color scheme by changing the gradient colors in the widget
///    - Adjust price range (1000-5000) by passing price_range in the API request
///    - Customize the model by modifying backend/ml_services/train_revenue_model.py
/// 
/// 7. Error Handling:
///    The widget handles:
///    - Network timeouts (30 seconds default)
///    - Model loading failures
///    - API errors (with user-friendly messages)
///    - Missing category mappings (defaults to 0)
///    - Graceful fallback behavior
