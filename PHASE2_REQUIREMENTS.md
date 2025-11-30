# Phase 2 - Requirements & Implementation Guide

---

# 🏗️ SYSTEM ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE CLOUD                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Firestore DB │  │ Firebase Auth│  │ Cloud Storage│      │
│  │ (Restaurants)│  │ (Users)      │  │ (Images)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │ Internet / API Calls
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   FLUTTER APP                                │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              SERVICES LAYER                          │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐   │   │
│  │  │ Firestore   │ │ Preferences │ │ Database     │   │   │
│  │  │ Service     │ │ Service     │ │ Helper       │   │   │
│  │  │ (API calls) │ │ (Settings)  │ │ (SQLite)     │   │   │
│  │  └─────────────┘ └─────────────┘ └──────────────┘   │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │         STATE MANAGEMENT (PROVIDER)                  │   │
│  │  ┌─────────────┐ ┌──────────────┐ ┌─────────────┐   │   │
│  │  │ Auth        │ │ Restaurant   │ │ Cart        │   │   │
│  │  │ Provider    │ │ Provider     │ │ Provider    │   │   │
│  │  └─────────────┘ └──────────────┘ └─────────────┘   │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │                 UI SCREENS                           │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ │   │
│  │  │ Sign In  │ │ Home     │ │ Cart     │ │ Profile │ │   │
│  │  │ Screen   │ │ Screen   │ │ Screen   │ │ Screen  │ │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └─────────┘ │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           LOCAL STORAGE                              │   │
│  │  ┌──────────────┐  ┌──────────────────────────────┐  │   │
│  │  │ SQLite       │  │ SharedPreferences            │  │   │
│  │  │ (Cart, Favs) │  │ (User Settings, Auth Token)  │  │   │
│  │  └──────────────┘  └──────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

---

# 📋 REQUIREMENT 1: DATA STORAGE

## Objective:
Implement 3 types of data storage: SQLite (local), Firebase Firestore (cloud), and SharedPreferences (settings)

## What to Build:

### 1.1 Firebase Firestore Setup
**File:** Firebase Console + Config Files

**Steps:**
1. Create Firebase project "nourish-app"
2. Add Android app (download `google-services.json`)
3. Add iOS app (download `GoogleService-Info.plist`)
4. Enable Firestore Database
5. Configure `android/build.gradle` and `android/app/build.gradle`

**What it does:** Stores restaurants data that all users can see

---

### 1.2 SQLite Database
**File:** `lib/services/database_helper.dart`

**Create tables:**
- `cart` - Store shopping cart items
- `favorites` - Store favorite restaurants

**Methods to implement:**
```dart
addToCart(item)
getCartItems()
removeFromCart(id)
clearCart()
```

**What it does:** Stores user's cart locally, works offline

---

### 1.3 SharedPreferences
**File:** `lib/services/preferences_service.dart`

**Methods to implement:**
```dart
saveUserId(userId)
getUserId()
saveAuthToken(token)
getAuthToken()
clearAll()
```

**What it does:** Stores user ID and settings, persists across app restarts

---

### 1.4 Firestore Service (API)
**File:** `lib/services/firestore_service.dart`

**Methods to implement:**
```dart
getRestaurants() // GET request
createOrder(orderData) // POST request
```

**What it does:** Communicates with Firebase to fetch/send data

---

### 1.5 Seed Sample Data
**Platform:** Firebase Console

**Add to Firestore:**
- 2 restaurants with food items
- Each restaurant has name, location, rating, items

**What it does:** Provides test data for the app

---

## Deliverables:
✅ Firebase project configured  
✅ SQLite database with 2 tables  
✅ SharedPreferences service working  
✅ Firestore service with API methods  
✅ Sample restaurants in Firestore  

---

# 📋 REQUIREMENT 2: STATE MANAGEMENT

## Objective:
Use Provider pattern to manage app state and automatically update UI

## What to Build:

### 2.1 Data Models
**Files:** `lib/models/restaurant.dart`

**Create classes:**
```dart
class Restaurant {
  String id, name, address;
  double latitude, longitude, rating;
  List<FoodItem> items;
  
  factory Restaurant.fromFirestore(data) // Convert Firebase data
}

class FoodItem {
  String id, title;
  double originalPrice, discountedPrice;
}
```

**What it does:** Structures data from Firebase

---

### 2.2 AuthProvider
**File:** `lib/providers/auth_provider.dart`

**Methods to implement:**
```dart
signIn(email, password)
signUp(email, password, name)
signOut()
```

**What it does:** Manages user authentication state

---

### 2.3 RestaurantProvider
**File:** `lib/providers/restaurant_provider.dart`

**Methods to implement:**
```dart
fetchRestaurants() // Calls Firestore API
```

**What it does:** Fetches restaurants from Firebase, updates UI automatically

---

### 2.4 CartProvider
**File:** `lib/providers/cart_provider.dart`

**Methods to implement:**
```dart
loadCart() // Load from SQLite
addItem(item) // Add to SQLite
removeItem(id) // Remove from SQLite
clearCart()
```

**What it does:** Manages shopping cart state

---

### 2.5 Initialize Providers
**File:** `lib/main.dart`

**Update:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => RestaurantProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider()),
  ],
  child: MaterialApp(...)
)
```

**What it does:** Makes providers available throughout the app

---

## Deliverables:
✅ Provider package added  
✅ 3 Provider classes created  
✅ Data models created  
✅ Providers initialized in main.dart  
✅ State updates trigger UI changes  

---

# 📋 REQUIREMENT 3: API/NETWORK CALLS

## Objective:
Make at least 1 GET and 1 POST request to Firebase

## What to Build:

### 3.1 GET Request - Fetch Restaurants
**File:** `lib/services/firestore_service.dart`

**Implementation:**
```dart
Future<List<Map<String, dynamic>>> getRestaurants() async {
  final snapshot = await _firestore.collection('restaurants').get();
  return snapshot.docs.map((doc) => doc.data()).toList();
}
```

**What it does:** Fetches all restaurants from Firebase

---

### 3.2 POST Request - Create Order
**File:** `lib/services/firestore_service.dart`

**Implementation:**
```dart
Future<String> createOrder(Map<String, dynamic> orderData) async {
  final docRef = await _firestore.collection('orders').add(orderData);
  return docRef.id;
}
```

**What it does:** Saves order to Firebase

---

### 3.3 Integrate with Provider
**File:** `lib/providers/restaurant_provider.dart`

**Implementation:**
```dart
Future<void> fetchRestaurants() async {
  final data = await _firestoreService.getRestaurants(); // API CALL
  _restaurants = data.map((d) => Restaurant.fromFirestore(d)).toList();
  notifyListeners(); // Update UI
}
```

**What it does:** Provider calls API, updates state, UI rebuilds

---

### 3.4 Update Home Screen
**File:** `lib/screens/home_screen.dart`

**Implementation:**
```dart
@override
void initState() {
  Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants();
}

// In build:
Consumer<RestaurantProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return CircularProgressIndicator();
    return ListView(children: provider.restaurants.map(...).toList());
  },
)
```

**What it does:** Displays restaurants from API

---

## Deliverables:
✅ GET request fetching restaurants  
✅ POST request creating orders  
✅ Provider using API calls  
✅ Home screen displaying API data  
✅ Loading states handled  

---

# 📋 REQUIREMENT 4: FORM VALIDATION

## Objective:
Validate user input with proper error messages and feedback

## What to Build:

### 4.1 Create Validators
**File:** `lib/utils/validators.dart`

**Implementation:**
```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be 8+ characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Need uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Need a number';
    return null;
  }
}
```

**What it does:** Validates email and password format

---

### 4.2 Update Sign In Screen
**File:** `lib/screens/signin_screen.dart`

**Add:**
1. Email field validator: `validator: Validators.validateEmail`
2. Password field validator: `validator: Validators.validatePassword`
3. Loading state: `bool _isLoading = false`
4. Error handling with SnackBar
5. Success feedback with SnackBar

**What it does:** Shows errors for invalid input, loading spinner during sign in

---

### 4.3 Update Create Account Screen
**File:** `lib/screens/create_account_screen.dart`

**Add:**
1. All field validators
2. Loading state
3. Error/success SnackBars

**What it does:** Validates all fields before account creation

---

## Deliverables:
✅ Validators utility created  
✅ Email validation working  
✅ Password validation working  
✅ Loading indicators showing  
✅ Error/success messages appearing  

---

# 📋 REQUIREMENT 5: DEVICE FEATURE (CAMERA)

## Objective:
Use device camera to take and save profile pictures

## What to Build:

### 5.1 Add Camera Package
**File:** `pubspec.yaml`

**Add:**
```yaml
dependencies:
  image_picker: ^1.0.7
```

**What it does:** Provides camera access

---

### 5.2 Add Permissions
**File:** `android/app/src/main/AndroidManifest.xml`

**Add:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**File:** `ios/Runner/Info.plist`

**Add:**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for profile pictures</string>
```

**What it does:** Requests camera permission from user

---

### 5.3 Update Profile Screen
**File:** `lib/screens/profile_screen.dart`

**Implementation:**
```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated!')),
      );
    }
  }
}
```

**Update avatar:**
```dart
GestureDetector(
  onTap: _pickImage,
  child: CircleAvatar(
    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
    child: _profileImage == null ? Text('👤') : null,
  ),
)
```

**What it does:** 
- Tap profile picture → Camera opens
- Take photo → Photo saved and displayed
- Shows success message

---

## Deliverables:
✅ Camera package added  
✅ Permissions configured  
✅ Profile screen opens camera  
✅ Photo displays after capture  
✅ Success message shown  

---

# ✅ FINAL CHECKLIST

## Requirement 1: Data Storage
- [ ] Firebase project configured
- [ ] SQLite database with cart & favorites tables
- [ ] SharedPreferences service created
- [ ] Firestore service with API methods
- [ ] Sample restaurants in Firestore

## Requirement 2: State Management
- [ ] Provider package added
- [ ] AuthProvider created
- [ ] RestaurantProvider created
- [ ] CartProvider created
- [ ] Providers initialized in main.dart

## Requirement 3: API Calls
- [ ] GET request (fetch restaurants)
- [ ] POST request (create order)
- [ ] RestaurantProvider using API
- [ ] Home screen displaying API data
- [ ] Error handling implemented

## Requirement 4: Form Validation
- [ ] Validators utility created
- [ ] Sign In validation working
- [ ] Create Account validation working
- [ ] Loading indicators showing
- [ ] Error/success SnackBars appearing

## Requirement 5: Device Feature
- [ ] Camera package added
- [ ] Permissions configured
- [ ] Profile screen opens camera
- [ ] Photo saves and displays
- [ ] Success message shows

---

# 🎯 SUCCESS CRITERIA

Your app must:
1. ✅ Store data in SQLite, Firebase, and SharedPreferences
2. ✅ Use Provider for state management
3. ✅ Make GET and POST API calls to Firestore
4. ✅ Validate forms with error messages
5. ✅ Use camera to take and save profile pictures

**Estimated Time:** 4-5 hours
