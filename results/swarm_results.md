# Docker Swarm Benchmarking Results

## Scenario 1: Resource Overhead (Idle - No Workload)
**Date:** 2026-05-06
**Tool:** `free -m`

```text
MASTER (192.168.56.10):
               total        used        free      shared  buff/cache   available
Mem:            3911         285        2169           1        1457        3387

WORKER 1:
               total        used        free      shared  buff/cache   available
Mem:            5921         244        4090           1        1585        5424

WORKER 2:
               total        used        free      shared  buff/cache   available
Mem:            5921         245        4181           2        1494        5423

WORKER 3:
               total        used        free      shared  buff/cache   available
Mem:            5921         244        3996           2        1680        5425
```

## Scenario 1: Resource Overhead (Idle with Workload)
**Date:** 2026-05-06
**Tool:** `free -m`

```text
MASTER (192.168.56.10):
               total        used        free      shared  buff/cache   available
Mem:            3911         465         285           2        3161        3154

WORKER 1:
               total        used        free      shared  buff/cache   available
Mem:            5921         508         514           2        4897        5112

WORKER 2:
               total        used        free      shared  buff/cache   available
Mem:            5921         432         146           2        5342        5181

WORKER 3:
               total        used        free      shared  buff/cache   available
Mem:            5921         315        1096           2        4509        5306
```

## Scenario 3: Microservice Performance (DeathStarBench)
**Command:** `wrk -t4 -c50 -d60s http://192.168.56.11:5000`

```text
Running 1m test @ http://192.168.56.11:5000
  4 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    17.23ms   52.07ms 780.15ms   98.31%
    Req/Sec     1.09k   129.47     1.49k    74.96%
  256000 requests in 1.00m, 402.10MB read
Requests/sec:   4259.64
Transfer/sec:      6.69MB
```

## Scenario 3: Resource Overhead (Under Peak Load)
**Tool:** `free -m` (during benchmark)

```text
MASTER (192.168.56.10):
               total        used        free      shared  buff/cache   available
Mem:            3911         496         253           2        3162        3123

WORKER 1:
               total        used        free      shared  buff/cache   available
Mem:            5921         510         512           2        4898        5111
```

## Scenario 2: Provisioning & Scaling
**Command:** `time (sudo docker service scale scaling-test=50)`

```text
verify: Service scaling-test converged

real	0m29.115s
user	0m0.502s
sys	0m0.341s
```

---
