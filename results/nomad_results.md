# HashiCorp Nomad Benchmarking Results

## Scenario 1: Resource Overhead (Idle - No Workload)
**Date:** 2026-05-06
**Engine:** HashiCorp Nomad v1.6.x (server/client)
**Tool:** `free -m`

```text
MASTER (192.168.56.10):
               total        used        free      shared  buff/cache   available
Mem:            3911         331         358           1        3222        3289

WORKER 1:
               total        used        free      shared  buff/cache   available
Mem:            5921         319         438           1        5162        5302

WORKER 2:
               total        used        free      shared  buff/cache   available
Mem:            5921         311         295           2        5314        5311

WORKER 3:
               total        used        free      shared  buff/cache   available
Mem:            5921         326         528           2        5067        5296
```

---
