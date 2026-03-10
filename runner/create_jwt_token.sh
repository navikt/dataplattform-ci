#!/usr/bin/env bash

client_id=$1 # Client ID as first argument
pem=$( cat $2 ) # file path of the private key as second argument
org=$3
installation_id=$4 # Installation ID as fourth argument

now=$(date +%s)
iat=$((${now})) # Issues 60 seconds in the past
exp=$((${now} + 600)) # Expires 10 minutes in the future

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

header_json='{
    "typ":"JWT",
    "alg":"RS256"
}'
# Header encode
header=$( echo -n "${header_json}" | b64enc )

payload_json="{
    \"iat\":${iat},
    \"exp\":${exp},
    \"iss\":\"${client_id}\"
}"
# Payload encode
payload=$( echo -n "${payload_json}" | b64enc )

# Signature
header_payload="${header}"."${payload}"
signature=$(
    openssl dgst -sha256 -sign <(echo -n "${pem}") \
    <(echo -n "${header_payload}") | b64enc
)

# Create JWT
JWT="${header_payload}"."${signature}"

access_token=$(curl --request POST \
  --url "https://api.github.com/app/installations/${installation_id}/access_tokens" \
  --header "Accept: application/vnd.github+json" \
  --header "Authorization: Bearer ${JWT}" \
  --header "X-GitHub-Api-Version: 2022-11-28" | jq -r '.token')

token=$(curl --request POST \
  --url "https://api.github.com/orgs/${org}/actions/runners/registration-token" \
  --header "Accept: application/vnd.github+json" \
  --header "Authorization: Bearer ${access_token}" \
  --header "X-GitHub-Api-Version: 2022-11-28" --verbose)

echo -n "$token" | jq -r '.token'
