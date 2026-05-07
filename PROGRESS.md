# Project Progress & Roadmap: 2026 Container Orchestrator Benchmarking

## Overview
This project aims to compare the localized performance, resource overhead, and deployment characteristics of varying Container Orchestration Engines (K3s, Docker Swarm, Nomad) deployed on a strict 32GB RAM AMD Ryzen environment using localized VirtualBox VMs via Vagrant.

## Current Status Summary
- **Overall Completion:** ~98%
- **Current Active Phase:** Phase 6 - Synthesis & Reporting (All benchmarking complete!)
- **Current Blocker:** None. All three orchestration engines (K3s, Docker Swarm, Nomad) have been successfully benchmarked.
- **Recent Completion:** Nomad benchmarking finished (Scenarios 1, 2 degraded, 3). K3s results verified. Comprehensive comparison analysis generated.

---

## Detailed Implementation Order

### Phase 1: Local Infrastructure Provisioning (COMPLETED)
- [x] Define VM topology via `Vagrantfile` (1 Master, 3 Workers).
- [x] Configure private networking (`192.168.56.x` subnet).
- [x] Resolve SSH key distribution so `master` node can execute commands against `worker` nodes.
- [x] Integrate `ansible` inside the `master` node to bypass Windows filesystem permission bugs.
- [x] Adjust hardware profiles intelligently to prevent Windows Host OOM locks (Workers adjusted from 8GB to 6GB RAM).

### Phase 2: K3s Deployment & Workload Validation (COMPLETED)
- [x] Write generic Ansible playbook to deploy K3s control plane and join workers (`k3s-setup.yml`).
- [x] Validate K3s cluster operational status (`kubectl get nodes`).
- [x] Retrieve and apply DeathStarBench (Hotel Reservation) YAML manifests.
- [x] Patch DeathStarBench manifests to fix `RunContainerError` absolute path bugs.
- [x] Validate all microservice containers reach a `Running` state.
- [x] Expose frontend service via NodePort for benchmark ingestion.

### Phase 3: K3s Benchmarking (COMPLETED)
- [x] Set up HTTP load generator (`wrk`) on the master node.
- [x] Run localized load testing against the Hotel Reservation microservice on K3s.
- [x] Capture cluster metrics (CPU overhead, RAM overhead, P99 Request Latency, Throughput).
- [x] Save K3s metrics for final comparison.
- [x] Teardown K3s cluster.

### Phase 4: Docker Swarm Setup & Benchmarking (COMPLETED)
- [x] Finish writing Ansible playbook for Docker Swarm (`swarm-setup.yml`).
- [x] Bootstrap Swarm manager and join workers over the private subnet.
- [x] Adapt DeathStarBench manifests for Swarm (pruned and mongo downgrade).
- [x] Run identical HTTP load generator tests.
- [x] Capture Swarm metrics (resource footprint, P99 latency, throughput).
- [x] Teardown Swarm cluster.

### Phase 5: HashiCorp Nomad Setup & Benchmarking (COMPLETED)
- [x] Write Ansible playbook for Nomad & Consul deployment (`nomad-setup.yml`).
- [x] Bootstrap Nomad server/client architecture (with Docker driver installation).
- [x] Translate DeathStarBench requirements into Nomad `.hcl` job specifications.
- [x] Run identical HTTP load generator tests (Scenario 3: 6861 req/s, 7.22ms latency).
- [x] Capture Nomad metrics (Scenarios 1, 2 degraded, 3).
- [x] Fix critical infrastructure bugs (network interface eth1→enp0s8, Docker driver missing).
- [ ] Teardown Nomad cluster.
✅ COMPLETED)
- [x] Compile metrics from all 3 orchestration engines.
- [x] Analyze control-plane idle resource usage out-of-the-box.
- [x] Compare application routing performance and latency variations.
- [x] Generate comprehensive comparison analysis (`results/COMPARISON.md`).
- [x] Finalize engine performance recommendations and architectural insightatency variations.
- [x] Finalize longitudinal update reporting details.

---

## Known Bugs & Historical Decisions
1. **Host Freezing (OOM):** Trying to dedicate 28GB (1x4GB Master + 3x8GB Workers) to the Vagrant cluster triggered Host-OS Out-Of-Memory conditions when pulling large container workloads simultaneously. **Solution:** Lowered worker nodes to 6GB RAM.
2. **TFServing ML Abort:** VirtualBox translation of AMD AVX instructions triggered kernel core dumps in TensorFlow. **Solution:** Workload pivoted exclusively to Microservice architectures (DeathStarBench).
3. **Ansible & Windows:** Running Ansible from the Windows host against Vagrant caused permission issues on `id_rsa` files. **Solution:** Ansible acts *locally* from inside the `master` VM using a mapped `/vagrant` directory.