Bitbucket to GitHub organisation migration
====

## Overview:

This tool migrates Bitbucket repositories into a GitHub organisation by creating a full mirror locally, creating the new
GitHub repository and pushing.

## Requirements:

Install the [GitHub CLI tool](https://github.com/cli/cli) and authenticate with: `gh auth login`

## Options:

In the `migrate.sh` script, there are several options at the top of the file.

* `PREFIX_GITHUB` - Prefix the new repository name with this. For example, migrating a repository called 'foo' with a
  prefix of 'migrated-' would create a repository in GitHub called 'migrated-foo'.
* `BITBUCKET_USER` - The username (or organisation name) of the Bitbucket user. Example: `district-5`.
* `GITHUB_USER` - The GitHub organisation name to migrate into. Example: `district-5`.
* `GITHUB_ORGANISATION_ID` - The organisation ID, as returned by the GitHub CLI tool. (See below for getting this).
* `REPO_NAMES` - The list of repository names to migrate. Just the name, not the full path. Example: 
  `repo1 repo-2 other-repo`

## Getting the organisation ID:

After installing the GitHub CLI tool, run this code below to gain your Organisation ID (replacing 
`<MY ORGANISATION NAME>`) with your organisation name.

```
gh api graphql -f query='{ organization(login:"<MY ORGANISATION NAME>") { id } }'
```

Should output the following. Where `A1b2C3d4E5f6G7h8I9j0A1b2C3d4E5f6G7h8I9j0` would be your organisation ID:

```json
{
  "data": {
    "organization": {
      "id": "A1b2C3d4E5f6G7h8I9j0A1b2C3d4E5f6G7h8I9j0"
    }
  }
}
```
