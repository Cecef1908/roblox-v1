#!/bin/bash
# deploy-hub.sh — Sync HTML hub files from main to gh-pages
# Usage: ./scripts/deploy-hub.sh
# This script is safe to run repeatedly. It only pushes if there are changes.

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Files to deploy
FILES=(index.html dashboard.html map.html lore.html)

echo "=== Deploying Hub to gh-pages ==="

# Ensure we're on main and up to date
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "ERROR: Must be on main branch (currently on $CURRENT_BRANCH)"
    exit 1
fi

# Check all required files exist
for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing $f on main"
        exit 1
    fi
done

# Stash any local changes
STASHED=false
if ! git diff --quiet || ! git diff --cached --quiet; then
    git stash push -m "deploy-hub auto-stash"
    STASHED=true
fi

# Switch to gh-pages and sync
git checkout gh-pages

for f in "${FILES[@]}"; do
    git checkout main -- "$f"
done
git checkout main -- deploy/ 2>/dev/null || true

# Commit and push if changes
git add "${FILES[@]}" deploy/
if git diff --cached --quiet; then
    echo "No changes to deploy."
else
    git commit -m "Deploy hub from main — $(date +%Y-%m-%d\ %H:%M)"
    git push origin gh-pages
    echo "Deployed successfully!"
fi

# Switch back to main
git checkout main

# Restore stash
if [ "$STASHED" = true ]; then
    git stash pop
fi

echo "=== Done ==="
echo "Live URL: https://cecef1908.github.io/roblox-v1/"
echo "Password: goldrush2026"
