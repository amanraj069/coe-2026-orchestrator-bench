# K3s Benchmarking Results

## Validation Run (2026-05-06)
**Command:** `wrk -t2 -c10 -d10s http://192.168.56.11:30000`

```text
Running 10s test @ http://192.168.56.11:30000
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     5.04ms    9.77ms  56.83ms   91.03%
    Req/Sec     1.19k   372.17     2.13k    74.14%
  6868 requests in 10.05s, 10.79MB read
Requests/sec:    683.56
Transfer/sec:      1.07MB
```

## Scenario 1: Resource Overhead (Idle with Workload)
**Date:** 2026-05-06
**Tool:** `kubectl top nodes`

```text
NAME      CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
master    84m          4%       1666Mi          42%         
worker1   40m          1%       714Mi           12%         
worker2   56m          1%       555Mi           9%          
worker3   77m          1%       1039Mi          17%         
```

## Scenario 3: Microservice Performance (DeathStarBench)
**Command:** `wrk -t4 -c50 -d60s http://192.168.56.11:30000`

```text
Running 1m test @ http://192.168.56.11:30000
  4 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    14.40ms   19.92ms 370.62ms   85.34%
    Req/Sec     1.13k   365.28     2.97k    70.63%
  252166 requests in 1.00m, 396.08MB read
  Socket errors: connect 0, read 0, write 0, timeout 48
Requests/sec:   4196.54
Transfer/sec:      6.59MB
```

## Scenario 3: Resource Overhead (Under Peak Load)
**Tool:** `kubectl top nodes` (during benchmark)

```text
NAME      CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
master    341m         17%      1670Mi          42%         
worker1   485m         12%      717Mi           12%         
worker2   51m          1%       556Mi           9%          
worker3   96m          2%       1041Mi          17%         
```

## Scenario 2: Provisioning & Scaling
**Command:** `time (kubectl scale deployment scaling-test --replicas=50 && kubectl rollout status deployment scaling-test)`

```text
deployment "scaling-test" successfully rolled out

real	0m13.573s
user	0m0.192s
sys	0m0.170s
```

---
