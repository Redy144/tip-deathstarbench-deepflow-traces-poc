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

```bash
../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
  -s ./wrk2/scripts/social-network/compose-post.lua \
  http://localhost:8080/wrk2-api/post/compose -R 500
```

High-load:

```bash
../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
  -s ./wrk2/scripts/social-network/compose-post.lua \
  http://localhost:8080/wrk2-api/post/compose -R 1000
```

### read-home-timeline

Main baseline:

```bash
../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
  -s ./wrk2/scripts/social-network/read-home-timeline.lua \
  http://localhost:8080/wrk2-api/home-timeline/read -R 600
```

Boundary/high-load:

```bash
../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L -T 5s \
  -s ./wrk2/scripts/social-network/read-home-timeline.lua \
  http://localhost:8080/wrk2-api/home-timeline/read -R 700
```

## Current conclusion

compose-post remains stable at R=500 and can handle R=1000, although with higher tail latency.

read-home-timeline is stable at R=600, becomes boundary-level at R=700, and shows overload symptoms from R=800 upward.