import re
from pathlib import Path
from statistics import mean

RAW_DIR = Path("experiments/results/baseline-jaeger/raw")

PATTERNS = {
    "avg_latency": r"Latency\s+([\d.]+)(ms|s)",
    "p50": r"50\.000%\s+([\d.]+)(ms|s)",
    "p90": r"90\.000%\s+([\d.]+)(ms|s)",
    "p99": r"99\.000%\s+([\d.]+)(ms|s)",
    "p999": r"99\.900%\s+([\d.]+)(ms|s)",
    "max": r"100\.000%\s+([\d.]+)(ms|s)",
    "requests_sec": r"Requests/sec:\s+([\d.]+)",
}


def to_ms(value: str, unit: str) -> float:
    value = float(value)
    return value * 1000 if unit == "s" else value


def extract_metadata(filename: str):
    workload = "read-home-timeline" if "read-home-timeline" in filename else "compose-post"
    rate_match = re.search(r"_R(\d+)_", filename)
    rate = int(rate_match.group(1)) if rate_match else None
    return workload, rate


def extract_metrics(text: str):
    result = {}

    for key, pattern in PATTERNS.items():
        match = re.search(pattern, text)

        if not match:
            result[key] = None
            continue

        if key == "requests_sec":
            result[key] = float(match.group(1))
        else:
            result[key] = to_ms(match.group(1), match.group(2))

    timeout_match = re.search(r"Socket errors:.*timeout\s+(\d+)", text)
    result["timeouts"] = int(timeout_match.group(1)) if timeout_match else 0

    return result


groups = {}

for path in RAW_DIR.glob("*.txt"):
    workload, rate = extract_metadata(path.name)
    metrics = extract_metrics(path.read_text(errors="ignore"))

    key = (workload, rate)
    groups.setdefault(key, []).append(metrics)

print("| Workload | R | Runs | Requests/sec avg | Avg latency ms | p50 ms | p90 ms | p99 ms | p99.9 ms | Max ms | Timeouts sum |")
print("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")

for (workload, rate), runs in sorted(groups.items()):
    def avg(metric):
        values = [r[metric] for r in runs if r[metric] is not None]
        return mean(values) if values else None

    print(
        f"| {workload} | {rate} | {len(runs)} | "
        f"{avg('requests_sec'):.2f} | "
        f"{avg('avg_latency'):.2f} | "
        f"{avg('p50'):.2f} | "
        f"{avg('p90'):.2f} | "
        f"{avg('p99'):.2f} | "
        f"{avg('p999'):.2f} | "
        f"{avg('max'):.2f} | "
        f"{sum(r['timeouts'] for r in runs)} |"
    )