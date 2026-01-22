# Quick Reference - Daily Check-In System

## 📋 Files Modified

1. **lib/screens/splash_screen.dart** ✓
   - Already had check-in logic
   - Checks `lastCheckInDate` vs today
   - Routes to Welcome or Home

2. **lib/screens/home_screen.dart** ✓
   - Added `checkedInToday` tracking
   - Dynamic check-in card (purple/green)
   - Disabled "Start Check-In" button after completion
   - Added `_startCheckIn()` method
   - Updated `_buildActionCard()` with `enabled` parameter

3. **lib/screens/daily_checkin/welcome_screen.dart** ✓
   - Updated text to mention "+100 coins"

4. **lib/screens/daily_checkin/mood_screen.dart** ✓
   - Added title "FOCUS - How are you feeling?"
   - Simplified AppBar

5. **lib/screens/daily_checkin/message_screen.dart** ✓
   - Already had FOCUS prefix in text
   - No changes needed

6. **lib/screens/daily_checkin/game_screen.dart** ✓
   - Removed 30-second countdown timer
   - Immediate reward claiming
   - Updated UI text with FOCUS

7. **lib/screens/daily_checkin/reward_screen.dart** ✓
   - Updated to show "+100 Coins Earned"
   - Fixed navigation to properly return to Home
   - Shows celebratory animation

## 🔑 Key Variables & Methods

### Home Screen State Variables
```dart
int coins = 0;                      // Total coins user has
bool checkedInToday = false;        // Check-in status today
```

### Key Methods
```dart
_loadData()                 // Load coins & check-in status from storage
_startCheckIn()             // Navigate to welcome screen & reload after
```

### Reward Screen Method
```dart
_giveReward()               // Add 100 coins, set flags, navigate back
```

## 💾 SharedPreferences Keys

| Key | Type | Purpose |
|-----|------|---------|
| `coins` | int | Total coins earned |
| `lastCheckInDate` | String | Date of last check-in (YYYY-MM-DD) |
| `rewardGivenToday` | bool | Prevents duplicate rewards |

## 🎯 Workflow Summary

```
User Opens App
    ↓
Splash Screen Checks:
  lastCheckInDate == today?
    ↓
    ├─ TRUE  → Navigate to Home Screen (show green card)
    └─ FALSE → Navigate to Welcome Screen (show purple card)
    
After Check-In Completion:
  ├─ Set lastCheckInDate = today
  ├─ Set rewardGivenToday = true
  ├─ coins += 100
  └─ Return to Home Screen with updated data
```

## 🛠️ Implementation Details

### Date Comparison
```dart
final today = DateTime.now().toString().substring(0, 10);
// Creates format: "2026-01-22"

final lastDate = prefs.getString('lastCheckInDate');
// Retrieves: "2026-01-22" or null

checkedInToday = (lastDate == today);
// Simple string comparison
```

### Button Enable/Disable Logic
```dart
// In Home Screen
if (!checkedInToday)
    ElevatedButton(onPressed: _startCheckIn, ...)  // ENABLED
else
    Row(children: [...])  // Just shows message, NO BUTTON

// In Action Cards
_buildActionCard(
    enabled: !checkedInToday,  // Disabled after check-in
    onTap: checkedInToday ? () {} : _startCheckIn,
)
```

### Double-Reward Prevention
```dart
// In Reward Screen _giveReward()
final alreadyRewarded = prefs.getBool('rewardGivenToday') ?? false;
if (alreadyRewarded) return;  // Exit early if already rewarded

// ... give reward ...
await prefs.setBool('rewardGivenToday', true);
```

## 🎨 UI Color Scheme

| Component | Colors |
|-----------|--------|
| Check-In Card (Not Done) | Purple (#6C63FF) |
| Check-In Card (Done) | Green (#6BCB77) |
| Reward Screen | Yellow to Pink gradient |
| Coins Badge | Gold/Yellow (#FFD700) |

## ⚡ Navigation Flow

```
Home Screen
    ↓
    └─ Click "Start Check-In"
       ↓
       Welcome Screen
       ↓
       Mood Selection
       ↓
       Message Screen
       ↓
       Game Screen
       ↓
       Reward Screen (3 sec animation)
       ↓
    ← Returns with result=true
    ← _loadData() called to refresh
    ← Shows updated check-in status
```

## 🔔 Important Notes

1. **Date Format:** Always use `substring(0, 10)` to get YYYY-MM-DD
2. **Time Zone:** Uses device's local time (not UTC)
3. **Persistence:** Data survives app restarts using SharedPreferences
4. **Reset:** Automatically resets reward flag at midnight
5. **Navigation:** Returns `true` from check-in flow to trigger reload
6. **Safety:** Double-checks `rewardGivenToday` before adding coins

## 📱 UI States

### Home Screen States

**State 1: Not Checked In Yet**
- Check-In Card: Purple gradient
- Button: "Start Check-In" (VISIBLE, ENABLED)
- Daily Reflection: ENABLED
- Message: "Complete your daily check-in to earn 100 coins!"

**State 2: Already Checked In**
- Check-In Card: Green gradient with ✓
- Button: HIDDEN
- Daily Reflection: DISABLED (greyed)
- Message: "You've already checked in today. Great job! 🎉"

## 🐛 Debug Checklist

Before release, verify:
- [ ] Coins increment correctly (+100)
- [ ] Check-in only happens once per day
- [ ] Green card shows after completion
- [ ] Purple card shows on new day
- [ ] "Start Check-In" button disables after use
- [ ] Reward screen animates for 3 seconds
- [ ] Navigation back to Home works smoothly
- [ ] All FOCUS branding is consistent

## 📊 Example Data Flow

**Day 1, 10:00 AM:**
```
SharedPreferences before:
  coins: 0
  lastCheckInDate: null
  rewardGivenToday: false

User completes check-in...

SharedPreferences after:
  coins: 100
  lastCheckInDate: "2026-01-22"
  rewardGivenToday: true
```

**Day 1, 3:00 PM:**
```
SharedPreferences:
  coins: 100 (unchanged)
  lastCheckInDate: "2026-01-22"
  rewardGivenToday: true

User opens app → Splash checks: "2026-01-22" == "2026-01-22"
Result: true → Skip check-in, show Home with Green card
```

**Day 2, 10:00 AM:**
```
SharedPreferences:
  coins: 100
  lastCheckInDate: "2026-01-22" (OLD)
  rewardGivenToday: true

User opens app → Splash checks: "2026-01-22" == "2026-01-23"
Result: false → Show Welcome Screen
Splash automatically resets: rewardGivenToday: false

User completes check-in...

SharedPreferences after:
  coins: 200
  lastCheckInDate: "2026-01-23"
  rewardGivenToday: true
```

---

## ✅ Feature Checklist

- [x] Daily check-in workflow (5 screens)
- [x] One-time per day protection
- [x] +100 coins reward system
- [x] Animated reward screen
- [x] Home screen hub with coin display
- [x] Dynamic check-in status display
- [x] Button enable/disable logic
- [x] Navigation handling with results
- [x] Data persistence with SharedPreferences
- [x] Double-reward prevention
- [x] Auto-date reset logic
- [x] FOCUS branding on all screens
- [x] Beginner-friendly code structure
- [x] Comments on safety features
