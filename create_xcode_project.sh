#!/bin/bash

echo "🧘 Creating medi iOS App Project"
echo ""

# Create the app directory structure
mkdir -p medi
mkdir -p medi/medi

# Copy source files to the app directory
echo "📁 Copying source files..."
cp -r Sources/medi/* medi/medi/

# Create ContentView as the main view (rename from our structure)
cat > medi/medi/ContentView_Main.swift << 'EOF'
import SwiftUI

struct ContentView_Main: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MeditationView()
                .tabItem {
                    Label("Meditate", systemImage: "leaf.fill")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)
        }
        .accentColor(.purple)
    }
}
EOF

# Update MediApp.swift to use the renamed ContentView
cat > medi/medi/MediApp.swift << 'EOF'
import SwiftUI

@main
struct MediApp: App {
    @StateObject private var meditationManager = MeditationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView_Main()
                .environmentObject(meditationManager)
                .preferredColorScheme(.light)
        }
    }
}
EOF

# Remove the old ContentView.swift to avoid conflicts
rm -f medi/medi/ContentView.swift

echo ""
echo "✅ Files prepared!"
echo ""
echo "Now please follow these steps to create the Xcode project:"
echo ""
echo "1. Open Xcode"
echo "2. Choose 'Create New Project' (or File → New → Project)"
echo "3. Select 'iOS' → 'App' → Next"
echo "4. Fill in:"
echo "   • Product Name: medi"
echo "   • Team: (Select your team or None)"
echo "   • Organization Identifier: com.yourname (or any identifier)"
echo "   • Interface: SwiftUI"
echo "   • Language: Swift"
echo "   • Use Core Data: NO"
echo "   • Include Tests: NO (optional)"
echo "5. Click Next"
echo "6. IMPORTANT: When it asks where to save:"
echo "   • Navigate to: $(pwd)"
echo "   • Select the 'medi' folder we just created"
echo "   • Click Create"
echo ""
echo "7. Once created, your app will be ready to run!"
echo "8. Select an iPhone simulator from the device menu and press the Play button (▶️)"
echo ""
echo "Press Enter to open Xcode..."
read

open -a Xcode 