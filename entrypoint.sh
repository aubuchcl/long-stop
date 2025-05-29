#!/bin/bash

# Default to 180 seconds if not set
DELAY=${SHUTDOWN_DELAY:-180}

function shutdown() {
  echo "Signal received. Waiting $DELAY seconds before shutting down..."
  sleep "$DELAY"
  echo "Exiting now."
  exit 0
}

trap shutdown SIGTERM SIGINT

echo "Container started with shutdown delay of $DELAY seconds. PID $$"
while true; do
  sleep 1
done
