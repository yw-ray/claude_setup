---
name: Chiplet NoI Topology Synthesis Research
description: Current research direction — traffic-aware NoI link allocation for chiplet accelerators, pivoted from partitioning
type: project
---

## Current Direction (as of 2026-04-06)

**Paper topic**: Traffic-Aware NoI Topology Synthesis — given chiplet partition + workload traffic + link budget, optimally allocate inter-chiplet links.

**Why:** Pivoted from "throughput-aware partitioning" because:
1. Partitioning barely affects throughput (compute-dominated for LLM workloads)
2. Link allocation has much larger impact (BookSim showed 4-5× latency difference)
3. Multi-hop routing load on intermediate links is the key factor that naive allocation misses

## Key Findings

**Load-aware allocation beats uniform by 2-4× in max congestion (ρ):**
- K=8, 64 links: uniform max_ρ=23.5, load-aware max_ρ=6.7 (3.5× better)
- K=8 big, 64 links: uniform max_ρ=38.5, load-aware max_ρ=17.0 (2.3× better)
- Traffic-proportional is WORSE than uniform (ignores multi-hop load)

**BookSim validation (partial):**
- Spectral links (traffic-proportional) beat uniform at lat@0.02: 45.7 vs 230 for spectral workload traffic
- SA concentrated links were worst — confirms that bottleneck link kills performance
- Custom `matrix` traffic pattern added to BookSim source (traffic.cpp)

**Failed approaches:**
- RL partitioning: couldn't beat Spectral (action space too large, signal too weak)
- SA partitioning with throughput objective: model was wrong (average vs bottleneck congestion)
- Traffic concentration strategy: sounds good analytically but BookSim shows bottleneck dominates

## What Needs to Be Done

1. **Fix BookSim config filenames** — remove `=` and `×` from filenames (BookSim parses `=` as config override)
2. **Run BookSim validation** for load-aware vs uniform vs traffic-proportional with custom matrix traffic
3. **Formulate as LP/ILP** — min max_ρ subject to link budget, proper optimization
4. **Multiple workloads** — not just one netlist, try H100-like, MI300X-like, CNN vs Transformer traffic
5. **Paper writing** — DAC/DATE 6-page format

## Code Locations

- `noi_topology_synthesis.py` — main synthesis + evaluation code
- `booksim2/src/traffic.cpp` — modified with `MatrixTrafficPattern` class
- `rl_partitioner/sa_coopt_v2.py` — SA experiments (partitioning, multiple model iterations)
- `rl_partitioner/envs/placement_aware_evaluator.py` — grid-based evaluator
- `rl_partitioner/envs/realistic_netlist.py` — H100/MI300X-like netlist generators
- `rl_partitioner/defense_experiments.py` — defense experiment results

## How to apply
When continuing this research, start from `noi_topology_synthesis.py`. The key contribution is load-aware link allocation (accounting for multi-hop routing load), validated against BookSim cycle-accurate simulation.
