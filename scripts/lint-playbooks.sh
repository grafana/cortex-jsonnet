#!/bin/sh
SCRIPT_DIR=$(realpath $(dirname $0))

# List all alerts.
ALERTS=$(yq eval '.groups.[].rules.[].alert' "${SCRIPT_DIR}/../cortex-mixin/out/alerts.yaml" 2> /dev/stdout)
if [ $? -ne 0 ]; then
  echo "Unable to list alerts. Got output:"
  echo "$ALERTS"
  exit 1
fi

# Check if each alert is referenced in the playbooks.
STATUS=0

for ALERT in $ALERTS; do
  grep --quiet "$ALERT" "${SCRIPT_DIR}/../cortex-mixin/docs/playbooks.md"
  if [ $? -ne 0 ]; then
    echo "Missing playbook for: $ALERT"
    STATUS=1
  fi
done

exit $STATUS
