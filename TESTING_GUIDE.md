# Daily Check-In Feature - Testing Guide

## How to Test the Implementation

### Test Case 1: First Time Opening the App (No Check-In Yet)

**Expected Flow:**
1. App launches → Splash screen with "FOCUS" logo (2 seconds)
2. Splash screen checks: `lastCheckInDate` is empty/null → NOT equal to today
3. Automatic navigation to Welcome Screen
4. User sees: "Welcome back! 👋" with "How are you feeling today? Let's start your daily check-in and earn 100 coins!"
5. User proceeds through:
   - Mood Selection Screen (5 mood options)
   - Positive Message Screen (based on mood)
   - Quick Game Screen
   - Reward Screen (animated +100 coins)
6. Returns to Home Screen
7. Home Screen shows:
   - Coins: 100
   - Check-In Card: Green gradient, "You've already checked in today ✓"
   - Button: DISABLED (greyed out)

**How to Verify:**
- Check SharedPreferences:
  - `coins` = 100
  - `lastCheckInDate` = today's date (YYYY-MM-DD)
  - `rewardGivenToday` = true

---

### Test Case 2: Opening App Later Same Day

**Setup:** Already completed check-in earlier

**Expected Flow:**
1. App launches → Splash screen (2 seconds)
2. Splash screen checks: `lastCheckInDate` == today → MATCH
3. Automatic skip of check-in, direct navigation to Home Screen
4. Home Screen shows:
   - Coins: 100 (unchanged)
   - Check-In Card: Green gradient, "You've already checked in today ✓"
   - Message: "Come back tomorrow for more coins"
   - Button: DISABLED (greyed out)
   - Daily Reflection card: DISABLED (greyed out, lighter colors)

**How to Verify:**
- Check SharedPreferences:
  - `coins` = 100 (no change, reward not doubled)
  - `lastCheckInDate` = same as before
  - `rewardGivenToday` = true

---

### Test Case 3: Opening App Next Day

**Setup:** 
1. Clear SharedPreferences or change system date to next day
2. Or manually test by modifying `lastCheckInDate` in SharedPreferences

**Expected Flow:**
1. App launches → Splash screen (2 seconds)
2. Splash screen checks: `lastCheckInDate` (old date) ≠ today (new date)
3. Splash screen automatically resets: `rewardGivenToday` = false
4. Navigation to Welcome Screen
5. User completes check-in again
6. Reward: +100 coins → Total now 200
7. Home Screen shows:
   - Coins: 200 (new total)
   - Check-In Card: Green gradient, "You've already checked in today ✓"

**How to Verify:**
- Check SharedPreferences:
  - `coins` = 200
  - `lastCheckInDate` = new date
  - `rewardGivenToday` = true

---

### Test Case 4: Trying to Manually Click Check-In After Completion

**Setup:** Already completed check-in today

**Expected Behavior:**
1. Home Screen shows "Start Check-In" button as DISABLED
2. Clicking the button does nothing (no action)
3. Daily Reflection card is greyed out
4. No navigation occurs

**How to Verify:**
- Button appears inactive with grey coloring
- No taps are processed

---

### Test Case 5: Emergency Re-Entry Check

**Setup:** Already completed check-in, trying to navigate directly

**Expected Behavior:**
1. Even if user navigates to WelcomeScreen manually, the check-in should still work
2. After completing, reward system prevents double-giving:
   - Checks `rewardGivenToday` flag
   - If true, skips coin addition
   - Returns early without updating coins

**How to Verify:**
- Coins do not increase on second check-in attempt
- SharedPreferences shows only one reward per day

---

## Visual Indicators to Check

### Home Screen - Not Yet Checked In
```
┌─────────────────────────────┐
│ Good to see you! 👋     ⭐100 │  ← Shows starting balance
├─────────────────────────────┤
│ ◯ Daily Check-In            │  ← Purple gradient
│ Complete your daily          │
│ check-in to earn 100 coins!  │
│ ┌─────────────────────────┐  │
│ │   Start Check-In        │  │  ← ENABLED (clickable)
│ └─────────────────────────┘  │
├─────────────────────────────┤
│ Quick Actions               │
│ 🔄 Daily Reflection         │
│   Start your check-in ✓ ENABLED
│ 📈 Your Progress            │
│   Coming soon ✓ ENABLED
│ ⚙️  Settings                │
│   Customize your experience ✓ ENABLED
└─────────────────────────────┘
```

### Home Screen - Already Checked In Today
```
┌─────────────────────────────┐
│ Good to see you! 👋     ⭐100 │  ← Updated coins
├─────────────────────────────┤
│ ✓ Daily Check-In            │  ← Green gradient
│ You've already checked in    │
│ today. Great job! 🎉         │
│ ✓ Come back tomorrow for     │
│   more coins                 │
├─────────────────────────────┤
│ Quick Actions               │
│ 🔄 Daily Reflection         │
│   Check-in complete today ✗ DISABLED (greyed)
│ 📈 Your Progress            │
│   Coming soon ✓ ENABLED
│ ⚙️  Settings                │
│   Customize your experience ✓ ENABLED
└─────────────────────────────┘
```

### Reward Screen
```
┌─────────────────────────────┐
│     🎉 FOCUS -              │
│   Daily Check-In Complete!  │
│                             │
│        ╔═════════╗          │
│        ║ ✨ ✨ ✨ ║          │  ← Animated star icon
│        ║  ✨ ⭐ ✨ ║          │     (scales + rotates)
│        ║ ✨ ✨ ✨ ║          │
│        ╚═════════╝          │
│                             │
│   ┌─────────────────────┐   │
│   │ 100 Coins Earned    │   │
│   │ Come back tomorrow   │   │
│   │ for more!           │   │
│   └─────────────────────┘   │
│                             │
│  (Auto-returns in 3 sec)    │
└─────────────────────────────┘
```

---

## Common Testing Scenarios

### Scenario A: Full Happy Path
1. First launch → Complete check-in → Earn 100 coins
2. Open app again same day → See check-in disabled
3. Change date to tomorrow → Check-in enabled again
4. Complete again → Earn 100 more coins (total: 200)

### Scenario B: Network/Crash Scenario
1. Start check-in flow
2. Kill app while on game screen
3. Reopen app
4. Check: Is `lastCheckInDate` set? No → Should see Welcome Screen again
5. Complete check-in
6. Check: Is reward only given once? Yes → Only +100 added

### Scenario C: Time Zone Scenario
1. Complete check-in at 11:55 PM
2. Open app after midnight
3. Check: Does it recognize new day? Yes → Should see Welcome Screen

---

## Debugging Tips

**Check Stored Values:**
```dart
// Add this temporarily to see stored values
final prefs = await SharedPreferences.getInstance();
print('Coins: ${prefs.getInt('coins') ?? 0}');
print('LastCheckIn: ${prefs.getString('lastCheckInDate')}');
print('RewardGiven: ${prefs.getBool('rewardGivenToday')}');
print('Today: ${DateTime.now().toString().substring(0, 10)}');
```

**Clear All Data (Reset for Testing):**
```dart
// Add to a debug button
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

**Force Check Date Comparison:**
- Add print statements in `_loadData()` method
- Monitor `lastDate == today` comparison

---

## Success Criteria ✓

- [x] First time users see full check-in workflow
- [x] Same-day repeat access shows home screen directly
- [x] Check-in button disabled after completion
- [x] Daily Reflection card shows disabled state
- [x] Coins display updates correctly (+100)
- [x] Reward screen shows celebratory animation
- [x] Next day allows check-in again
- [x] No double-reward possible in 24-hour period
- [x] All screens show "FOCUS" branding
- [x] Navigation flow is smooth and intuitive
