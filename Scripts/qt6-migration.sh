#!/bin/bash
# Qt6 Migration Script
# Fixes deprecated imports across all QML files

PROJECT_DIR="/Users/kaiwybornyprismaero/Projects/PowerTuneDigitalOfficial_Prism"

# Find all QML files
find "$PROJECT_DIR" -name "*.qml" -type f | while read file; do
    echo "Processing: $file"
    
    # Create backup
    cp "$file" "$file.bak"
    
    # Remove QtQuick.Controls.Styles 1.4 (not available in Qt6)
    sed -i '' 's/import QtQuick\.Controls\.Styles 1\.4//g' "$file"
    
    # Remove QtQuick.Extras 1.4 import (will be replaced with custom components)
    sed -i '' 's/import QtQuick\.Extras 1\.4//g' "$file"
    sed -i '' 's/import QtQuick\.Extras\.Private 1\.0//g' "$file"
    
    # Replace QtGraphicalEffects 1.0 with Qt5Compat.GraphicalEffects
    sed -i '' 's/import QtGraphicalEffects 1\.0/import Qt5Compat.GraphicalEffects/g' "$file"
    sed -i '' 's/import QtGraphicalEffects 1\.12/import Qt5Compat.GraphicalEffects/g' "$file"
    
    # Replace QtQuick.Controls 1.4 as Quick1 with comment (TabView etc)
    sed -i '' 's/import QtQuick\.Controls 1\.4 as Quick1/\/\/ TODO: Qt6 - QtQuick.Controls 1.4 removed/g' "$file"
    
    # Replace QtQuick.Dialogs 1.0 with Qt 6 version
    sed -i '' 's/import QtQuick\.Dialogs 1\.0/import QtQuick.Dialogs/g' "$file"
    sed -i '' 's/import QtQuick\.Dialogs 1\.2/import QtQuick.Dialogs/g' "$file"
    sed -i '' 's/import QtQuick\.Dialogs 1\.3/import QtQuick.Dialogs/g' "$file"
    
    # Fix duplicate imports
    sed -i '' '/^[[:space:]]*$/d' "$file"
    
    # Remove backup
    rm "$file.bak"
done

echo "Migration complete!"
