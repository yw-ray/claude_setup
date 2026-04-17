---
name: Chiplet NoI Research Exploration
description: Austin Rovinski PhD direction — chiplet partitioning optimization with RL/GNN for EDA
type: project
---

Youngwoo explored a potential PhD research direction under Austin Rovinski (NYU Tandon) focused on chiplet-based chip design automation.

**Why:** Rovinski's lab specializes in OpenROAD (open-source EDA), chiplet I/O libraries, and ML for EDA. Chiplet design is becoming mandatory as AI chips exceed reticle limits (858mm²).

**Key research question:** "Automatic chiplet partitioning with performance-cost co-optimization" — given an RTL netlist + workload, find the optimal way to split into chiplets (NP-hard).

**What was built (2026-04-02~03):**
- Analytical cost model (v4): found cost crossover at ~800mm² total area
- BookSim cycle-accurate NoI simulation: showed dense inter-chiplet links achieve 87% monolithic throughput, NoI reduces latency penalty from 82% to 20%
- RL partitioning environment: Gymnasium env + REINFORCE + GNN policy
- GNN > MLP confirmed (33.5% vs 39.6% inter-chiplet comm)
- But RL still behind Spectral clustering (33% vs 7% comm)

**Breakthrough (2026-04-03):** Spectral init + RL refinement BEATS Spectral by 2.6% (best) / 1.2% (avg) on multi-objective score. RL improves thermal score from 0.67→0.78 while maintaining comm/balance. This validates the hypothesis: RL adds value by optimizing physical constraints Spectral can't see.

**Next steps to make it a paper:**
1. Heterogeneous process assignment (Affinity dimension — currently 1.0 for all)
2. Larger netlists (100+ modules) for generalization
3. Different workload traffic patterns (Transformer vs CNN)
4. BookSim cycle-accurate integration as reward signal
5. GNN end-to-end policy for structure-aware refinement

**How to apply:** RL's value is in multi-constraint optimization that Spectral can't do. The Spectral+RL hybrid pattern works.

**Code location:** `projects/chiplet-noi-analysis/`
