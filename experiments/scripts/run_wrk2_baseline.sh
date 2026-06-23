#!/usr/bin/env bash

set -euo pipefail

WORKLOAD="${1}"
RATE="${2}"
THREADS="${3:-4}"
CONNECTIONS="${4:-40}"
DURATION="${5:-60}"

ROOT_DIR="$(git rev-parse --show-toplevel)"
SOCIAL_DIR="$ROOT_DIR/DeathStarBench/socialNetwork"
OUT_DIR="$ROOT_DIR/experiments/results/baseline-jaeger/raw"

mkdir -p "$OUT_DIR"

case "$WORKLOAD" in
  compose-post)
    SCRIPT="./wrk2/scripts/social-network/compose-post.lua"
    URL="http://localhost:8080/wrk2-api/post/compose"
    ;;
  read-home-timeline)
    SCRIPT="./wrk2/scripts/social-network/read-home-timeline.lua"
    URL="http://localhost:8080/wrk2-api/home-timeline/read"
    ;;
  *)
    echo "Unknown workload: $WORKLOAD"
    echo "Use: compose-post or read-home-timeline"
    exit 1
    ;;
esac

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
OUT_FILE="$OUT_DIR/${TIMESTAMP}_${WORKLOAD}_R${RATE}_t${THREADS}_c${CONNECTIONS}_d${DURATION}.txt"

cd "$SOCIAL_DIR"

{
  echo "# workload=$WORKLOAD"
  echo "# rate=$RATE"
  echo "# threads=$THREADS"
  echo "# connections=$CONNECTIONS"
  echo "# duration=$DURATION"
  echo "# timestamp=$TIMESTAMP"
  echo

  ../wrk2/wrk -D exp \
    -t "$THREADS" \
    -c "$CONNECTIONS" \
    -d "$DURATION" \
    -L \
    -T 5s \
    -s "$SCRIPT" \
    "$URL" \
    -R "$RATE"

  echo
  echo "# docker compose ps"
  docker compose ps
} | tee "$OUT_FILE"

echo
echo "Saved to: $OUT_FILE"