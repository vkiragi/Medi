#!/bin/bash

if [ -f "medi/medi.xcodeproj/project.pbxproj" ]; then
    echo "Opening medi.xcodeproj..."
    open medi/medi.xcodeproj
else
    echo "❌ medi.xcodeproj not found!"
    echo "Please create the Xcode project first by:"
    echo "1. Opening Xcode"
    echo "2. Creating new iOS App project"
    echo "3. Saving it in the 'medi' folder"
fi 