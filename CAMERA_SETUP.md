# Camera & Food Detection Setup Guide

## Overview
This feature allows users to track their meals by capturing photos of food they're eating. The app automatically detects ingredients and provides nutrition information using the Spoonacular API. This is for personal meal tracking, not related to restaurants.

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Get Spoonacular API Key

1. Go to https://spoonacular.com/food-api
2. Create a free account
3. Navigate to your profile/console
4. Copy your API key
5. Open `lib/services/spoonacular_service.dart`
6. Replace `YOUR_SPOONACULAR_API_KEY_HERE` with your actual API key:

```dart
static const String _apiKey = 'your-actual-api-key-here';
```

**Note:** The free plan has limited requests per day. For production, consider upgrading.

### 3. Platform-Specific Setup

#### iOS
- Camera and microphone permissions are already added to `Info.plist`
- No additional setup needed

#### Android
- Camera permissions are already added to `AndroidManifest.xml`
- `minSdkVersion` is set to 21
- No additional setup needed

### 4. Flow

1. Run the app: `flutter run`
2. Navigate to Settings screen (from Profile tab)
3. Tap "Scan Food" option in the General section
4. Grant camera permission when prompted
5. Take a photo of your meal
6. View detected ingredients and nutrition information for your personal meal tracking


## Troubleshooting

### "No cameras available"
- Make sure you're testing on a physical device or emulator with camera support
- Web platform doesn't support camera package

### "Camera permission denied"
- Go to device settings → Apps → Nourish → Permissions
- Enable Camera permission

### "Error analyzing image"
- Check that your Spoonacular API key is correct
- Verify you haven't exceeded API rate limits
- Check internet connection

### API Key Issues
- Make sure the API key is set in `spoonacular_service.dart`
- Verify the API key is active in Spoonacular console
- Free tier has limited requests per day


