#!/bin/bash
set -e

# Function to print error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if the designated branch is provided
if [[ -z $DESIGNATED_BRANCH ]]; then
    error_exit "Designated branch not provided."
fi

tag_version=$(echo "$CI_COMMIT_TAG" | sed 's/v//')
# Extracting the minor version (e.g., for v1.2.5, it extracts 1.2)
minor_version=$(echo "$tag_version" | cut -d. -f1,2)
RELEASE_BRANCH=release/v"$minor_version"

# Start Validation
echo "Starting Tag Validation..."

# Check if the tag format is correct
if [[ ! $CI_COMMIT_TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error_exit "Tag format is incorrect. Tags should follow the format v1.2.3"
fi

if  $(git checkout $RELEASE_BRANCH >/dev/null 2>&1) ; then
    if [[ $(git branch -a --contains tags/$CI_COMMIT_TAG 2>/dev/null) == *"$RELEASE_BRANCH"* ]]; then
        if [ $(git rev-parse "$RELEASE_BRANCH" 2>/dev/null) == "$CI_COMMIT_SHA" ]; then
            echo "Tag: "$CI_COMMIT_TAG" is within the release branch: "$RELEASE_BRANCH" and latest commit: "$CI_COMMIT_SHA""
        else
            error_exit "Within the release branch: "$RELEASE_BRANCH" but not the latest commit"
        fi
    fi
else 
    git checkout $DESIGNATED_BRANCH >/dev/null 2>&1
    if [ $(git rev-parse "$DESIGNATED_BRANCH" 2>/dev/null) == "$CI_COMMIT_SHA" ]; then
        echo "Tag: "$CI_COMMIT_TAG" is within the designated branch: "$DESIGNATED_BRANCH" and latest commit: "$CI_COMMIT_SHA""
    else
        error_exit "Commit is not in the designated branch: "$DESIGNATED_BRANCH" and the branch based on is not "$RELEASE_BRANCH""
    fi
fi