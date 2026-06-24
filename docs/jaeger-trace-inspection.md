# Jaeger trace inspection

Per-workload trace inspection lives in `docs/traces/`. Cross-workload synthesis is in [jaeger-findings.md](jaeger-findings.md).

Methodology (wrk2 + manual Jaeger export): [baseline-methodology.md](baseline-methodology.md).

## Quick links

| Workload | Rate | Documentation |
| --- | ---: | --- |
| compose-post | 500 | [compose-post_R500.md](traces/compose-post_R500.md) |
| compose-post | 1000 | [compose-post_R1000.md](traces/compose-post_R1000.md) |
| read-home-timeline | 600 | [read-home-timeline_R600.md](traces/read-home-timeline_R600.md) |
| read-home-timeline | 700 | [read-home-timeline_R700.md](traces/read-home-timeline_R700.md) |

## Trace JSON files

```text
experiments/results/baseline-jaeger/<workload>_R<rate>/traces/
```

DeepFlow comparison plan: [comparison-methodology.md](comparison-methodology.md).
