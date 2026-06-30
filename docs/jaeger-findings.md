# Jaeger findings (cross-workload synthesis)

This document summarizes Jaeger observations across all four benchmark points. Per-workload detail is in the linked files below.

Methodology: [baseline-methodology.md](baseline-methodology.md)

Runs collected: 2026-06-24 (sequential wrk2 + immediate Jaeger export per point).

## Quick links

| Workload | R | wrk2 result | Trace inspection |
| --- | ---: | --- | --- |
| compose-post | 500 | `.../compose-post_R500/wrk2/run.txt` | [compose-post_R500.md](traces/compose-post_R500.md) |
| compose-post | 1000 | `.../compose-post_R1000/wrk2/run.txt` | [compose-post_R1000.md](traces/compose-post_R1000.md) |
| read-home-timeline | 600 | `.../read-home-timeline_R600/wrk2/run.txt` | [read-home-timeline_R600.md](traces/read-home-timeline_R600.md) |
| read-home-timeline | 700 | `.../read-home-timeline_R700/wrk2/run.txt` | [read-home-timeline_R700.md](traces/read-home-timeline_R700.md) |

Trace JSON files are stored in:

```text
experiments/results/baseline-jaeger/<workload>_R<rate>/traces/
```

## Summary table

| Workload | R | Services | Spans (typical) | Main bottleneck (per-trace) | wrk2 note | Warnings |
| --- | ---: | ---: | ---: | --- | --- | --- |
| compose-post | 500 | 12 | 32 | compose-post orchestration; timeline writes on slow traces | On target (~499 req/s) | none |
| compose-post | 1000 | 12 | 32 | compose-post + home-timeline Redis under load | Saturated (~730 req/s, multi-second p50) | none |
| read-home-timeline | 600 | 3 | 7 | nginx client waiting | Below target (~542 req/s) | none |
| read-home-timeline | 700 | 3 | 7 | nginx client waiting | Below target (~534 req/s), high tail | none |

## Write vs read workloads

**compose-post (write)** exposes a wide service graph (~12 services, ~32 spans). Short and long traces share the same topology; latency differences come from span duration growth across orchestration and timeline-write paths, not from different call graphs.

**read-home-timeline (read)** is narrow (~3 services, 7 spans). Variance between shortest and longest traces is dominated by nginx-side waiting (`read_home_timeline_client`), while home-timeline Redis and post-storage spans stay in the low milliseconds.

## wrk2 vs Jaeger: two layers of latency

wrk2 reports aggregate client-side latency over thousands of requests. Jaeger traces are individual successful requests. In this baseline:

- At R=500 compose-post, wrk2 p50 (~10 ms) is in the same ballpark as Jaeger trace durations (5–20 ms).
- At higher load (R=1000 compose-post, R=600/700 read), wrk2 p50 reaches seconds while Jaeger traces remain in milliseconds to low hundreds of milliseconds.

This gap indicates queueing and contention under sustained load — visible in wrk2 but not fully explained by inspecting a handful of individual traces.

## What Jaeger makes easy

- Identifying all services participating in a single request
- Comparing short vs long traces with the same topology
- Locating which spans grow on slow individual requests
- Confirming HTTP status and span structure per request

## What remains difficult

- Explaining multi-second wrk2 latency from a few hand-picked traces
- Aggregating patterns across thousands of requests without tooling
- Separating nginx queueing time from backend service time in client spans
- Observing behavior outside instrumented code paths — one motivation for
  exploring eBPF / zero-instrumentation tools (see [project-summary.md](project-summary.md))

## Context within the PoC

Alternative tracing methods (DeepFlow, DeepTrace) were not integrated in this
PoC. The Jaeger findings above represent the only complete tracing dataset
collected. See [project-summary.md](project-summary.md) for why those
alternatives could not be evaluated and what that implies for the stability of
new tracing approaches.
