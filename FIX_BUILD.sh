#!/bin/bash

# SermonFlow: Senior Release Manager Build Reset Script
# Objective: Eliminate DerivedData corruption and build-state drift.

echo "🚀 Resetting SermonFlow build environment..."

# 1. Kill Xcode to prevent file locks
echo "--- Killing Xcode..."
killall Xcode 2>/dev/null

# 2. Clear DerivedData
echo "--- clearing DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Sermon_Flow-*
rm -rf ~/Library/Developer/Xcode/DerivedData/sermonflow-*

# 3. Reset Swift Package Manager Caches
echo "--- Resetting SPM caches..."
# This forces Xcode to re-resolve Firebase and StoreKit dependencies on next open
rm -rf .swiftpm/xcode/package.resolved

# 4. Clean local build artifacts
# No BUILD_DIR specified, relying on DerivedData wipe.

echo "✅ Environment neutralized. Open Sermon Flow.xcodeproj and perform a 'Product > Archive' for submission."
