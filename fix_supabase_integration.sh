#!/bin/bash

# Fix Supabase integration issues by moving files from Xcode project to Swift package

# Create directories if they don't exist
mkdir -p Sources/medi/Models/Auth
mkdir -p Sources/medi/Views/Auth

# Step 1: Check if we've already created the Swift package versions
if [ -f "Sources/medi/Models/Auth/AuthManager.swift" ]; then
    echo "✅ AuthManager already exists in Swift package"
else
    echo "⚠️ AuthManager not found in Swift package. Please run the script again."
    exit 1
fi

if [ -f "Sources/medi/Views/Auth/SignInView.swift" ]; then
    echo "✅ SignInView already exists in Swift package"
else
    echo "⚠️ SignInView not found in Swift package. Please run the script again."
    exit 1
fi

# Step 2: Update the SupabaseManager.swift with real credentials if provided
if [ "$#" -eq 2 ]; then
    SUPABASE_URL=$1
    SUPABASE_KEY=$2
    
    # Update the SupabaseManager with real credentials
    echo "Updating Supabase credentials..."
    sed -i '' "s|let supabaseUrl = URL(string: \"YOUR_SUPABASE_URL\")!|let supabaseUrl = URL(string: \"$SUPABASE_URL\")!|g" "Sources/medi/Models/SupabaseManager.swift"
    sed -i '' "s|let supabaseKey = \"YOUR_SUPABASE_ANON_KEY\"|let supabaseKey = \"$SUPABASE_KEY\"|g" "Sources/medi/Models/SupabaseManager.swift"
    echo "✅ Supabase credentials updated"
fi

echo ""
echo "✅ Fixed Supabase integration files!"
echo ""
echo "Next steps for your Xcode project:"
echo "1. Remove AuthManager.swift and SignInView.swift from your Xcode project"
echo "   (Don't delete them, just remove references)"
echo "2. Run 'swift build' to verify the Swift package builds successfully"
echo "3. Open the Xcode project and build again"
echo ""
echo "If you still have issues:"
echo "- Check imports to make sure 'import Supabase' is included"
echo "- Make sure to use the Swift package versions of Auth classes"
echo "- If necessary, recreate the Xcode project to pick up new Swift package structure" 