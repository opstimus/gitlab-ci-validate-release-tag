# GitLab CI - Validate release tag

## Requirements

This shell script is used to check and verify the tags created in GitLab when deploying to production. This script needs a variable named `$DESIGNATED_BRANCH` to execute.
It should be the trunk/main production release branch, It can be added as an env variable in the pipeline or can be passed when starting the script.
Moreover, this script needs the following variables to be set as well.

```
GIT_STRATEGY: fetch
GIT_DEPTH: 0
```

## Implementation

A new job/stage should be created in the following manner.

```
validate_tag:
  stage: validate_tag
  script: - curl -sSL -o validate_tag.sh https://raw.githubusercontent.com/{PATH TO THE SCRIPT IN THE REPO} - chmod +x validate_tag.sh # Ensure the script is executable - ./validate_tag.sh || exit 1 # Execute the script and exit with error if validation fails
  only: - /^v[0-9]+\.[0-9]+\.[0-9]+$/
```
  
All the other jobs/stages that should be validated should have the below attributes set
```
  rules: - if: '$CI_COMMIT_TAG'
  needs: - job: validate_tag
```
