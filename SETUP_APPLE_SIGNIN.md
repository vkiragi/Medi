# Apple Sign-In Setup Instructions

Follow these steps to enable Apple Sign-In in your medi app:

## 🔧 Xcode Configuration

### 1. Add Sign In with Apple Capability
1. Open your project in Xcode (`medi-xcode/medi.xcodeproj`)
2. Select your **medi** target in the project navigator
3. Go to the **Signing & Capabilities** tab
4. Click the **+ Capability** button
5. Search for and add **"Sign In with Apple"**

### 2. Update Info.plist (if needed)
The app should work without additional Info.plist changes, but if you encounter issues, add:

```xml
<key>NSAppleIDAuthorizationUsageDescription</key>
<string>This app uses Apple Sign-In to securely save your meditation progress across devices.</string>
```

## 📱 Testing Apple Sign-In

### On Simulator:
1. Make sure you're signed into an Apple ID in Settings > Apple ID
2. Build and run the app
3. Tap "Sign in with Apple"
4. You'll see a Face ID/Touch ID prompt (simulated)

### On Device:
1. Make sure you're signed into your Apple ID in Settings
2. Build and run on your device
3. Apple Sign-In will work with real Face ID/Touch ID

## ✅ What Works Now

After setup, your app will have:

### **Sign-In Flow:**
- Beautiful welcome screen with Apple Sign-In button
- Option to continue without signing in (anonymous mode)
- Automatic sign-in on app restart

### **Profile Management:**
- Profile tab showing user info
- Meditation stats (sessions, minutes, streak)
- Sign out functionality
- Settings placeholder for future features

### **Data Persistence:**
- Signed-in users: Data saved with Apple ID
- Anonymous users: Data saved locally
- Seamless transition between modes

## 🔒 Privacy Features

- **Email Privacy**: Users can choose to hide their real email
- **Minimal Data**: Only stores what's needed for the app
- **Local Storage**: Meditation data stays on device
- **Easy Sign-Out**: Clear data removal option

## 🚀 Ready to Test!

1. Follow the Xcode setup steps above
2. Build and run the app
3. Try both sign-in options:
   - Sign in with Apple (full features)
   - Continue without signing in (anonymous mode)
4. Test the profile tab and sign-out functionality

Your meditation app now has professional-grade authentication! 🧘‍♀️✨ 