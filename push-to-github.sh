#!/bin/bash

# GIDYO - Push to GitHub Script
# Run this after creating your GitHub repository

# Replace YOUR_USERNAME with your actual GitHub username
GITHUB_USERNAME="AlexandreC1"
REPO_NAME="gidyo"

echo "🚀 Pushing GIDYO to GitHub..."

# Add remote (if not already added)
git remote add origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git" 2>/dev/null || echo "Remote already exists"

# Set main branch
git branch -M main

# Push to GitHub
echo "📤 Pushing to GitHub..."
git push -u origin main

echo "✅ Done! Your project is now on GitHub at:"
echo "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
