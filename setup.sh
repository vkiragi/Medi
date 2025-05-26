#!/bin/bash

# Setup script for medi app

echo "🧘 Setting up medi - Simple Meditation App"
echo ""
echo "This script will help you create an Xcode project for the medi app."
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ Xcode is installed"
echo ""

# Create Xcode project
echo "📱 Creating iOS app project..."
xcodegen_installed=$(command -v xcodegen &> /dev/null && echo "yes" || echo "no")

if [ "$xcodegen_installed" = "no" ]; then
    echo "ℹ️  XcodeGen is not installed. Would you like to install it? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Installing XcodeGen..."
        brew install xcodegen
    else
        echo ""
        echo "Please create an Xcode project manually:"
        echo "1. Open Xcode"
        echo "2. Create new project → iOS → App"
        echo "3. Product Name: medi"
        echo "4. Interface: SwiftUI"
        echo "5. Language: Swift"
        echo "6. Copy all files from Sources/medi/ to your project"
        exit 0
    fi
fi

# Create project.yml for XcodeGen
cat > project.yml << EOF
name: medi
options:
  bundleIdPrefix: com.yourcompany
  deploymentTarget:
    iOS: "16.0"
targets:
  medi:
    type: application
    platform: iOS
    sources:
      - Sources/medi
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.medi
        MARKETING_VERSION: 1.0.0
        CURRENT_PROJECT_VERSION: 1
        INFOPLIST_KEY_UIApplicationSceneManifest_Generation: YES
        INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents: YES
        INFOPLIST_KEY_UILaunchScreen_Generation: YES
        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone: "UIInterfaceOrientationPortrait"
        INFOPLIST_KEY_CFBundleDisplayName: "medi"
        SWIFT_VERSION: 5.0
EOF

if [ "$xcodegen_installed" = "yes" ] || command -v xcodegen &> /dev/null; then
    echo "Generating Xcode project..."
    xcodegen generate
    echo ""
    echo "✅ Project created successfully!"
    echo ""
    echo "📂 Opening project in Xcode..."
    open medi.xcodeproj
else
    echo ""
    echo "Please follow the manual setup instructions above."
fi

echo ""
echo "🎉 Setup complete! Happy meditating!" 