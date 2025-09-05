#!/usr/bin/env bash

# Read key=value lines from .env
ARGS=""
while IFS='=' read -r key value; do
  # skip empty lines and comments
  if [[ -n "$key" && "$key" != \#* ]]; then
    ARGS="$ARGS --dart-define=$key=$value"
  fi
done < .env
echo "Building with args: $ARGS"
flutter build web --release $ARGS
