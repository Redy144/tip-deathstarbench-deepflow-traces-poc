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

## Manual Smoke Workloads

Run these from `DeathStarBench/socialNetwork`.

Compose post:

```bash
../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L \
  -s ./wrk2/scripts/social-network/compose-post.lua \
  http://localhost:8080/wrk2-api/post/compose -R 5
```

Read home timeline:

```bash
../wrk2/wrk -D exp -t 4 -c 40 -d 60 -L \
  -s ./wrk2/scripts/social-network/read-home-timeline.lua \
  http://localhost:8080/wrk2-api/home-timeline/read -R 5
```

## Stop the Stack

```bash
cd DeathStarBench/socialNetwork
docker compose down
```

## Plan

1. Confirm that the upstream Social Network stack starts reliably.
2. Confirm that the social graph initialization and basic workloads work.
3. Inspect the traces already produced in Jaeger.
4. Decide what data should be collected from Jaeger for the PoC.
5. Plan the DeepFlow setup as a second observation method.
6. Compare Jaeger instrumentation with DeepFlow observation on the same
   Social Network workloads.
7. Add another DeathStarBench application only if the Social Network comparison
   is stable and useful.
