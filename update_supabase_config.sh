#!/bin/bash

# Script to update Supabase URL and anon key in SupabaseManager.swift

# Usage check
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <supabase_url> <supabase_anon_key>"
    echo "Example: $0 \"https://abcdefghijklmn.supabase.co\" \"eyJhbGciOiJIUzI1NiIsInR...\""
    exit 1
fi

SUPABASE_URL=$1
SUPABASE_KEY=$2
MANAGER_FILE="Sources/medi/Models/SupabaseManager.swift"

if [ ! -f "$MANAGER_FILE" ]; then
    echo "Error: SupabaseManager.swift not found at $MANAGER_FILE"
    exit 1
fi

# Replace the URL
sed -i '' "s|let supabaseUrl = URL(string: \"YOUR_SUPABASE_URL\")!|let supabaseUrl = URL(string: \"$SUPABASE_URL\")!|g" "$MANAGER_FILE"

# Replace the key
sed -i '' "s|let supabaseKey = \"YOUR_SUPABASE_ANON_KEY\"|let supabaseKey = \"$SUPABASE_KEY\"|g" "$MANAGER_FILE"

echo "✅ Supabase configuration updated in SupabaseManager.swift"
echo "URL: $SUPABASE_URL"
echo "Key: ${SUPABASE_KEY:0:5}...${SUPABASE_KEY: -5}"
echo ""
echo "Next steps:"
echo "1. Build and run your project"
echo "2. Sign in with Apple or use anonymous mode"
echo "3. Navigate to Profile tab to see sync options"
echo ""
echo "Note: The first sync may take a few moments as tables are created if they don't exist." 