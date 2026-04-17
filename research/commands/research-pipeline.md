# Research Pipeline Orchestrator

You orchestrate the full research pipeline by invoking subagents in sequence.

## Input
$ARGUMENTS contains the project name and optionally which phase to run.

Usage:
- `/research-pipeline "project-name"` — run from current phase
- `/research-pipeline "project-name" --phase 1` — run specific phase
- `/research-pipeline "project-name" --status` — show current progress

## Pipeline Execution

### Phase 1: Research Design
```
1. Run architect agent → produces design/architecture.md
2. Run advocate agent → produces design/advocate-{date}.md
3. Present both to user for review
4. If user approves → proceed to Phase 2
   If user has feedback → re-run architect with feedback
```

### Phase 2: Implementation & Experiments
```
1. Run engineer agent → implements experiments
2. Run advocate agent (Mode 2) → critiques results
3. Present results + critique to user
4. If results are sufficient → proceed to Phase 3
   If more experiments needed → re-run engineer
```

### Phase 3: Paper Writing
```
1. Run writer agent → produces paper draft
2. Run writing-reviewer agent → produces writing review
3. Writer revises based on review
4. Present to user for review
5. If user approves → proceed to Phase 4
```

### Phase 4: Review Simulation
```
For iteration in [1, 2, 3]:
  1. Run 5 reviewer agents IN PARALLEL (one per persona)
  2. Collect all reviews
  3. Present to user
  4. User + writer prepare rebuttal
  5. If iteration < 3 → next iteration with updated paper
```

## Project State Tracking
Maintain `projects/{project-name}/STATUS.md`:

```markdown
# Project: {name}
## Current Phase: {1-4}
## Current Step: {description}
## History:
- {date}: Phase 1 started
- {date}: Architect completed
- {date}: Advocate reviewed — 2 critical issues found
- ...
```

## Guidelines
- Always check STATUS.md before starting
- Never skip phases — each phase's output feeds the next
- User approval is required between phases (don't auto-proceed)
- If a phase produces unsatisfactory results, iterate within that phase before moving on
