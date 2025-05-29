#!/bin/bash
set -e

# Trap to show signal received in shell
trap "echo 'SIGTERM caught in shell'" TERM

# Start Puma with the rack app
exec bundle exec puma -C config/puma.rb config.ru
