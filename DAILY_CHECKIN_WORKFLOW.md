# FOCUS Daily Check-In Workflow

## Overview
The app implements a complete daily check-in flow that allows users to earn 100 coins per day by completing the check-in process. Each user can only check in once per day.

## Workflow Flow

```
App Launch
    ↓
Splash Screen (2 second animation)
    ↓
Check if user completed check-in today?
    ├─ YES → Home Screen
    └─ NO → Start Daily Check-In:
           1. Welcome Screen
           2. Mood Selection Screen
           3. Positive Message Screen (based on mood)
           4. Quick Game/Engagement Screen
           5. Reward Screen (+100 coins animation)
           6. Return to Home Screen
```

## Key Features

### 1. **One-Time Daily Check-In**
- The app stores the last check-in date in SharedPreferences
- Compares the stored date with today's date
- If already checked in, skips the entire flow and goes directly to Home Screen
- Reset flag happens automatically at midnight (new day)

### 2. **Reward System**
- **Fixed Reward:** Exactly 100 coins per daily check-in
- **Storage:** Coins are stored locally using SharedPreferences
- **Animation:** Celebratory reward screen with:
  - Animated star icon (scale + rotation)
  - Gradient background
  - "100 Coins Earned" message
  - 3-second display before auto-navigating

### 3. **Home Screen**
Central hub displaying:
- **Total Coins Display:** Top-right corner with coin counter
- **Daily Status Card:** Shows if check-in is completed today
  - If NOT completed: Shows "Complete your daily check-in to earn 100 coins!" with Start button
  - If completed: Shows "You've already checked in today" with message to return tomorrow
- **Quick Actions:**
  - Daily Reflection (disabled after check-in)
  - Your Progress (coming soon)
  - Settings (coming soon)

### 4. **Screens Structure**

#### Splash Screen
- Displays "FOCUS" logo with animation
- Checks if daily check-in is already done
- Routes appropriately (Home or Welcome)

#### Welcome Screen
- Greeting message
- "How are you feeling today? Let's start your daily check-in and earn 100 coins!"
- Smooth slide-in animation

#### Mood Screen
- 5 mood options (Great, Good, Okay, Bad, Awful)
- Each mood has emoji and color
- Selected mood determines the positive message

#### Message Screen
- Shows personalized message based on selected mood
- Celebrates the user
- Animated entrance

#### Game Screen
- Immediate reward claim (no 30-second timer)
- Shows coin display
- Claim Reward button to proceed

#### Reward Screen
- Animated star icon celebration
- Shows "+100 Coins Earned" message
- Auto-navigates back to Home after 3 seconds
- Sets `lastCheckInDate` and `rewardGivenToday` flags

### 5. **Data Persistence**

Uses `SharedPreferences` to store:
```dart
coins                    → Total coins earned (int)
lastCheckInDate          → Date of last check-in (String: YYYY-MM-DD)
rewardGivenToday         → Whether reward was given today (bool)
```

### 6. **Safety Features**

- **Double-Reward Prevention:** 
  - Check `rewardGivenToday` flag before awarding coins
  - Reset flag automatically on new day
  
- **Date Comparison:**
  - Uses `DateTime.now().toString().substring(0, 10)` for YYYY-MM-DD format
  - Consistent date checking across all screens

- **Navigation:**
  - Home Screen prevents check-in button from being active after completion
  - Actions are disabled after check-in (greyed out)
  - Check-in flow returns with `result=true` to trigger reload

## Beginner-Friendly Code Notes

- Uses simple state management with `setState()`
- Clear variable naming (`checkedInToday`, `coins`)
- Separate methods for loading data and starting check-in
- Easy-to-understand animation patterns
- Commented dates and safety checks

## Future Enhancements

- Track check-in streaks
- Leaderboards
- Different reward types
- Weekly challenges
- Progress analytics
- Custom daily themes
