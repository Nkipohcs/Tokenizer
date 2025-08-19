#!/bin/bash
# Script to initialize a git repository and push it to GitHub.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Initializing Git repository ---"
git init

echo "--- Adding all files to staging ---"
git add .

echo "--- Committing files ---"
# Check if there are any changes to commit
if [ -n "$(git status --porcelain)" ]; then
  git commit -m "feat: initial commit of the BEP-20 Tokenizer project"
else
  echo "No changes to commit."
fi

echo "--- Renaming branch to main ---"
git branch -M main

echo "--- Adding remote origin ---"
# Remove remote if it exists, then add it. This prevents errors on re-runs.
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:Nkipohcs/Tokenizer.git

echo "--- Pushing to GitHub ---"
git push -u origin main

echo "--- Script finished successfully! ---"
