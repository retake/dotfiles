#!/bin/bash -eu

webhook_url= #必須
main_text=slack_test
disp_user_name=test_user
payload="{\"text\": \"${main_text}\", \"username\": \"${disp_user_name}\"}"

curl -X POST --data-urlencode "payload=${payload}" ${webhook_url}

