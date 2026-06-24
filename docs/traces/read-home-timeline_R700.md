# Jaeger trace inspection: read-home-timeline_R700

Run: 2026-06-24 (`timestamp=20260624_221423`)

## Artifacts

- wrk2: `experiments/results/baseline-jaeger/read-home-timeline_R700/wrk2/run.txt`
- traces: `experiments/results/baseline-jaeger/read-home-timeline_R700/traces/`

## Workload

GET `/wrk2-api/home-timeline/read` at R=700. Boundary / higher-load read workload.

## wrk2 summary (from run.txt)

| Metric | Value |
| --- | --- |
| Requests/sec | 533.56 |
| Avg latency | 6.99 s |
| p50 | 6.15 s |
| p99 | 28.11 s |
| Timeouts | 0 |

The system cannot sustain 700 req/s in this run. Tail latency grows substantially versus R=600, while per-trace Jaeger durations remain two orders of magnitude lower than wrk2 percentiles.

## Selected traces

| Criterion | File | Trace ID | Duration (ms) | Spans | Services | HTTP | Warnings |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| shortest | trace_01_shortest.json | `131cfd5e0131d19d` | 18.25 | 7 | 3 | 200 | none |
| median | trace_02_median.json | `1e01db5c7c5c2cd9` | 94.99 | 7 | 3 | 200 | none |
| longest | trace_03_longest.json | `02d02ca58ccc2c34` | 215.64 | 7 | 3 | 200 | none |

## Services visible in traces

- nginx-web-server
- home-timeline-service
- post-storage-service

Same 7-span / 3-service topology as R=600.

## Interpretation

### Request path

Identical to R=600: nginx → home-timeline-service (Redis) → post-storage-service (memcached + read) → nginx response.

### Latency comparison (shortest vs longest)

| Span | Shortest (~18 ms) | Longest (~216 ms) |
| --- | ---: | ---: |
| nginx `/wrk2-api/home-timeline/read` | ~18 ms | ~216 ms |
| read_home_timeline_client (nginx) | ~small | ~154 ms |
| read_home_timeline_server | ~2 ms | ~7.8 ms |
| post_storage_read_posts_server | ~1 ms | ~3.1 ms |

Pattern matches R=600: nginx client waiting accounts for most of the spread; backend spans grow only modestly.

### Bottlenecks

Individual-trace bottleneck: nginx-side waiting before/during downstream calls. wrk2 p99 of 28 s reflects system overload and request queueing, not trace-level backend slowness.

### Comparison with R=600

| Aspect | R=600 | R=700 |
| --- | --- | --- |
| Throughput | 541.59 req/s | 533.56 req/s |
| wrk2 p50 | 1.08 s | 6.15 s |
| wrk2 p99 | 14.84 s | 28.11 s |
| Jaeger longest trace | 188.6 ms | 215.6 ms |
| Services | 3 | 3 |

Raising R from 600 to 700 does not increase throughput but sharply increases wrk2 tail latency. Jaeger trace durations increase only ~15% at the longest sample.

### Notes on data quality

No duplicate span IDs. Stable span count and service set across all samples.
