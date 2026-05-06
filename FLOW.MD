# Research Execution Flow: 2026 COE Comparison

## Phase 1: Environment & Tooling Setup
- [x] Create Vagrantfile for local VM micro-cluster (1 Master, 3 Workers).
- [x] Configure Ansible inventory.
- [x] Draft provisioning playbook for K3s.
- [x] Draft provisioning playbook for Docker Swarm.
- [ ] Draft provisioning playbook for Vanilla K8s (`k8s-setup.yml`).
- [ ] Draft provisioning playbook for HashiCorp Nomad (`nomad-setup.yml`).
- [ ] Run `vagrant up` to initialize VMs.
- [ ] Execute playbooks sequentially to verify cluster bootstrapping on each engine.

## Phase 2: Workload Containerization & Validation (Updated)
- [x] Scaffold directory structure for workloads (K8s, Swarm, Nomad).
- [x] Define ML Inference (TFServing) manifests (Fails gracefully due to AVX-VM restrictions - documented out of bounds).
- [x] Clone or adapt DeathStarBench (Hotel Reservation microservices) for K8s, Swarm.
- [ ] Write Nomad HCL specs for DeathStarBench components.
- [ ] Dry-run deployments on the cluster to verify memory constraints (8GB max per worker).
- [ ] Configure `LoadBalancer` or NodePort mapping to expose endpoints to the host `wrk2` generator.

## Phase 3: Experiment Execution
*(Note: Ensure the host machine is rebooted between engine evaluations to clear hypervisor and OS caches).*
1. **Scenario 1: Control Plane Overhead**
   - Measure Idle CPU/Memory using `pidstat` and `htop` for each engine.
2. **Scenario 2: Provisioning & Scaling**
   - Deploy a simple Nginx service, scaling from 1 to 50 replicas. Capture event timestamps for scheduling latencies.
3. **Scenario 3: Microservice Performance (DeathStarBench)**
   - Generate load using `wrk2` from host. Track P99 Tail Latency and Maximum Throughput (RPS).
4. **Scenario 4: ML Inference Efficiency**
   - Generate AI workloads against TFServing. Track Inference Latency and OOM thresholds.

## Phase 4: Data Analysis & Visualization
- [ ] Export raw system metrics and generator outputs to CSV.
- [ ] Develop Python (Pandas/Matplotlib) scripts to generate:
  - Cumulative Distribution Functions (CDFs) for Scaling/Provisioning bounds.
  - Bar charts with 95% confidence intervals for Latency/Overhead.

## Phase 5: Paper Writing
- [ ] Outline finalized.
- [ ] Draft Sections 1-3 (Intro, Related Work, Methodology).
- [ ] Draft Section 4 (Functional Comparison Matrix 2019 vs 2026).
- [ ] Draft Section 5 & 6 (Performance Data & Discussion).
- [ ] Final Review and Submission.