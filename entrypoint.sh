#!/bin/bash

set -e

if [ -z "$GH_TOKEN" ]
then
  echo "You must provide the action with a GitHub Personal Access Token secret in order to deploy."
  exit 1
fi

if [ -z "$BRANCH" ]
then
  echo "You must provide the action with a branch name it should deploy to, for example gh-pages or docs."
  exit 1
fi

if [ -z "$FOLDER" ]
then
  echo "You must provide the action with the folder name in the repository where your compiled page lives."
  exit 1
fi

case "$FOLDER" in /*|./*)
  echo "The deployment folder cannot be prefixed with '/' or './'. Instead reference the folder name directly."
  exit 1
esac

if [ -z "$COMMIT_EMAIL" ]
then
  COMMIT_EMAIL="${GITHUB_ACTOR}@users.noreply.github.com"
fi

if [ -z "$GH_REPOSITORY" ]
then
  GH_REPOSITORY="micronaut-projects/micronaut-docs"
fi

if [ -z "$COMMIT_NAME" ]
then
  COMMIT_NAME="${GITHUB_ACTOR}"
fi

# Installs Git.
apt-get update && \
apt-get install -y git && \

# Directs the action to the the Github workspace.
cd $GITHUB_WORKSPACE && \

# echo "Workspace Info" && \
# echo "--------------" && \
# pwd && \
# ls -l build && \
# echo "--------------" && \

# Configures Git.
git init && \
git config --global user.email "${COMMIT_EMAIL}" && \
git config --global user.name "${COMMIT_NAME}" && \


# Checks out the base branch to begin the deploy process.
git checkout "${BASE_BRANCH:-master}" && \

# Builds the project if a build script is provided.
echo "Running build scripts... $BUILD_SCRIPT" && \
eval "$BUILD_SCRIPT" && \

if [ "$CNAME" ]; then
  echo "Generating a CNAME file in in the $FOLDER directory..."
  echo $CNAME > $FOLDER/CNAME
fi


## Initializes the repository path using the access token.
REPOSITORY_PATH="https://${GH_TOKEN}@github.com/${GH_REPOSITORY}.git" && \

## Clone the docs
git clone "$REPOSITORY_PATH" -b gh-pages gh-pages --single-branch > /dev/null && \
cd gh-pages && \

  
if [ -z "$VERSION" ]
then
  echo "No Version. Publishing Snapshot of Docs"
  mkdir -p snapshot
  cp -r "../$FOLDER/." ./snapshot/
  git add snapshot/*
else 
    echo "Publishing $VERSION of Docs"
    if [ -z "$BETA" ]
    then 
      echo "Publishing Latest Docs"
      mkdir -p latest
      cp -r "../$FOLDER/." ./latest/
      git add latest/*
    fi   

    majorVersion=${VERSION:0:4}
    majorVersion="${majorVersion}x"

    mkdir -p "$majorVersion"
    cp -r "../$FOLDER/." "./$majorVersion/"
    git add "$majorVersion/*"
fi


git commit -m "Deploying to ${BRANCH} - $(date +"%T")" --quiet && \
git push "https://$GITHUB_ACTOR:$GH_TOKEN@github.com/$GH_REPOSITORY.git" gh-pages || true && \
cd .. && \
git checkout "${BASE_BRANCH:-master}" && \
echo "Deployment succesful!"
