#!/usr/bin/env bash

cat << EOF > $2
FROM $1
LABEL authors="martin"

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (\`entrypoint.sh\`)
ENTRYPOINT ["/entrypoint.sh"]
EOF
