#!/bin/bash

# Flutter Web App Deployment Script for GitHub Pages
# This script builds and deploys your Flutter web app to GitHub Pages

set -e  # Exit on any error

echo "🚀 Starting deployment process..."
echo ""

# Configuration
REPO_NAME="weave_llm_leaderboard"
BASE_HREF="/$REPO_NAME/"

# Get commit message from user or use default
if [ -z "$1" ]; then
    COMMIT_MSG="Update app: $(date '+%Y-%m-%d %H:%M:%S')"
else
    COMMIT_MSG="$1"
fi

echo "📦 Commit message: $COMMIT_MSG"
echo ""

# Step 1: Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean
echo "✅ Clean complete"
echo ""

# Step 2: Get dependencies
echo "📥 Getting dependencies..."
flutter pub get
echo "✅ Dependencies updated"
echo ""

# Step 3: Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release --base-href=$BASE_HREF
if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi
echo ""

# Step 4: Add all changes to git
echo "📝 Adding changes to git..."
git add .
echo "✅ Changes staged"
echo ""

# Step 5: Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit"
else
    # Commit changes
    echo "💾 Committing changes..."
    git commit -m "$COMMIT_MSG"
    echo "✅ Changes committed"
    echo ""
fi

# Step 6: Push to main branch
echo "⬆️  Pushing to main branch..."
git push origin main
echo "✅ Pushed to main"
echo ""

# Step 7: Force add build/web (in case .gitignore blocks it)
echo "📂 Adding build/web folder..."
git add -f build/web
if ! git diff --staged --quiet; then
    git commit -m "Add production build for deployment"
    git push origin main
    echo "✅ Build folder added"
else
    echo "ℹ️  Build folder already up to date"
fi
echo ""

# Step 8: Deploy to gh-pages using subtree
echo "🌐 Deploying to GitHub Pages..."
git subtree push --prefix build/web origin gh-pages
if [ $? -eq 0 ]; then
    echo "✅ Deployment successful!"
else
    echo "❌ Deployment failed"
    echo ""
    echo "💡 If you see an error about rejected updates, try:"
    echo "   git push origin \`git subtree split --prefix build/web main\`:gh-pages --force"
    exit 1
fi
echo ""

echo "🎉 Deployment complete!"
echo ""
echo "Your app should be live at:"
echo "https://bdytx5.github.io/$REPO_NAME/"
echo ""
echo "Note: It may take 1-2 minutes for GitHub Pages to update."
