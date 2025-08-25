#!/bin/bash

if pgrep -x "Twingate" > /dev/null; then
  # Twingate is running
  :
else
    exit 1
fi

curl -f -m 0.5 --output /dev/null http://healthcheck.infra.bde-insa-lyon.fr
# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
    exit 0
else
    exit 1
fi

