# Charity Persistence Fix - Cross-Browser Support

## Problem Identified ❌

**Before the fix**, supported charities on **web** were saved to **SharedPreferences** (browser localStorage), which meant:

- ✅ Data persists within the **same browser**
- ❌ Data is **lost when switching browsers** (Chrome → Firefox)
- ❌ Data is **lost when clearing browser data**
- ❌ **No sync across devices**

### Why This Happened

```dart
// OLD CODE (Web - SharedPreferences only)
if (kIsWeb) {
  final prefsData = await _loadCharityPrefsFromPrefs();
  final userCharities = prefsData[userId] ?? [];
  userCharities.add(charityId);
  await _saveCharityPrefsToPrefs(prefsData);  // Saved ONLY to localStorage
}
```

**SharedPreferences on web** = Browser's `localStorage` API
- Isolated per browser
- Not synced to cloud

---

## Solution Applied ✅

**Now**, supported charities on **web** are saved to **Cloud Firestore**, just like favorite restaurants!

### What Changed

| Feature | Before (SharedPreferences) | After (Firestore) |
|---------|---------------------------|-------------------|
| **Storage Location** | Browser localStorage | Cloud database |
| **Cross-Browser** | ❌ No | ✅ Yes |
| **Cross-Device** | ❌ No | ✅ Yes |
| **Persistence** | ❌ Lost on cache clear | ✅ Always persists |
| **Real-time Sync** | ❌ No | ✅ Yes |

### New Code

```dart
// NEW CODE (Web - Firestore sync)
if (kIsWeb) {
  // WEB: Save to Firestore (persists across browsers)
  final firestore = FirebaseFirestore.instance;
  await firestore
      .collection('userCharities')
      .doc(userId)
      .collection('charities')
      .doc(charityId)
      .set({
    'charity_id': charityId,
    'created_at': FieldValue.serverTimestamp(),
  });
}
```

---

## Architecture: Web vs Mobile

### Web (Browser)

```
User supports charity
       ↓
database_service.dart
       ↓
  if (kIsWeb)
       ↓
Cloud Firestore
  /userCharities/{userId}/charities/{charityId}
       ↓
✅ Synced across ALL browsers
✅ Synced across ALL devices
```

### Mobile (iOS/Android)

```
User supports charity
       ↓
database_service.dart
       ↓
  if (!kIsWeb)
       ↓
Local SQLite Database
  TABLE: user_charity_preferences
       ↓
✅ Fast local access
✅ Works offline
```

---

## Firestore Structure

### Collection: `userCharities`

```
userCharities/
  ├── {userId_1}/
  │     └── charities/
  │           ├── charity_001/
  │           │     ├── charity_id: "charity_001"
  │           │     └── created_at: Timestamp
  │           └── charity_002/
  │                 ├── charity_id: "charity_002"
  │                 └── created_at: Timestamp
  │
  ├── {userId_2}/
  │     └── charities/
  │           └── charity_003/
  │                 ├── charity_id: "charity_003"
  │                 └── created_at: Timestamp
```

This structure mirrors how **favorite restaurants** are stored:

```
userFavorites/
  └── {userId}/
        └── restaurants/
              └── {restaurantId}/
                    ├── restaurant_name: "..."
                    ├── restaurant_rating: 4.5
                    └── created_at: Timestamp
```

---

## Updated Methods

### 1. `addSupportedCharity()`

**What it does**: Adds a charity to user's supported list

**Web behavior**:
```dart
firestore
  .collection('userCharities')
  .doc(userId)
  .collection('charities')
  .doc(charityId)
  .set({...})  // Saves to cloud ☁️
```

**Mobile behavior**:
```dart
db.insert('user_charity_preferences', {...})  // Saves to SQLite 📱
```

---

### 2. `removeSupportedCharity()`

**What it does**: Removes a charity from user's supported list

**Web behavior**:
```dart
firestore
  .collection('userCharities')
  .doc(userId)
  .collection('charities')
  .doc(charityId)
  .delete()  // Deletes from cloud ☁️
```

**Mobile behavior**:
```dart
db.delete('user_charity_preferences', where: '...')  // Deletes from SQLite 📱
```

---

### 3. `getSupportedCharities()`

**What it does**: Gets all charities supported by user

**Web behavior**:
```dart
final snapshot = await firestore
    .collection('userCharities')
    .doc(userId)
    .collection('charities')
    .get();

return snapshot.docs.map((doc) => doc.id).toList();  // Loads from cloud ☁️
```

**Mobile behavior**:
```dart
final results = await db.query('user_charity_preferences', where: '...');
return results.map((row) => row['charity_id']).toList();  // Loads from SQLite 📱
```

---

### 4. `isCharitySupported()`

**What it does**: Checks if user supports a specific charity

**Web behavior**:
```dart
final doc = await firestore
    .collection('userCharities')
    .doc(userId)
    .collection('charities')
    .doc(charityId)
    .get();

return doc.exists;  // Checks in cloud ☁️
```

**Mobile behavior**:
```dart
final results = await db.query(
  'user_charity_preferences',
  where: 'user_id = ? AND charity_id = ?',
  whereArgs: [userId, charityId],
);

return results.isNotEmpty;  // Checks in SQLite 📱
```

---

## Testing the Fix

### Test Case 1: Same Browser ✅
1. Open app in Chrome
2. Support a charity
3. Refresh page
4. ✅ Charity still supported

### Test Case 2: Different Browser ✅
1. Open app in Chrome
2. Support a charity
3. Open app in Firefox **with same account**
4. ✅ Charity still supported (synced from Firestore!)

### Test Case 3: Different Device ✅
1. Open app on Computer (web)
2. Support a charity
3. Open app on Phone (mobile app) **with same account**
4. ❌ NOT synced (mobile uses local SQLite)
   - **Note**: Mobile doesn't sync to Firestore in current implementation
   - Mobile data stays local for performance

### Test Case 4: Clear Browser Data ✅
1. Support a charity
2. Clear browser cache/localStorage
3. Reload app
4. ✅ Charity still supported (because it's in Firestore, not localStorage!)

---

## Comparison with Other Features

### Feature Persistence Matrix

| Feature | Mobile Storage | Web Storage | Cross-Browser? | Cross-Device? |
|---------|---------------|-------------|----------------|---------------|
| **Cart Items** | SQLite | SharedPreferences | ❌ No | ❌ No |
| **Favorite Restaurants** | SQLite | **Firestore** | ✅ Yes | Web↔Web only |
| **Supported Charities** | SQLite | **Firestore** | ✅ Yes | Web↔Web only |
| **Profile Images** | SQLite | Firestore | ✅ Yes | Web↔Web only |
| **Auth Session** | SQLite | SharedPreferences | ❌ No | ❌ No |

### Why Some Features Don't Sync

**Cart Items** use SharedPreferences on web because:
- Carts are temporary (cleared after checkout)
- Not critical to persist across browsers
- Faster to store locally
- Less Firestore API calls = lower costs

**Favorite Restaurants & Charities** use Firestore because:
- Long-term user preferences
- Important to persist
- Users expect them to work everywhere
- Worth the Firestore API calls

---

## Code Changes Summary

### Files Modified
- `lib/services/database_service.dart`

### Methods Updated
1. `addSupportedCharity()` - Now saves to Firestore on web
2. `removeSupportedCharity()` - Now removes from Firestore on web
3. `getSupportedCharities()` - Now loads from Firestore on web
4. `isCharitySupported()` - Now checks Firestore on web

### Old Helper Methods (Now Unused on Web)
- `_loadCharityPrefsFromPrefs()` - No longer called on web
- `_saveCharityPrefsToPrefs()` - No longer called on web

**Note**: These methods are still in the code but only used for mobile (SQLite) now.

---

## Benefits of This Fix

### For Users ✅
- ✅ Charities persist when switching browsers
- ✅ Charities persist when clearing browser data
- ✅ Consistent experience across all web browsers
- ✅ No data loss

### For Developers ✅
- ✅ Consistent pattern with favorite restaurants
- ✅ Easier to maintain (one storage strategy per platform)
- ✅ Better data security (Firestore has auth rules)
- ✅ Cloud backup of user preferences

---

## Firestore Security Rules (Recommended)

To secure the charity data, add these rules to Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User charities - only user can read/write their own data
    match /userCharities/{userId}/charities/{charityId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

This ensures:
- Users can only access their own charity data
- Unauthorized users cannot read/write
- Data is protected in the cloud

---

## Conclusion

The fix ensures **supported charities work exactly like favorite restaurants**:
- Mobile: Fast local SQLite storage
- Web: Cloud-synced Firestore storage
- **Cross-browser persistence** on web ✅
- Consistent architecture ✅

No more data loss when switching browsers! 🎉
