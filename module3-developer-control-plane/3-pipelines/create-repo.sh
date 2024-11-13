#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <gitea-username>"
    exit 1
fi

# Input parameters
GITEA_USER="$1"

# Variables
GITHUB_REPO_URL="https://github.com/wesreisz/tilt-avatars.git"
GITEA_URL="http://gitea-http.gitea.svc.cluster.local:3000"  # Update with your Gitea instance URL
GITEA_REPO_NAME="tilt-avatars"  # New repository name in Gitea

# Step 1: Clone the GitHub repository
echo "Cloning the GitHub repository..."
git clone $GITHUB_REPO_URL
cd $GITEA_REPO_NAME || exit

# Step 2: Remove the GitHub remote origin
echo "Removing GitHub remote origin..."
git remote rm origin

# Step 3: Create a new repository in Gitea using the API
echo "Creating a new repository in Gitea..."
curl -u "$GITEA_USER:$GITEA_PASSWORD" \
     -X POST "$GITEA_URL/api/v1/user/repos" \
     -H "Content-Type: application/json" \
     -d "{\"name\":\"$GITEA_REPO_NAME\",\"private\":false}"

# Step 4: Add Gitea as a new remote
GITEA_REPO_URL="$GITEA_URL/$GITEA_USER/$GITEA_REPO_NAME.git"
echo "Adding Gitea as the new remote..."
git remote add origin $GITEA_REPO_URL

# Step 5: Push the code to the new Gitea repository
echo "Pushing the code to Gitea..."
git push -u origin main

echo "Repository successfully cloned and pushed to Gitea."
