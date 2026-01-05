# 🎯 Integration Guide: Google-Style Search Results with Preferences

## ✅ What Has Been Implemented

### 1. **User Preference Input Screen** 
File: `lib/screens/recommendations/user_preference_input_screen.dart`

**Features:**
- ✅ Age input field (validated 13-120)
- ✅ Preferred Area dropdown (25 Sri Lankan districts)
- ✅ Budget per Event input (LKR)
- ✅ Favourite Artist text field
- ✅ Event Type checkboxes (Concerts, Sports, Festivals, Cultural)
- ✅ Clean, modern UI design
- ✅ Form validation
- ✅ Saves preferences to system
- ✅ Auto-navigates to search results after submission

### 2. **Google-Style Search Results Screen**
File: `lib/screens/recommendations/search_results_screen.dart`

**Features:**
- ✅ Google-like header with search box
- ✅ Search statistics ("About X results")
- ✅ **TWO RESULT SECTIONS:**
  
  **Section 1: System Events (from Add Event form)**
  - Shows real events from your database
  - Filtered by user preferences:
    - Budget matching
    - Area/location matching
    - Event type matching
    - Favourite artist matching
  - Styled like Google search results
  - Clickable → Opens event detail screen
  
  **Section 2: External-Style Results**
  - Simulated external search results
  - Dynamically generated based on preferences
  - Styled like Google search results
  - Informational (non-clickable)

- ✅ **Right-click disabled** on entire page
- ✅ Google-style footer
- ✅ Fully responsive design

### 3. **Right-Click Protection**
File: `web/index.html`

**Protected against:**
- ✅ Right-click context menu
- ✅ Text selection on search results
- ✅ F12 (Developer tools)
- ✅ Ctrl+Shift+I (Inspect element)
- ✅ Ctrl+Shift+J (Console)
- ✅ Ctrl+U (View source)

### 4. **Integration with AI Recommendations**
File: `lib/screens/recommendations/ai_recommendations_screen.dart`

**Updated:**
- ✅ "Set Preferences" button now navigates to new form
- ✅ Auto-reloads recommendations after preference submission

---

## 🚀 How to Use

### **Step 1: Access the Feature**

Navigate to AI Recommendations screen → Click "Set Preferences" button

### **Step 2: Fill Preferences**

```
Age: [Enter age, e.g., 25]
Preferred Area: [Select from dropdown, e.g., Colombo]
Budget per Event: [Enter budget, e.g., 5000]
Favourite Artist: [Enter artist name, e.g., Yohani]
Event Types: [Check boxes: ✓ Concerts ✓ Cultural]
```

### **Step 3: Get Results**

Click "Get Recommendations" → Automatically navigates to search results

### **Step 4: View Results**

**Section 1: Festio.lk Events** (Your System Data)
- Real events from database
- Filtered by your preferences
- Click to view details

**Section 2: Related Information** (External-style)
- Additional relevant content
- Styled like web search results

---

## 📁 File Structure

```
lib/
  screens/
    recommendations/
      ✅ user_preference_input_screen.dart    (Preference form)
      ✅ search_results_screen.dart            (Google-style results)
      ✅ ai_recommendations_screen.dart        (Updated with integration)
  
web/
  ✅ index.html                                (Right-click protection)
```

---

## 🎨 How the Search Results Look

### Google-Style Header
```
[←] [Festio Logo] [concerts cultural in colombo     ] 
```

### Search Stats
```
About 15 results (0.234 seconds)
```

### Section 1: System Events
```
[📷] festio.lk › events › event123

Rock Concert 2026                               [Blue Google title]
15/2/2026 · Colombo · LKR 3000
Experience the biggest rock concert of the year featuring...

[concerts] [music] [live]
```

### Section 2: External-Style Results
```
[🌐] www.events.lk

Best Concerts in Colombo                        [Blue Google title]
Discover upcoming concerts in your area. Find tickets...
```

---

## 🔧 How It Works Technically

### 1. **Preference Flow**

```dart
User clicks "Set Preferences"
    ↓
UserPreferenceInputScreen
    ↓
Fill form (age, area, budget, artist, types)
    ↓
Click "Get Recommendations"
    ↓
Save to UserPreferencesModel
    ↓
Auto-navigate to SearchResultsScreen
```

### 2. **Result Filtering Logic**

```dart
_filterEventsByPreferences(events) {
  // Budget filter
  if (event.ticketPrice > maxBudget) → EXCLUDE
  
  // Area filter
  if (!event.location.contains(preferredArea)) → EXCLUDE
  
  // Event type filter
  if (!favoriteEventTypes.contains(event.category)) → EXCLUDE
  
  // Artist filter
  if (favoriteArtist in event.title/description) → INCLUDE
  
  return filteredEvents;
}
```

### 3. **Search Query Generation**

```dart
"concerts cultural in colombo"
    ↑           ↑          ↑
event types   types   preferred area
```

### 4. **Two-Section Display**

```dart
CustomScrollView([
  // Header
  SliverAppBar(Google-style header),
  
  // Section 1: System Events
  SliverToBoxAdapter(_buildSectionHeader('Events from Festio.lk')),
  SliverList(_systemEvents.map(_buildSystemEventResult)),
  
  // Section 2: External-Style
  SliverToBoxAdapter(_buildSectionHeader('Related Information')),
  SliverList(mockExternalResults.map(_buildExternalStyleResult)),
  
  // Footer
  SliverToBoxAdapter(_buildFooter()),
])
```

---

## 🎯 Parameters from Add Event Form

The search uses these **EventModel** fields:

```dart
✅ title             - Matched against favorite artist
✅ description       - Matched against favorite artist
✅ category          - Matched against event types
✅ tags              - Matched against event types
✅ location          - Matched against preferred area
✅ ticketPrice       - Matched against budget
✅ startDate         - Displayed in results
✅ imageUrl          - Displayed as thumbnail
✅ isApproved        - Only approved events shown
✅ isSpam            - Spam events excluded
```

---

## 🔐 Security Features

### Right-Click Protection (web/index.html)

```javascript
// Disable context menu
document.addEventListener('contextmenu', (e) => e.preventDefault());

// Disable text selection on search results
document.addEventListener('selectstart', (e) => {
  if (window.location.pathname.includes('search-results')) {
    e.preventDefault();
  }
});

// Disable developer tools shortcuts
document.addEventListener('keydown', (e) => {
  if (e.keyCode == 123 ||                      // F12
      (e.ctrlKey && e.shiftKey && e.keyCode == 73) ||  // Ctrl+Shift+I
      (e.ctrlKey && e.shiftKey && e.keyCode == 74) ||  // Ctrl+Shift+J
      (e.ctrlKey && e.keyCode == 85)) {        // Ctrl+U
    e.preventDefault();
  }
});
```

---

## 📊 Example Usage Scenario

**User Input:**
```
Age: 25
Preferred Area: Colombo
Budget: 5000 LKR
Favourite Artist: Yohani
Event Types: ✓ Concerts ✓ Cultural
```

**Generated Search Query:**
```
"concerts cultural Yohani in Colombo"
```

**Filtered Results:**
```
Section 1: Festio.lk Events (System Data)
- 3 concerts in Colombo under 5000 LKR
- 2 cultural events featuring Yohani
- 1 music festival in Colombo

Section 2: Related Information (External-style)
- "Best Concerts in Colombo"
- "Yohani Live Performances 2026"
- "Event Calendar - Colombo"
- "Entertainment Guide"
- "Buy Tickets Online"
```

---

## 🎨 Customization Options

### Change Google Colors

```dart
// In search_results_screen.dart
const Color(0xFF1A73E8)  // Google blue for titles
const Color(0xFF1A0DAB)  // Visited link color
```

### Adjust Result Filters

```dart
// In _filterEventsByPreferences()
// Add more filter logic:
if (preferences.observesReligiousHolidays) {
  // Filter religious events
}
```

### Modify External Results

```dart
// In _buildExternalStyleResult()
// Change mockResults array to customize external results
```

---

## 🐛 Troubleshooting

### Issue: "Set Preferences" button doesn't navigate

**Solution:**
```dart
// Ensure import in ai_recommendations_screen.dart
import 'user_preference_input_screen.dart';

// Button code:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const UserPreferenceInputScreen(),
  ),
);
```

### Issue: No results shown

**Solution:**
- Check if events are approved: `event.isApproved == true`
- Check if events match preferences
- Verify `EventProvider` has loaded events

### Issue: Right-click still works

**Solution:**
- Run `flutter clean && flutter build web`
- Clear browser cache
- Check `web/index.html` has the JavaScript code

---

## ✨ Future Enhancements

Possible improvements:
1. Add pagination for results
2. Add sorting options (by date, price, relevance)
3. Add filter refinement after search
4. Add "Did you mean?" for typos
5. Add sponsored results section
6. Add maps/images in results
7. Add social sharing buttons
8. Add save/bookmark functionality

---

## 📝 Summary

✅ **Preference Form**: Clean, validated input form  
✅ **Search Results**: Google-style 2-section results  
✅ **System Integration**: Uses real event data from Add Event form  
✅ **Security**: Right-click and keyboard shortcuts disabled  
✅ **Navigation**: Seamless flow from preferences → results  
✅ **Filtering**: Smart filtering by budget, area, type, artist  
✅ **UI/UX**: Professional Google-inspired design  

**Everything is integrated and ready to use!** 🎉

---

## 🔗 Quick Reference

**Navigate to preferences:**
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const UserPreferenceInputScreen(),
));
```

**Navigate to results:**
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => SearchResultsScreen(userPreferences: prefs),
));
```

**Access from AI Recommendations:**
- Click "Set Preferences" button → Auto-handles everything

---

**All features are now live and integrated into your system!** 🚀
