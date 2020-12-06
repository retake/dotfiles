#!/bin/bash -eu

### 環境変数GITHUB_AUTH_KEYにgithubの認証keyを入れて置くこと ###
# org_nameを自分の組織名に書き換えてコメントを外すこと #

# org_name='組織名'
dependabot='dependabot[bot]'
github_user='k-matsuura'
chrome_path='/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe'

repo_list() {
  curl \
    -H "Authorization: token ${GITHUB_AUTH_KEY}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/${org_name}/repos"
}

org_repo_names() {
  jq -r ".[].name"
}

pr_list() {
  curl \
    -H "Authorization: token ${GITHUB_AUTH_KEY}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${org_name}/${repo}/pulls"
}

reviewer_pr_numbers() {
  jq -r \
    "map(select(.user.login == \"${dependabot}\" \
    and .requested_reviewers[].login == \"${github_user}\")) \
    | .[].number"
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
  pr_list | reviewer_pr_numbers | open_browser
done

