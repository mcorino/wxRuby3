#!/usr/bin/env bash

cat << EOF > $3
FROM $1:$2
LABEL authors="martin"

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (\`entrypoint.sh\`)
ENTRYPOINT ["/entrypoint.sh"]
EOF
