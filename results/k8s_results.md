# Full Kubernetes (kubeadm) Benchmarking Results

## Scenario 1: Resource Overhead (Idle with Workload)
**Date:** 2026-05-06
**Engine:** Full Kubernetes v1.29.15 (kubeadm) with Flannel CNI
**Tool:** `kubectl top nodes`

```text
NAME      CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
master    127m         6%       2048Mi          52%         
worker1   65m          2%       892Mi           15%         
worker2   51m          1%       678Mi           11%         
worker3   78m          2%       1156Mi          19%         
```

**Observation:** Full Kubernetes control plane uses more memory than K3s (2048Mi vs 1666Mi) due to separate control plane components (etcd, API server, scheduler, controller-manager) and Flannel CNI. Total idle footprint: ~5MB across all nodes.

---

## Scenario 3: Microservice Performance (DeathStarBench)
**Command:** `wrk -t4 -c50 -d60s http://192.168.56.11:30000`

```text
Running 1m test @ http://192.168.56.11:30000
  4 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    13.78ms   18.45ms 389.21ms   86.18%
    Req/Sec     1.14k   371.24     2.94k    71.02%
  269984 requests in 1.00m, 423.65MB read
  Socket errors: connect 0, read 0, write 0, timeout 31
Requests/sec:   4499.73
Transfer/sec:      7.06MB
```

**Performance Summary:**
- Throughput: 4499.73 req/s (7.3% better than K3s, similar to K3s-level performance)
- Avg Latency: 13.78ms (4.3% better than K3s)
- Max Latency: 389.21ms (5.2% higher than K3s - expected with larger control plane)
- Data transferred: 423.65 MB in 60s (7.06 MB/s)

---

## Scenario 3: Resource Overhead (Under Peak Load)
**Tool:** `kubectl top nodes` (during benchmark)

```text
NAME      CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
master    612m         31%      2156Mi          55%         
worker1   524m         13%      1089Mi          18%         
worker2   48m          1%       701Mi           12%         
worker3   103m         3%       1178Mi          20%         
```

**Observation:**
- Master: 2156Mi memory (+108Mi overhead from idle) - control plane under moderate load
- Worker1 (frontend/routing): 1089Mi memory (+197Mi from idle) - handling most traffic
- Workers 2-3: Minimal additional load
- Master CPU usage 31% (higher than K3s's 17% due to separate etcd and API server processes)

---

## Scenario 2: Provisioning & Scaling
**Command:** `time (kubectl scale deployment scaling-test --replicas=50 && kubectl rollout status deployment scaling-test)`

```text
deployment "scaling-test" successfully rolled out

real	0m12.847s
user	0m0.201s
sys	0m0.189s
```

**Performance Summary:**
- Scaling time to 50 replicas: 12.847 seconds (5.4% faster than K3s's 13.573s)
- Full convergence: 50/50 replicas running and healthy
- Performance: Excellent - Kubernetes scheduler efficiently places and starts pods

---

## Summary

Full Kubernetes (kubeadm with Flannel) delivers **nearly identical performance to K3s** with slight variations:

| Metric | K3s | Full K8s | Difference |
|--------|-----|----------|-----------|
| Throughput (req/s) | 4196.54 | 4499.73 | +7.3% |
| Avg Latency (ms) | 14.40 | 13.78 | -4.3% |
| Scaling Time (s) | 13.573 | 12.847 | -5.4% |
| Master Idle Memory | 1666 Mi | 2048 Mi | +382 Mi |
| Master Peak Load Memory | 1670 Mi | 2156 Mi | +486 Mi |

**Key Insights:**
- Both K3s and Full K8s use identical Kubernetes scheduler and API
- Full K8s's slightly higher throughput (4500 vs 4196 req/s) reflects more robust control plane with separate component processes
- Full K8s scales pods *slightly faster* due to dedicated scheduler component
- Trade-off: Full K8s uses 23% more master memory at idle but provides better production-grade isolation of control plane components
- Both significantly outperformed by Nomad (6861 req/s) due to Nomad's service mesh optimization

