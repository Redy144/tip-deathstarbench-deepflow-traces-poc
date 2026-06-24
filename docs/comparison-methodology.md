# Comparison methodology: Jaeger vs DeepFlow

This document defines how the PoC will compare Jaeger instrumentation with DeepFlow. DeepFlow is not yet integrated.

## Shared experiment setup

Same four benchmark points as [baseline-methodology.md](baseline-methodology.md):

| Workload | Rate | Role |
| --- | ---: | --- |
| compose-post | 500 | stable write |
| compose-post | 1000 | higher-load write |
| read-home-timeline | 600 | stable read |
| read-home-timeline | 700 | boundary read |

Same wrk2 parameters: 60s, 4 threads, 40 connections, `-L`, 5s timeout.

Same manual trace selection per point: shortest, median, longest (HTTP 200).

## Artifact layout

Jaeger baseline:

```text
experiments/results/baseline-jaeger/<workload>_R<rate>/
├── wrk2/run.txt
└── traces/trace_01_shortest.json
    traces/trace_02_median.json
    traces/trace_03_longest.json
```

DeepFlow baseline (planned, same structure):

```text
experiments/results/baseline-deepflow/<workload>_R<rate>/
├── wrk2/run.txt
└── traces/...
```

Interpretation stays in `docs/traces/` (and later a DeepFlow-specific section or directory if needed).

## Comparison dimensions

| Dimension | Jaeger | DeepFlow (to measure) |
| --- | --- | --- |
| Service visibility | manual inspection in UI | TBD |
| Request path | instrumentation spans | eBPF / network-level |
| Latency attribution | per-span durations | TBD |
| Tail latency | per-trace manual analysis | TBD |
| Data quality | e.g. duplicate span IDs | TBD |
| Operational overhead | per-service instrumentation | agent-based |
| Workflow | wrk2 script + manual export | same wrk2; manual or tool-specific export |

## Procedure for DeepFlow phase

1. Deploy DeepFlow alongside DeathStarBench Social Network.
2. Run wrk2 with `./experiments/scripts/run_wrk2_baseline.sh` for each benchmark point.
3. Export three representative traces/spans manually (or with DeepFlow UI/tools).
4. Document in `docs/traces/` or a dedicated comparison section.
5. Update [jaeger-findings.md](jaeger-findings.md) with side-by-side summary.

## Success criteria

- All four benchmark points run under both methods
- Three traces per point documented for each method
- Written comparison of visibility, bottlenecks, and limitations

## Out of scope

- Hotel Reservation or other DeathStarBench apps
- Automated trace clustering
- Python analysis scripts in this repository
