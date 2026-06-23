# Baseline methodology

## Environment

- Benchmark: DeathStarBench Social Network
- Tracing baseline: Jaeger all-in-one 1.62.0
- Load generator: wrk2
- Duration: 60s
- Threads: 4
- Connections: 40
- Timeout: 5s
- Latency correction: enabled with `-L`

## Selected workloads

### compose-post

Main baseline:

    ../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
      -s ./wrk2/scripts/social-network/compose-post.lua \
      http://localhost:8080/wrk2-api/post/compose -R 500

High-load:

    ../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
      -s ./wrk2/scripts/social-network/compose-post.lua \
      http://localhost:8080/wrk2-api/post/compose -R 1000

### read-home-timeline

Main baseline:

    ../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
      -s ./wrk2/scripts/social-network/read-home-timeline.lua \
      http://localhost:8080/wrk2-api/home-timeline/read -R 600

Boundary/high-load:

    ../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
      -s ./wrk2/scripts/social-network/read-home-timeline.lua \
      http://localhost:8080/wrk2-api/home-timeline/read -R 700

## Running helper scripts

Baseline workloads can be executed with helper scripts from the repository root.

Run a single benchmark:

    ./experiments/scripts/run_wrk2_baseline.sh <workload> <rate>

Supported workloads:

    compose-post
    read-home-timeline

Examples:

    ./experiments/scripts/run_wrk2_baseline.sh compose-post 500
    ./experiments/scripts/run_wrk2_baseline.sh compose-post 1000
    ./experiments/scripts/run_wrk2_baseline.sh read-home-timeline 600
    ./experiments/scripts/run_wrk2_baseline.sh read-home-timeline 700

Raw wrk2 outputs are saved automatically to:

    experiments/results/baseline-jaeger/raw/

After collecting raw results, generate the averaged summary table with:

    python3 experiments/scripts/summarize_wrk2_results.py

## Current conclusion

`compose-post` remains stable at `R=500` and can handle `R=1000`, although with higher tail latency.

`read-home-timeline` is stable at `R=600`, becomes boundary-level at `R=700`, and shows overload symptoms from `R=800` upward.