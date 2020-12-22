#!/bin/bash -eu

### 環境変数GITHUB_AUTH_KEYにgithubの認証keyを入れて置くこと ###
### 環境変数GITHUB_ORG_NAMeにgithubの組織名を入れて置くこと ###

github_user='k-matsuura'
chrome_path='/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe'

repo_list() {
  curl \
    -H "Authorization: token ${GITHUB_AUTH_KEY}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/${GITHUB_ORG_NAME}/repos"
}

org_repo_names() {
  jq -r ".[].name"
}

pr_list() {
  curl \
    -H "Authorization: token ${GITHUB_AUTH_KEY}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${GITHUB_ORG_NAME}/${repo}/pulls"
}

assigned_pr_numbers() {
  jq -r "map(select(.assignee.login == \"${github_user}\" and .draft == false)) | .[].number"
}

open_browser() {
  xargs \
    -I{NUMBER} "${chrome_path}" \
    https://github.com/odt/${repo}/pull/{NUMBER}
}

repos=($(repo_list | org_repo_names | xargs))

for val in "${repos[@]}"
do
  repo=$val
  pr_list | assigned_pr_numbers | open_browser
  sleep 0.1
done

