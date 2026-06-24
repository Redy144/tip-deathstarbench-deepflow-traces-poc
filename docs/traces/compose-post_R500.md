# Jaeger trace inspection: compose-post_R500

Run: 2026-06-24 (`timestamp=20260624_220538`)

## Artifacts

- wrk2: `experiments/results/baseline-jaeger/compose-post_R500/wrk2/run.txt`
- traces: `experiments/results/baseline-jaeger/compose-post_R500/traces/`

## Workload

POST to `/wrk2-api/post/compose` at R=500. Stable write workload.

## wrk2 summary (from run.txt)

| Metric | Value |
| --- | --- |
| Requests/sec | 499.00 |
| Avg latency | 11.75 ms |
| p50 | 10.38 ms |
| p99 | 33.89 ms |
| Timeouts | 0 |

Throughput matches the target rate. Tail latency is modest relative to higher-load points.

## Selected traces

Export criteria: HTTP 200, service `nginx-web-server`, operation `/wrk2-api/post/compose`.

| Criterion | File | Trace ID | Duration (ms) | Spans | Services | HTTP | Warnings |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| shortest | trace_01_shortest.json | `292f9a45c1f9821a` | 5.22 | 32 | 12 | 200 | none |
| median | trace_02_median.json | `2b4c83d3fc000dd5` | 10.44 | 32 | 12 | 200 | none |
| longest | trace_03_longest.json | `1b7ef6ffcb865481` | 20.50 | 30 | 10 | 200 | none |

Note: wrk2 p50 (10.38 ms) is close to but not identical to the median Jaeger trace duration (10.44 ms). These are separate samples.

## Services visible in traces

All 12 services appear in shortest and median traces:

- nginx-web-server
- compose-post-service
- text-service
- user-mention-service
- url-shorten-service
- unique-id-service
- media-service
- user-service
- social-graph-service
- post-storage-service
- user-timeline-service
- home-timeline-service

The longest trace omits `user-service` and `media-service` spans (10 services, 30 spans) — likely optional-path branches not taken on that request, not a tracing gap.

## Interpretation

### Request path

A typical compose-post request enters through nginx (`/wrk2-api/post/compose`), fans out through compose-post-service to text parsing, mention resolution, URL shortening, media attachment, social-graph lookup, post storage, and parallel timeline writes (user-timeline and home-timeline via Redis/Mongo backends).

### Latency comparison (shortest vs longest)

| Area | Shortest (~5 ms) | Longest (~20 ms) |
| --- | ---: | ---: |
| nginx root span | ~5 ms | ~20 ms |
| compose_post_server | ~3 ms | ~17 ms |
| write_home_timeline_redis_update | ~0.47 ms | ~1.03 ms |
| write_user_timeline_mongo_insert | ~0.59 ms | ~3.54 ms |
| write_home_timeline_client | ~1.0 ms | ~3.4 ms |

Topology is the same; the longest trace is slower mainly in compose-post orchestration and user-timeline Mongo insert, with smaller but visible growth in home-timeline Redis update. The nginx span absorbs most of the end-to-end difference because it covers waiting for downstream work.

### Bottlenecks

In the longest trace, dominant time sits in `compose_post_client` / `compose_post_server` and timeline-write paths (`write_user_timeline_mongo_insert`, `write_home_timeline_client`). Home-timeline Redis is a contributor but not the sole differentiator at R=500.

### Notes on data quality

No duplicate span IDs or warnings in exported JSON. All three traces returned HTTP 200.
