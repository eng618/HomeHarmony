#!/bin/bash

# Function to trim whitespace/newlines
trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

# Sanitize variables
FIREBASE_API_KEY=$(trim "$FIREBASE_API_KEY")
FIREBASE_AUTH_DOMAIN=$(trim "$FIREBASE_AUTH_DOMAIN")
FIREBASE_PROJECT_ID=$(trim "$FIREBASE_PROJECT_ID")
FIREBASE_STORAGE_BUCKET=$(trim "$FIREBASE_STORAGE_BUCKET")
FIREBASE_MESSAGING_SENDER_ID=$(trim "$FIREBASE_MESSAGING_SENDER_ID")
FIREBASE_APP_ID=$(trim "$FIREBASE_APP_ID")
FIREBASE_MEASUREMENT_ID=$(trim "$FIREBASE_MEASUREMENT_ID")

flutter run "$@" \
  --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
  --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
  --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID" \
  --dart-define=FIREBASE_MEASUREMENT_ID="$FIREBASE_MEASUREMENT_ID"
