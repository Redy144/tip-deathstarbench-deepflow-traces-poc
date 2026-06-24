#!/usr/bin/env bash
# Run a single wrk2 baseline for a benchmark point.
# Output: experiments/results/baseline-jaeger/<workload>_R<rate>/wrk2/run.txt (overwrites)

set -euo pipefail

WORKLOAD="${1:?workload required}"
RATE="${2:?rate required}"

THREADS="${THREADS:-4}"
CONNECTIONS="${CONNECTIONS:-40}"
DURATION="${DURATION:-60}"

ROOT_DIR="$(git rev-parse --show-toplevel)"
SOCIAL_DIR="$ROOT_DIR/DeathStarBench/socialNetwork"
RESULTS_DIR="$ROOT_DIR/experiments/results/baseline-jaeger"

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

POINT_DIR="$RESULTS_DIR/${WORKLOAD}_R${RATE}"
OUT_DIR="$POINT_DIR/wrk2"
OUT_FILE="$OUT_DIR/run.txt"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUT_DIR"

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
