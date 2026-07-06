# tip-deathstarbench-deepflow-traces-poc

Proof-of-concept for evaluating distributed tracing methods on DeathStarBench
Social Network.

Jaeger instrumentation tracing is the **completed baseline**. DeepFlow and
DeepTrace were evaluated as alternative approaches but **could not be
integrated** in this environment. See [docs/project-summary.md](docs/project-summary.md)
for the full evaluation narrative and conclusions.

## Repository layout

```text
.
├── DeathStarBench/          # pinned submodule (Social Network + wrk2)
├── docs/                    # methodology, findings, and evaluation notes
├── experiments/
│   ├── scripts/             # run_wrk2_baseline.sh only
│   └── results/baseline-jaeger/
├── README.md
└── REPORT.md

```

## DeathStarBench version

Pinned submodule commit: `4fba28cb3b454259d005794608c5204cf8aef461`

Fork: [https://github.com/Redy144/DeathStarBench.git](https://github.com/Redy144/DeathStarBench.git) (Jaeger all-in-one pinned to 1.62.0)

## Requirements

- Docker Compose v2
- wrk2 build tools: `make`, `gcc`, `luajit`, `libssl-dev`, `luarocks`, `luasocket`
- Python 3 + `aiohttp` (for `init_social_graph.py` only)

```bash
sudo apt-get install -y make gcc libssl-dev libz-dev luarocks python3-pip
sudo luarocks install luasocket
pip install aiohttp
```

## Setup

```bash
git clone --recurse-submodules <repo-url>
cd tip-deathstarbench-deepflow-traces-poc

cd DeathStarBench/wrk2 && make && cd ../..

cd DeathStarBench/socialNetwork
docker compose up -d
python3 scripts/init_social_graph.py --graph socfb-Reed98
```

## Running benchmarks

Single helper script (wrk2 only):

```bash
./experiments/scripts/run_wrk2_baseline.sh compose-post 500
```

Output: `experiments/results/baseline-jaeger/compose-post_R500/wrk2/run.txt` (overwritten each run).

All four benchmark points are defined in [docs/baseline-methodology.md](docs/baseline-methodology.md).

## Jaeger traces (manual)

After each wrk2 run, export three traces from Jaeger UI (`http://localhost:16686`) and save JSON to:

```text
experiments/results/baseline-jaeger/<workload>_R<rate>/traces/
```

Document findings in `docs/traces/<workload>_R<rate>.md`.

## Documentation

- [Project summary](docs/project-summary.md) — goal, evaluation path, conclusions
- [Baseline methodology](docs/baseline-methodology.md) — benchmark points, wrk2, manual Jaeger export
- [Jaeger findings](docs/jaeger-findings.md) — cross-workload synthesis and links to per-workload trace docs
- [DeepTrace evaluation log](docs/trying_out_deeptrace.md)

## Stop the stack

```bash
cd DeathStarBench/socialNetwork
docker compose down
```

## Current status

- **Jaeger baseline:** wrk2 results and 3 trace JSON files per benchmark point (2026-06-24 runs)
- **Jaeger analysis:** per-workload docs in `docs/traces/` and synthesis in `docs/jaeger-findings.md`
- **DeepFlow:** not integrated (Docker Compose vs K8s infrastructure conflict)
- **DeepTrace:** not integrated (immature tooling; see evaluation log)
