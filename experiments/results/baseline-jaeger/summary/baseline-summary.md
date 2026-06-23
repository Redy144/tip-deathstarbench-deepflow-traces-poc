# Baseline results summary

All results are averaged over 3 runs.

## Results

| Workload           |    R | Runs | Requests/sec avg | Avg latency ms | p50 ms | p90 ms | p99 ms | p99.9 ms | Max ms | Timeouts sum |
| ------------------ | ---: | ---: | ---------------: | -------------: | -----: | -----: | -----: | -------: | -----: | -----------: |
| compose-post       |  500 |    3 |           499.06 |           4.06 |   3.76 |   5.36 |   8.50 |    23.27 |  36.36 |            0 |
| compose-post       | 1000 |    3 |           995.10 |           6.62 |   4.85 |   9.78 |  41.19 |    98.64 | 162.48 |            0 |
| read-home-timeline |  600 |    3 |           596.84 |           7.19 |   4.39 |  12.74 |  48.34 |   121.44 | 220.20 |            0 |
| read-home-timeline |  700 |    3 |           696.33 |          19.11 |   4.86 |  36.09 | 287.83 |   668.84 | 877.57 |            0 |

## Conclusions

`compose-post` is stable at `R=500`. At `R=1000`, throughput remains close to the target rate, but tail latency increases.

`read-home-timeline` is stable at `R=600`, but it has higher tail latency than `compose-post`. At `R=700`, the workload becomes a boundary/high-load case.

No socket timeouts were observed in the averaged benchmark runs.
