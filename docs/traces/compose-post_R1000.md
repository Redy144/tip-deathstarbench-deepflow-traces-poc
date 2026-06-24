# Jaeger trace inspection: compose-post_R1000

Run: 2026-06-24 (`timestamp=20260624_220708`)

## Artifacts

- wrk2: `experiments/results/baseline-jaeger/compose-post_R1000/wrk2/run.txt`
- traces: `experiments/results/baseline-jaeger/compose-post_R1000/traces/`

## Workload

POST to `/wrk2-api/post/compose` at R=1000. Higher-load write workload.

## wrk2 summary (from run.txt)

| Metric | Value |
| --- | --- |
| Requests/sec | 729.56 |
| Avg latency | 9.19 s |
| p50 | 8.95 s |
| p99 | 17.15 s |
| Timeouts | 0 |

The system does not sustain the target rate of 1000 req/s under this configuration. Aggregate wrk2 latency is orders of magnitude higher than individual Jaeger trace durations — wrk2 reflects queueing and contention across thousands of concurrent requests, not single-request service time.

## Selected traces

| Criterion | File | Trace ID | Duration (ms) | Spans | Services | HTTP | Warnings |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| shortest | trace_01_shortest.json | `268aaad8442de4c2` | 6.10 | 32 | 12 | 200 | none |
| median | trace_02_median.json | `082eca87d4103aa3` | 19.79 | 32 | 12 | 200 | none |
| longest | trace_03_longest.json | `174d3a708f62ad84` | 49.93 | 32 | 12 | 200 | none |

## Services visible in traces

Same 12-service topology as R=500:

- nginx-web-server, compose-post-service, text-service, user-mention-service, url-shorten-service, unique-id-service, media-service, user-service, social-graph-service, post-storage-service, user-timeline-service, home-timeline-service

## Interpretation

### Request path

Identical microservice graph to R=500. compose-post-service orchestrates text, mentions, URLs, media, storage, and dual timeline updates.

### Latency comparison (shortest vs longest)

| Area | Shortest (~6 ms) | Longest (~50 ms) |
| --- | ---: | ---: |
| nginx root span | ~6 ms | ~50 ms |
| compose_post_server | ~4 ms | ~45 ms |
| write_home_timeline_redis_update | ~0.25 ms | ~3.89 ms |
| write_home_timeline_client | ~0.72 ms | ~5.77 ms |
| write_user_timeline_mongo_insert | ~0.71 ms | ~1.55 ms |

Under load, timeline-write spans (especially home-timeline Redis and client waits) grow more than at R=500, but the largest absolute gap remains in compose-post and nginx orchestration spans.

### Bottlenecks

At R=1000 the longest trace shows `compose_post_server` (~45 ms) and home-timeline paths (`write_home_timeline_client` ~5.8 ms, `write_home_timeline_redis_update` ~3.9 ms) as the main backend contributors. wrk2 tail latency (seconds) is not explained by these per-trace spans alone — it reflects system-wide saturation.

### Comparison with R=500

| Aspect | R=500 | R=1000 |
| --- | --- | --- |
| Throughput | ~499 req/s (on target) | ~730 req/s (below target) |
| wrk2 p50 | 10.38 ms | 8.95 s |
| Jaeger longest trace | 20.5 ms | 49.9 ms |
| Services in trace | 12 | 12 |

Individual traces scale roughly 2–3× in duration; aggregate wrk2 latency scales far more due to overload.

### Notes on data quality

No duplicate span IDs. All traces HTTP 200.
