---
name: Express Links Paper for DATE
description: Phantom load bypass via express links in chiplet NoI — paper draft complete, targeting DATE 2026
type: project
---

## Paper: "Express Links for Chiplet Networks: Bypassing Phantom Load in Network-on-Interposer"

**Target**: DATE 2026 (6 pages + 1 ref page, IEEE format)
**Status**: First draft complete (`paper/main.tex`)

## Key Claim
Multi-hop routing in chiplet 2D grids creates "phantom load" on intermediate links (up to 200× amplification, 50% of links affected in 4×4 grid). Express links — direct connections between non-adjacent high-traffic chiplet pairs — bypass phantom load, achieving 46% latency reduction and 90% throughput improvement (BookSim-validated).

## Technique
Greedy express link placement: iteratively add the link that reduces max network congestion the most, re-routing traffic after each addition. O(L × K⁴ log K), practical for K≤16 (3 seconds).

## Key Results (BookSim cycle-accurate)
- K=16 L=72: Express +90% peak throughput, -46% latency vs adjacent-only
- Greedy 5.6× better than random placement
- Greedy 2.5× better than fully-connected (same budget)
- 3-4 express links achieve 60% of total improvement
- Robust: 9/10 seeds, all workloads (xcr 0.1-0.6), all budgets

## Paper Structure
1. Introduction: phantom load problem motivation
2. Related Work: Kite, Florets, Chiplet Actuary, CPElide (table comparison)
3. Architecture: phantom load definition, express links, greedy algorithm
4. Evaluation: BookSim main results, ablation, sensitivity, diminishing returns
5. Conclusion

## Files
- `paper/main.tex` — full paper draft
- `express_link_optimizer.py` — core algorithm + experiments
- `booksim2/src/traffic.cpp` — custom matrix traffic for BookSim
- `results/bv_express/` — BookSim validation data
- `chiplet_explorer.py` — design space exploration (coarse level)
- `noi_topology_synthesis.py` — link allocation analysis

## TODO
- [ ] Generate actual figures (matplotlib) for paper
- [ ] LaTeX compilation (need texlive)
- [ ] Proofread and tighten to 6 pages
- [ ] Add more BookSim data points if needed
