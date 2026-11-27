#!/usr/bin/env bash
set -euo pipefail

first=$(curl -fsS --max-time 20 -A 'appointment-check' \
  "$API_URL&startDate=$(date +%F)&endDate=$(date -d '+6 months' +%F)" \
  | jq -r '.availableDays[0].date // empty')
echo "earliest: ${first:-none}"

now=$(TZ=Europe/Berlin date +%H%M)
if [[ ${TEST:-} == true ]]; then
  msg="Test OK, earliest: ${first:-none}"
elif [[ -n $first && $first < ${TARGET:-2027-01-20} ]]; then
  msg="Earlier slot: $first"
elif [[ $now =~ ^07[012] ]]; then
  msg="Alive, earliest: ${first:-none}"
else
  exit 0
fi

curl -fsS -d "$msg" "https://ntfy.sh/$NTFY_TOPIC" >/dev/null
