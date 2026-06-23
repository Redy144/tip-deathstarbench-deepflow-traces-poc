# tip-deathstarbench-deepflow-traces-poc

Proof-of-concept repository for new methods of collecting and analysing
distributed traces in distributed applications.

At this stage the repository is intentionally minimal. It contains a pinned fork of 
the upstream DeathStarBench repository as a git submodule. The fork is used to keep 
a small compatibility fix for Jaeger tracing in the Social Network benchmark.

## Current Scope

For the first PoC we use only `DeathStarBench/socialNetwork`.

Why Social Network first:

- it is already available in DeathStarBench;
- it contains multiple microservices, Nginx/OpenResty, MongoDB, Redis, and
  Memcached;
- it already includes Jaeger tracing in the DeathStarBench Docker Compose setup;
- it has ready workload scripts for common user actions.

Other DeathStarBench applications, such as Hotel Reservation, should be added
only later as a validation step after the Social Network workflow is clear.

## Repository Layout

```text
.
├── DeathStarBench/   # pinned DeathStarBench fork submodule
├── docs/             # methodology and experiment notes
├── experiments/      # benchmark scripts and collected results
├── .gitmodules       # submodule definition
└── README.md         # project setup and plan
```

## DeathStarBench Version

Pinned submodule commit:

```text
4fba28cb3b454259d005794608c5204cf8aef461
```

Submodule source:

```text
https://github.com/Redor144/DeathStarBench.git
```
This fork pins the Jaeger all-in-one Docker image to jaegertracing/all-in-one:1.62.0,
because using latest may result in missing Social Network services in Jaeger UI.

## Requirements

- Docker Desktop or Docker Engine
- Docker Compose v2
- Python 3 with `aiohttp`
- Build tools for wrk2: `make`, `gcc`, `luajit`, `libssl-dev`, `luarocks`,
  `luasocket`

On Ubuntu-like systems, the local dependencies are roughly:

```bash
sudo apt-get update
sudo apt-get install -y make gcc libssl-dev libz-dev luarocks
sudo luarocks install luasocket
```

## Clone

```bash
git clone --recurse-submodules <repo-url>
cd tip-deathstarbench-deepflow-traces-poc
```

If the repository was cloned without submodules:

```bash
git submodule update --init --recursive
```

## Build wrk2

DeathStarBench uses wrk2 for workload generation.

```bash
cd DeathStarBench/wrk2
make
cd ../..
```

## Start Social Network

Use the Docker Compose file from the pinned DeathStarBench submodule:

```bash
cd DeathStarBench/socialNetwork
docker compose up -d
```

Useful URLs:

| Service | URL |
| --- | --- |
| Social Network frontend | http://localhost:8080 |
| Media frontend | http://localhost:8081 |
| Jaeger UI | http://localhost:16686 |

Basic checks:

```bash
curl -I http://localhost:8080
curl http://localhost:16686/api/services
```

## Initialize Social Graph

Run this once after the stack is up:

```bash
python3 scripts/init_social_graph.py --graph socfb-Reed98
```

Basic application probe:

```bash
curl 'http://localhost:8080/wrk2-api/home-timeline/read?user_id=0&start=0&stop=10'
```

## Baseline Experiments

The Jaeger-based baseline is documented in:

- [Baseline methodology](docs/baseline-methodology.md)
- [Baseline results summary](experiments/results/baseline-jaeger/summary/baseline-summary.md)

Raw wrk2 outputs are stored in:

```text
experiments/results/baseline-jaeger/raw/
```

Helper scripts are stored in:

```text
experiments/scripts/
```

Use the methodology document for exact workload commands and selected request rates.

## Stop the Stack

```bash
cd DeathStarBench/socialNetwork
docker compose down
```

## Current Status

- DeathStarBench Social Network is used as the first PoC target.
- The repository uses a pinned DeathStarBench fork submodule with Jaeger all-in-one pinned to `1.62.0`.
- The Social Network stack starts correctly with Docker Compose.
- The social graph can be initialized with `socfb-Reed98`.
- A Jaeger-based wrk2 baseline has been collected for selected workloads.
- Baseline methodology, raw wrk2 outputs, helper scripts, and averaged results are stored in the repository.

## Next Steps

1. Inspect selected traces in Jaeger for the baseline workloads.
2. Decide which Jaeger trace data should be exported or described in the PoC.
3. Plan the DeepFlow setup as a second observation method.
4. Run the same workloads with DeepFlow enabled.
5. Compare Jaeger instrumentation with DeepFlow-based observation.
6. Document differences, limitations, and possible next experiments.
7. Add another DeathStarBench application only if the Social Network comparison is stable and useful.