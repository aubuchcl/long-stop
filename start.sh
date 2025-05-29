#!/bin/bash
set -e

# Trap termination signals (optional diagnostic)
trap "echo 'SIGTERM caught in shell'" TERM

# Start Puma in cluster mode
exec bundle exec puma -C config/puma.rb
