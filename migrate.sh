#!/usr/bin/env bash

# Do you want to prefix the new GitHub repositories with anything? Example: "migrated-"
PREFIX_GITHUB=""

# The Bitbucket user (or organisation) slug. Example: "district5"
BITBUCKET_USER=""

# The GitHub organisation slug. Example: "district-5"
GITHUB_USER=""

# The GitHub organisation ID to migrate into (see README.md). Example: "district-5"
GITHUB_ORGANISATION_ID=""

# Add your repo names. No '/' characters, just the name. Example: REPO_NAMES="my-repo my-other-repo"
REPO_NAMES=""

if [ "${BITBUCKET_USER}" == "" ]; then
  echo "BITBUCKET_USER must be completed."
  exit 1
fi
if [ "${GITHUB_USER}" == "" ]; then
  echo "GITHUB_USER must be completed."
  exit 1
fi
if [ "${GITHUB_ORGANISATION_ID}" == "" ]; then
  echo "GITHUB_ORGANISATION_ID must be completed."
  exit 1
fi
if [ "${REPO_NAMES}" == "" ]; then
  echo "REPO_NAMES must be completed."
  exit 1
fi

SKIP="0"
if [ "${1}" == "--now" ]; then
  SKIP="1"
fi

DIRECTORY=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "${DIRECTORY}" || exit

countItDown() {
  secs=$(( ${1#0} ))
  number_seconds=${#secs}
  while [ $secs -gt -1 ]
  do
    sleep 1 &
    if [ "${secs}" == "1" ]; then
      printf "\r${2}%${number_seconds}d second " $((secs))
    else
      printf "\r${2}%${number_seconds}d seconds" $((secs))
    fi
    secs=$(( secs - 1 ))
    wait
  done
  printf "\r                                                \n"
}

run_for_repo() {
  REPO_NAME=${1}
  BITBUCKET_CLONE_URL="git@bitbucket.org:${BITBUCKET_USER}/${REPO_NAME}.git"

  if [ -z "${REPO_NAME}" ]; then
    echo "Missing repository"
    echo "
      Usage: ./migrate.sh
    "
    exit 1
  fi


  echo "--------"
  echo "| Repo: ${BITBUCKET_USER}/${REPO_NAME}"
  echo "|  URL: ${BITBUCKET_CLONE_URL}"
  echo "--------"

  if [ -d "${DIRECTORY}/tmp/${REPO_NAME}" ]; then
    rm -rf "${DIRECTORY}/tmp/${REPO_NAME}"
  fi

  cd "${DIRECTORY}/tmp" || exit
  echo "--------"
  echo "|"
  echo "| Mirroring..."
  echo "|"
  echo "--------"
  git clone "${BITBUCKET_CLONE_URL}" "./${REPO_NAME}" --mirror
  cd "${DIRECTORY}/tmp/${REPO_NAME}" || exit

  _=$(gh api -i graphql -f query="mutation {createRepository(input: {name: \"${PREFIX_GITHUB}${REPO_NAME}\", visibility: PRIVATE, ownerId: \"${GITHUB_ORGANISATION_ID}\"}){repository {url}}}")
  git remote set-url origin "git@github.com:${GITHUB_USER}/${PREFIX_GITHUB}${REPO_NAME}.git"
  git push origin --mirror
  cd "${DIRECTORY}" || exit
  rm -rf "${DIRECTORY}/tmp/${REPO_NAME}"
}

for REPO in ${REPO_NAMES}; do
  if [ "${SKIP}" != "1" ]; then
    RAND=$(jot -r 1  300 900)
    countItDown "$RAND" "Beginning next repo \"${REPO}\" in "
  fi
  run_for_repo "${REPO}"
done
