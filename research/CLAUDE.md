# Research Agent System

연구 논문 작성을 위한 multi-agent 파이프라인.

## Phases

| Phase | Agents | 목적 |
|-------|--------|------|
| 1. Research Design | architect + advocate | RQ → 실험 설계 |
| 2. Implementation | engineer + advocate | 코드 구현 + 실험 |
| 3. Paper Writing | writer + writing-reviewer | 논문 draft |
| 4. Review Simulation | 5 reviewers × 3 iterations | 사전 리뷰 |

## Commands

- `/research-architect` — 연구 설계 (RQ, 방법론, 실험 계획)
- `/research-advocate` — 반론/약점 분석, 스토리 강화
- `/research-engineer` — 구현 및 실험 실행
- `/research-writer` — 논문 작성
- `/research-writing-reviewer` — 논문 문장/구조 리뷰
- `/research-reviewer` — 학회 리뷰어 시뮬레이션
- `/research-pipeline` — 전체 파이프라인 오케스트레이션

## Directory Structure

```
research/
├── CLAUDE.md
├── .claude/commands/          # Agent command definitions
├── projects/                  # 연구 프로젝트별 디렉토리
│   └── {project-name}/
│       ├── design/            # Phase 1 outputs
│       ├── experiments/       # Phase 2 code + results
│       ├── paper/             # Phase 3 drafts
│       └── reviews/           # Phase 4 review logs
└── templates/                 # 공통 템플릿
```

## Paper Writing Principles

논문은 반드시 **명확한 주장(thesis)**이 있어야 한다. findings를 나열하는 것이 아니라, 하나의 스토리 라인으로 관통해야 한다.

### 필수 스토리 구조

1. **흐름/발전**: "이 분야는 이런 방향으로 발전하고 있다" (e.g., chiplet 수가 늘어나고 있다)
2. **문제 발생**: "이 흐름에서 이런 문제가 생긴다" (e.g., phantom load가 발생한다)
3. **기존 한계**: "기존 접근들은 이러한 한계 때문에 해결하지 못한다" (e.g., adjacent-only 전략은 근본 원인을 제거 못한다)
4. **우리의 주장**: "우리는 이것을 해결한다 / 이것이 핵심이라고 주장한다" (e.g., topology 개입이 필수이며, workload에 따라 전략이 달라야 한다)

### Abstract 작성 규칙

- Abstract의 **첫 2-3문장 안에** 핵심 주장(thesis statement)이 나와야 한다.
- "We identify...", "We characterize...", "We find..." 나열은 thesis가 아니다.
- Thesis는 "X는 Y이다", "X 없이는 Z가 불가능하다" 같은 **검증 가능한 주장**이어야 한다.
- 좋은 예: "Phantom load is the dominant bottleneck in K>=16 chiplet NoI, and no adjacent-only strategy can resolve it."
- 나쁜 예: "We identify phantom load and explore five mitigation strategies." (주장 없이 나열)

### 흔한 실수

- **Characterization paper라고 주장이 없어도 되는 게 아니다.** "우리가 발견한 현상이 중요하다"는 것 자체가 주장이며, 이를 명시해야 한다.
- **Findings 나열 ≠ 논문.** "A를 발견했고, B도 발견했고, C도 발견했다"는 shopping list이지 스토리가 아니다.
- **Negative results도 주장이 될 수 있다.** "Express links are NOT universally beneficial"은 강력한 주장이다.

### Figure 규칙

- **Figure 내 글씨 크기는 본문 글씨 크기(10pt)보다 확실히 작아야 한다.** matplotlib rcParams: `font.size: 6`, `axes.titlesize: 7`, `axes.labelsize: 6`, tick/legend: `5.5`. 제목(title)도 본문보다 작게.
- **모든 그림의 글씨 크기를 통일해야 한다.** 한 논문 내 모든 figure가 같은 rcParams를 사용. 그림마다 글씨 크기가 다르면 안 됨.
- **Fig 1은 반드시 첫 페이지에 배치.** Introduction 상단에 `\begin{figure}[!t]`로 강제 배치.
- **Figure 내에서 텍스트(annotation, label)와 그래프 요소(선, 점, 영역)가 겹치면 안 된다.** annotation 위치를 조정하거나, bbox로 배경을 넣어서 가독성 확보.
- Figure caption은 간결하게. 그림이 보여주는 핵심 메시지 한 문장.

### 논문에 넣지 말 것

- **Design Guidelines 섹션**: 별도 섹션으로 가이드라인을 나열하지 않는다. 실험 결과와 Discussion에서 자연스럽게 녹여내야 한다. 가이드라인 나열은 페이지 낭비이며, 그 공간에 실험 결과를 더 넣는 것이 낫다.
- **논문에 필요한 실험 결과는 전부 포함해야 한다.** 텍스트로 요약하지 말고 table/figure로 보여줘야 한다. 논문을 압축할 때 실험 결과를 텍스트로 대체하면 안 된다.

## Usage

```bash
cd ~/grepo/research
# Phase 1
/research-architect "temporal delta dataflow for edge VLA"
/research-advocate   # architect 결과에 대해 반론

# Phase 2
/research-engineer   # 설계 기반 구현
/research-advocate   # 실험 결과 해석

# Phase 3
/research-writer     # 논문 작성
/research-writing-reviewer  # 문장/구조 리뷰

# Phase 4
/research-reviewer --iteration 1  # 5명 리뷰
# 수정 후
/research-reviewer --iteration 2  # 재리뷰
/research-reviewer --iteration 3  # 최종 리뷰
```
