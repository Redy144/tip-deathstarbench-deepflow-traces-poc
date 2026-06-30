# Baseline methodology

This document covers the **Jaeger baseline** — the only tracing method
successfully integrated in this PoC. See [project-summary.md](project-summary.md)
for the full evaluation context.

This document is the single source of truth for benchmark points, wrk2 runs, and manual Jaeger trace export.

## Environment

- Benchmark: DeathStarBench Social Network
- Tracing: Jaeger all-in-one 1.62.0
- Load generator: wrk2
- Results: `experiments/results/baseline-jaeger/<workload>_R<rate>/`

Default wrk2 parameters:

- Duration: 60s
- Threads: 4
- Connections: 40
- Timeout: 5s
- Latency correction: `-L`

## Benchmark points

| Workload | Rate | Role | wrk2 URL | Jaeger operation (nginx-web-server) |
| --- | ---: | --- | --- | --- |
| compose-post | 500 | stable write | `http://localhost:8080/wrk2-api/post/compose` | `/wrk2-api/post/compose` |
| compose-post | 1000 | higher-load write | same | `/wrk2-api/post/compose` |
| read-home-timeline | 600 | stable read | `http://localhost:8080/wrk2-api/home-timeline/read` | `/wrk2-api/home-timeline/read` |
| read-home-timeline | 700 | boundary read | same | `/wrk2-api/home-timeline/read` |

## Prerequisites

1. Social Network stack running (`docker compose up -d` in `DeathStarBench/socialNetwork`)
2. Social graph initialized once (`python3 scripts/init_social_graph.py --graph socfb-Reed98`)
3. wrk2 built (`make` in `DeathStarBench/wrk2`)

## Running wrk2

From the repository root:

```bash
./experiments/scripts/run_wrk2_baseline.sh <workload> <rate>
```

Examples:

```bash
./experiments/scripts/run_wrk2_baseline.sh compose-post 500
./experiments/scripts/run_wrk2_baseline.sh compose-post 1000
./experiments/scripts/run_wrk2_baseline.sh read-home-timeline 600
./experiments/scripts/run_wrk2_baseline.sh read-home-timeline 700
```

Output (overwritten on each run):

```text
experiments/results/baseline-jaeger/<workload>_R<rate>/wrk2/run.txt
```

Equivalent manual command (compose-post, R=500):

```bash
cd DeathStarBench/socialNetwork
../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
  -s ./wrk2/scripts/social-network/compose-post.lua \
  http://localhost:8080/wrk2-api/post/compose -R 500
```

Record key metrics from `run.txt` (Requests/sec, latency percentiles) in `docs/traces/<workload>_R<rate>.md` when documenting results.

## Jaeger trace export (manual)

After the wrk2 run finishes, export traces from Jaeger UI (`http://localhost:16686`).

### When to export

Export traces **immediately after** the wrk2 run for that benchmark point, while Jaeger still contains requests from that workload window.

### How to select three traces

For each benchmark point, pick three successful requests (HTTP 200) for the operation listed in the table above:

| File | Criterion | How to choose |
| --- | --- | --- |
| `trace_01_shortest.json` | shortest | lowest total duration among successful traces |
| `trace_02_median.json` | median / typical | duration close to the middle of observed traces |
| `trace_03_longest.json` | longest | highest total duration among successful traces |

In Jaeger UI: search by service `nginx-web-server` and the operation for that workload. Sort or compare durations manually.

### Where to save

```text
experiments/results/baseline-jaeger/<workload>_R<rate>/traces/
├── trace_01_shortest.json
├── trace_02_median.json
└── trace_03_longest.json
```

Export JSON from Jaeger UI (trace detail → JSON export or API copy).

### Important: wrk2 metrics vs Jaeger traces

wrk2 reports **aggregate** latency (p50, p99, etc.) over thousands of requests.

The three Jaeger traces are **individual requests** chosen manually. They are not automatically equal to wrk2 percentiles. Do not assume that the shortest Jaeger trace equals wrk2 p50.

Document both wrk2 summary (from `run.txt`) and per-trace observations separately in `docs/traces/`.

## Trace inspection documentation

Per workload: `docs/traces/<workload>_R<rate>.md` (filled in manually after export).

Cross-workload synthesis: [jaeger-findings.md](jaeger-findings.md).

## Results layout

```text
experiments/results/baseline-jaeger/
├── compose-post_R500/
│   ├── wrk2/run.txt
│   └── traces/          # manual JSON exports
├── compose-post_R1000/
├── read-home-timeline_R600/
└── read-home-timeline_R700/
```

## Results and interpretation

This file defines how the baseline was collected. The cross-workload results
and interpretation are maintained in [jaeger-findings.md](jaeger-findings.md).
Per-workload notes live in [docs/traces/](traces/).
