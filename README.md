# tip-deathstarbench-deepflow-traces-poc

Proof-of-concept repository for new methods of collecting and analysing
distributed traces in distributed applications.

DeathStarBench Social Network is the benchmark. Jaeger is the current tracing
baseline. DeepFlow comparison is planned for a later phase.

## Repository layout

```text
.
├── DeathStarBench/          # pinned submodule (Social Network + wrk2)
├── docs/                    # methodology and manual trace inspection notes
├── experiments/
│   ├── scripts/             # run_wrk2_baseline.sh only
│   └── results/baseline-jaeger/
└── README.md
```

## DeathStarBench version

Pinned submodule commit: `4fba28cb3b454259d005794608c5204cf8aef461`

Fork: [https://github.com/Redor144/DeathStarBench.git](https://github.com/Redor144/DeathStarBench.git) (Jaeger all-in-one pinned to 1.62.0)

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

- [Baseline methodology](docs/baseline-methodology.md) — benchmark points, wrk2, manual Jaeger export
- [Per-workload trace inspection](docs/traces/)
- [Jaeger findings](docs/jaeger-findings.md)
- [Comparison methodology (Jaeger vs DeepFlow)](docs/comparison-methodology.md)
- [Trying out the DeepTrace](docs/trying_out_deeptrace.md)

## Stop the stack

```bash
cd DeathStarBench/socialNetwork
docker compose down
```

## Current status

- wrk2 baseline: one `run.txt` per benchmark point (2026-06-24 runs)
- Jaeger traces: 3 JSON files per point in `*/traces/` (shortest, median, longest)
- `docs/traces/`: filled in with wrk2 metrics and trace interpretation
- `docs/jaeger-findings.md`: cross-workload synthesis

## Next steps

1. Integrate DeepFlow and repeat the same four benchmark points
2. Compare Jaeger vs DeepFlow using [comparison-methodology.md](docs/comparison-methodology.md)

