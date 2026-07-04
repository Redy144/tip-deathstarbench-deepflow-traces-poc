# Jaeger trace inspection: read-home-timeline_R600

Run: 2026-06-24 (`timestamp=20260624_221305`, after stack restart following compose-post runs)

## Artifacts

- wrk2: `experiments/results/baseline-jaeger/read-home-timeline_R600/wrk2/run.txt`
- traces: `experiments/results/baseline-jaeger/read-home-timeline_R600/traces/`

## Workload

GET `/wrk2-api/home-timeline/read` at R=600. Stable read workload.

## wrk2 summary (from run.txt)

| Metric | Value |
| --- | --- |
| Requests/sec | 541.59 |
| Avg latency | 2.70 s |
| p50 | 1.08 s |
| p99 | 14.84 s |
| Timeouts | 0 |

Throughput is below the 600 req/s target. R=600 is the lower read bracket in this design; saturation effects (high wrk2 p50, queueing) appear even before R=700. Runs were sequential with a stack restart before read benchmarks (see methodology). wrk2 latency is high despite individual Jaeger traces completing in tens to low hundreds of milliseconds — indicating client-side queueing under sustained fixed-rate load rather than multi-second single-request backend paths (see also [jaeger-findings.md](../jaeger-findings.md) on the wrk2 vs Jaeger gap).

## Selected traces

Jaeger operation: `/wrk2-api/home-timeline/read`, service: `nginx-web-server`.

| Criterion | File | Trace ID | Duration (ms) | Spans | Services | HTTP | Warnings |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| shortest | trace_01_shortest.json | `10c98d0710f7ebb2` | 11.49 | 7 | 3 | 200 | none |
| median | trace_02_median.json | `1f7a2e4ada8b3184` | 75.55 | 7 | 3 | 200 | none |
| longest | trace_03_longest.json | `21cc7266e63b4f7c` | 188.57 | 7 | 3 | 200 | none |

## Services visible in traces

- nginx-web-server
- home-timeline-service
- post-storage-service

Every trace has exactly 7 spans across 3 services — a narrow, consistent graph.

## Interpretation

### Request path

nginx receives the read request → `read_home_timeline_client` → home-timeline-service (`read_home_timeline_server`, Redis lookup) → post-storage-service (`post_storage_read_posts_server`, memcached mget) → response assembly in nginx.

### Latency comparison (shortest vs longest)

| Span | Shortest (~11 ms) | Longest (~189 ms) |
| --- | ---: | ---: |
| nginx `/wrk2-api/home-timeline/read` | ~11 ms | ~189 ms |
| read_home_timeline_client (nginx) | ~small | ~133 ms |
| read_home_timeline_server | ~2 ms | ~5.5 ms |
| post_storage_read_posts_server | ~1 ms | ~3.8 ms |
| redis_find_client | ~0.2 ms | ~0.2 ms |

Backend spans differ by only a few milliseconds. The longest trace is dominated by nginx client-side waiting (~133 ms of ~189 ms total), not by Redis or post-storage service time.

### Bottlenecks

For individual traces, nginx queueing/waiting is the primary variance source. Backend home-timeline and post-storage work stays sub-10 ms even in the longest sample.

### Notes on data quality

No duplicate span IDs. Consistent 7-span structure across all three traces.
