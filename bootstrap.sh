#!/bin/bash

#########################################################################
# Setup Environment
#########################################################################
echo "Setting up environment"

if [ "${PGID}" == "0" ]; then
  export USERGROUP=root
else
  addgroup -g ${PGID} ${USERGROUP}
fi

if [ "${PUID}" == "0" ]; then
  export USER=root
else
  adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "${USERGROUP}" \
    --uid "${PUID}" \
    "${USER}"
fi

su ${USER} -c /entrypoint.sh