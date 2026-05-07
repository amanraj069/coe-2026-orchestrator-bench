# Container Orchestration Engine Comparison
**Date:** 2026-05-07  
**Project:** Benchmarking K3s, Full Kubernetes, Docker Swarm, and HashiCorp Nomad on DeathStarBench (Hotel Reservation)

---

# Executive Summary

| Metric | K3s | Full Kubernetes | Docker Swarm | Nomad | Winner |
|--------|-----|-----------------|--------------|--------|--------|
| **Throughput (req/s)** | 4196.54 | 4499.73 | 4259.64 | 6861.08 | **Nomad** |
| **Average Latency (ms)** | 14.40 | 13.78 | 17.23 | 7.22 | **Nomad** |
| **P99 / Max Latency (ms)** | 370.62 | 389.21 | 780.15 | 315.04 | **Nomad** |
| **Scaling Time to 50 Replicas (s)** | 13.573 | 12.847 | 29.115 | 9.234* | **Nomad** |
| **Idle Master Memory** | 1666 Mi | 2048 Mi | 465 MB | 358 MB | **Nomad** |
| **Idle Worker Memory (avg)** | 769 Mi | 917 Mi | 244 MB | 337 MB | **Swarm** |
| **Master Memory Under Load** | 1670 Mi | 2156 Mi | 496 MB | 390 MB | **Swarm** |
| **Peak Worker Memory (max observed)** | 1041 Mi | 1156 Mi | 512 MB | 1381 MB | **Swarm** |

\* Nomad achieved **9.234s full convergence** on a clean cluster state (50/50 replicas successfully placed).  
A degraded run with lingering workloads showed **5.787s initial placement** for only 20/50 replicas before resource exhaustion delayed the remaining allocations.

---

# Detailed Scenario Analysis

## Scenario 1: Idle Resource Overhead

### K3s (`kubectl top nodes`)
- **Master:** 84m CPU (4%), 1666 Mi memory (42%)
- **Workers:** 40–77m CPU, 555–1039 Mi memory (9–17%)
- **Observation:** Lightweight Kubernetes runtime with single-binary distribution.

---

### Full Kubernetes (`kubectl top nodes`)
- **Master:** 127m CPU (6%), 2048 Mi memory (52%)
- **Workers:** 51–78m CPU, 678–1156 Mi memory (11–19%)
- **Observation:** Higher baseline memory due to separate control plane components (etcd, API server, scheduler, controller-manager, kubelet).

---

### Docker Swarm (`free -m`, idle with workload)
- **Master:** 465 MB memory
- **Workers:** 315–508 MB memory
- **Observation:** Lean memory footprint with minimal runtime overhead.

---

### HashiCorp Nomad (`free -m`, idle without workload)
- **Master:** 358 MB memory
- **Workers:** 329–347 MB memory
- **Observation:** Smallest idle footprint; Nomad + Consul ecosystem is extremely lightweight.

---

## Memory Efficiency Ranking (Lowest Idle Master Memory)

1. **Nomad:** 358 MB  
2. Docker Swarm: 465 MB  
3. K3s: 1666 Mi (~1704 MB)  
4. Full Kubernetes: 2048 Mi (~2097 MB)

---

# Scenario 2: Provisioning & Scaling Performance

## K3s

```bash
kubectl scale deployment scaling-test --replicas=50
```

**Result:** 13.573 seconds to full convergence  
**Status:** 50/50 replicas successfully running and healthy

### Observations
- Predictable convergence
- Stable scheduling behavior
- Efficient reconciliation loop

---

## Full Kubernetes

```bash
kubectl scale deployment scaling-test --replicas=50
```

**Result:** 12.847 seconds to full convergence  
**Status:** 50/50 replicas successfully running and healthy

### Observations
- Faster convergence than K3s
- Dedicated scheduler/controller-manager improved responsiveness
- Better parallel pod placement efficiency

---

## Docker Swarm

```bash
docker service scale scaling-test=50
```

**Result:** 29.115 seconds to full convergence  
**Status:** 50/50 replicas successfully running

### Observations
- Slowest orchestrator tested
- Sequential scheduling behavior noticeable
- Higher orchestration latency during rapid scale-up

---

## HashiCorp Nomad

```bash
nomad job scale scaling-test nginx=50
```

### Clean Cluster State
**Result:** 9.234 seconds to full convergence  
**Status:** 50/50 replicas successfully placed

### Degraded Cluster State
**Initial Placement:** 5.787 seconds (20/50 replicas placed)  
**Issue:** Remaining replicas blocked due to temporary memory exhaustion caused by lingering workloads.

### Observations
- Fastest scheduler response time
- Most aggressive placement strategy
- Sensitive to resource availability
- Excellent scaling efficiency when sufficient resources are available

---

## Scaling Performance Ranking

1. **Nomad:** 9.234s  
2. Full Kubernetes: 12.847s  
3. K3s: 13.573s  
4. Docker Swarm: 29.115s

---

# Scenario 3: Microservice Performance (DeathStarBench Load Test)

## K3s

```bash
wrk -t4 -c50 -d60s http://192.168.56.11:30000
```

### Results
- Requests/sec: 4196.54
- Avg Latency: 14.40ms
- Max Latency: 370.62ms
- Stdev: 19.92ms
- 48 socket timeouts
- Transfer: 396.08 MB in 60s

---

## Full Kubernetes (kubeadm + Flannel)

```bash
wrk -t4 -c50 -d60s http://192.168.56.11:30000
```

### Results
- Requests/sec: 4499.73
- Avg Latency: 13.78ms
- Max Latency: 389.21ms
- Stdev: 18.45ms
- 31 socket timeouts
- Transfer: 423.65 MB in 60s

---

## Docker Swarm

```bash
wrk -t4 -c50 -d60s http://192.168.56.11:5000
```

### Results
- Requests/sec: 4259.64
- Avg Latency: 17.23ms
- Max Latency: 780.15ms
- Stdev: 52.07ms
- Transfer: 402.10 MB in 60s

---

## HashiCorp Nomad

```bash
wrk -t4 -c50 -d60s http://192.168.56.11:5000
```

### Results
- Requests/sec: 6861.08
- Avg Latency: 7.22ms
- Max Latency: 315.04ms
- Stdev: 9.21ms
- Transfer: 647.68 MB in 60s

---

# Performance Ranking (Throughput)

1. **Nomad:** 6861.08 req/s  
   - +52.6% vs Full Kubernetes  
   - +63.7% vs K3s

2. Full Kubernetes: 4499.73 req/s  
   - +7.3% vs K3s

3. Docker Swarm: 4259.64 req/s  
   - +1.5% vs K3s

4. K3s: 4196.54 req/s

---

# Performance Ranking (Latency — Lower is Better)

1. **Nomad:** 7.22ms average  
   - 1.9x faster than Full Kubernetes  
   - 2x faster than K3s

2. Full Kubernetes: 13.78ms average  
   - 4.3% faster than K3s

3. K3s: 14.40ms average

4. Docker Swarm: 17.23ms average

---

# Tail Latency Ranking (P99 Proxy Using Max Observed Latency)

1. **Nomad:** 315.04ms  
2. K3s: 370.62ms  
3. Full Kubernetes: 389.21ms  
4. Docker Swarm: 780.15ms

---

# Key Performance Observations

- Full Kubernetes outperformed K3s by:
  - **7.3% higher throughput**
  - **4.3% lower latency**
  - **5.4% faster scaling**

- The modular Kubernetes control plane appears to provide measurable benefits under load.

- Both Kubernetes variants significantly underperformed Nomad in raw throughput and latency.

- Nomad achieved:
  - ~52% higher throughput than Full Kubernetes
  - ~64% higher throughput than K3s
  - ~50% lower latency than Kubernetes variants

- Docker Swarm remained competitive in throughput but suffered from poor tail latency consistency.

---

# Scenario 4: Resource Overhead Under Peak Load

## K3s (`kubectl top nodes`)
- **Master:** 341m CPU (17%), 1670 Mi memory (42%)
  - Overhead: +4 Mi from idle
- **Worker1:** 485m CPU (12%), 717 Mi memory (12%)
  - Overhead: +3 Mi from idle

### Observation
Minimal control plane memory growth under load.

---

## Full Kubernetes (`kubectl top nodes`)
- **Master:** 612m CPU (31%), 2156 Mi memory (55%)
  - Overhead: +108 Mi from idle
- **Worker1:** 524m CPU (13%), 1089 Mi memory (18%)
  - Overhead: +197 Mi from idle

### Observation
Dedicated control plane components increase memory usage during sustained traffic.

---

## Docker Swarm (`free -m`)
- **Master:** 496 MB memory
  - Overhead: +31 MB
- **Worker1:** 510 MB memory
  - Overhead: +2 MB

### Observation
Most memory-efficient orchestrator under load.

---

## HashiCorp Nomad (`free -m`)
- **Master:** 390 MB memory
  - Overhead: +32 MB
- **Worker1:** 1381 MB memory
  - Overhead: +1034 MB

### Observation
Aggressive workload concentration on Worker1 enabled high throughput but increased localized memory pressure.

---

# Resource Efficiency Analysis

## Memory Efficiency Under Load

1. **Docker Swarm:** +31–32 MB overhead  
2. **Nomad Master:** +32 MB overhead  
3. **K3s Master:** +4 Mi overhead  
4. **Full Kubernetes Master:** +108 Mi overhead

---

# Architectural Insights

## Kubernetes Variants: K3s vs Full Kubernetes

### K3s
- Single-binary Kubernetes distribution
- Integrated components
- Optimized for edge and lightweight deployments

### Advantages
- Lower baseline resource usage
- Simpler deployment
- Easier cluster bootstrap

### Tradeoffs
- Less modular
- Reduced observability flexibility
- Lower peak performance under stress

---

### Full Kubernetes (kubeadm)
- Fully modular control plane
- Separate etcd, scheduler, API server, controller-manager

### Advantages
- Better scalability
- Improved scheduling responsiveness
- Production-grade HA architecture
- Rich ecosystem integrations

### Tradeoffs
- Higher memory footprint
- Greater operational complexity

---

## Networking & Routing Models

### Kubernetes
- kube-proxy
- CoreDNS
- iptables/IPVS routing

### Docker Swarm
- Built-in ingress mesh
- Overlay networking

### Nomad
- Static port allocation
- Consul service discovery
- Lightweight routing path

---

## Why Nomad Performed Better

The benchmark results suggest Nomad benefits from:

1. Lower orchestration overhead  
2. Simpler networking stack  
3. More direct service discovery  
4. Reduced proxy/routing complexity  
5. Faster scheduler responsiveness

These factors likely contributed to:
- Lower latency
- Higher throughput
- Better tail latency consistency

---

# Recommendations

## For High-Performance Microservices
### → HashiCorp Nomad
Best raw throughput and latency performance.

---

## For Production Kubernetes Ecosystem Compatibility
### → Full Kubernetes
Best long-term production flexibility, tooling, and ecosystem integration.

---

## For Lightweight Kubernetes Deployments
### → K3s
Ideal for:
- Edge computing
- Homelabs
- Resource-constrained clusters
- Lightweight production environments

---

## For Minimal Resource Usage
### → Docker Swarm
Strongest memory efficiency and simplest operational model.

---

# Testing Limitations & Caveats

1. Single-host virtualized environment (32GB RAM total)
2. No WAN/network latency simulation
3. DeathStarBench favors microservice communication performance
4. No persistent/stateful workloads evaluated
5. Observability stack overhead not included
6. `wrk` load generator executed from same subnet
7. Nomad degraded run affected by residual workloads
8. Tail latency approximated using maximum observed latency rather than true percentile histograms

---

# Final Conclusion

HashiCorp Nomad demonstrated the strongest raw performance across nearly every benchmark category:
- Highest throughput
- Lowest latency
- Fastest scaling
- Lowest idle control plane overhead

However, Full Kubernetes remains the strongest overall platform for production-grade orchestration due to:
- Ecosystem maturity
- Observability tooling
- Community adoption
- Advanced scheduling capabilities
- Operational flexibility

K3s provides an excellent middle ground for lightweight Kubernetes deployments, while Docker Swarm remains attractive for simplicity and low memory consumption.

Overall:

| Use Case | Recommended Platform |
|---|---|
| Maximum Throughput & Lowest Latency | **Nomad** |
| Enterprise Kubernetes Ecosystem | **Full Kubernetes** |
| Lightweight Kubernetes | **K3s** |
| Minimal Operational Complexity | **Docker Swarm** |