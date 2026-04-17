---
description: "Weekly report workflow - Jira issue-based commit collection and report writing (script + usage guide)"
---

# 주간 보고서 워크플로우 (Jira 이슈 기준)

## 개요

주간 작업/커밋을 Jira 이슈별로 수집하고, 각 이슈에 대해 **자연어 작업 요약**까지 생성한 뒤, 그 결과를 바탕으로 주간 보고서를 작성하는 흐름을 안내합니다.
데이터 수집은 Python 스크립트, **요약 생성**과 보고서 작성은 에이전트가 수행합니다.

## 경로

- **커밋 수집 스크립트**: `~/.claude/skills/weekly-report/scripts/weekly-report.py`
- **이슈 매핑 스크립트**: `~/.claude/skills/weekly-report/scripts/weekly-place.py` (Confluence structure 기준 분류)
- **출력 디렉터리**: `~/.claude/weekly/YYMMDD/` (예: `~/.claude/weekly/260128/`)
- **출력 파일**: `~/.claude/weekly/YYMMDD/commits-by-issue.md`

날짜(YYMMDD)는 실행일 기준으로 자동 생성되며, `--out-date YYMMDD`로 지정할 수도 있습니다.

## 1단계: 커밋 수집 실행

저장소 루트에서 다음처럼 실행합니다.

```bash
# 기본: cwd를 repo로, upstream/main 최근 7일 + 오픈 PR HEAD
python3 ~/.claude/skills/weekly-report/scripts/weekly-report.py

# 옵션 예시
python3 ~/.claude/skills/weekly-report/scripts/weekly-report.py --repo /path/to/mats-monorepo --days 7 --out-date 260128
```

**스크립트 동작 요약**

- `upstream` 원격 fetch 후 `--main-branch`(기본 `upstream/main`)의 최근 `--days`일 커밋 수집
- `gh pr list`로 오픈 PR 목록을 가져와 각 PR의 HEAD 커밋(OID) 수집
- main에 이미 포함된 커밋은 제외하고, 커밋 해시 기준으로 중복 제거
- 커밋 제목에서 `MATS-XXXX` 패턴을 추출해 이슈별로 그룹핑, 매칭 없으면 "이슈 없음"으로 묶음
- 결과를 `~/.claude/weekly/YYMMDD/commits-by-issue.md`에 마크다운으로 저장 (각 이슈 섹션에 **요약**: 자리 비움)

**필수 환경**

- Git 저장소, `upstream` 원격 설정
- GitHub CLI(`gh`) 설치 및 인증(`GH_HOST` 사용 시 해당 호스트에 맞게 설정)

## 2단계: 이슈·커밋 매핑 (Confluence structure 기준)

`commits-by-issue.md`와 Jira 해결 이슈를 Confluence 회의록 페이지 구조(Projects/Maintenance 등)에 맞게 분류합니다. **3단계(요약 채우기) 전에 수행**해, 배치 결과를 보고 요약을 작성할 수 있게 합니다.

```bash
python3 ~/.claude/skills/weekly-report/scripts/weekly-place.py
```

**동작**: 최신 `~/.claude/weekly/YYMMDD/commits-by-issue.md`를 읽고, Jira 최근 7일 해결 이슈를 조회한 뒤, MATS팀 회의록 폴더(Confluence)에서 날짜 기준 가장 가까운 페이지를 찾아 h1/h2 구조를 읽습니다. 커밋·이슈를 Projects/Maintenance/Frontend/Backend/Workflow/Workload 등으로 분류해 **기존 structure에 맞게 배치된 항목들**과 **배치되지 않은 항목들**을 출력합니다. (Confluence 페이지는 수정하지 않음.)

**필수 환경**: `.netrc`에 `mangoboost.atlassian.net` 인증 설정, `requests` 라이브러리.

## 3단계: 이슈별 작업 요약 채우기 (자연어) — **필수**

2단계(매핑) 결과를 보고, 각 이슈가 어느 섹션에 배치되는지 파악한 뒤 요약을 채웁니다. **`/weekly` 실행 시 또는 주간 자료 생성 시 에이전트는 반드시 이 단계를 수행합니다.**

**에이전트 수행 내용**

- `~/.claude/weekly/YYMMDD/commits-by-issue.md`를 연다 (YYMMDD는 1단계에서 생성된 디렉터리).
- 2단계에서 출력된 **배치된 항목 / 미배치 항목**을 참고해, 각 `### MATS-XXXX` 및 `### 이슈 없음` 섹션에서 **요약**: 줄이 비어 있으면 해당 섹션의 커밋 목록(제목만)을 보고 1~2문장 한국어 작업 요약을 작성해 `**요약**: ` 뒤에 덧붙여 저장한다.
- 이미 요약이 있는 섹션은 건너뛰어도 된다.

**사용자가 에이전트를 부를 때 예시**

> "매핑(weekly-place) 돌렸어. 이제 commits-by-issue.md 열고 각 이슈별 **요약** 줄 채워 줘."

이렇게 하면 주간 보고서의 "이슈별 작업 요약"이나 섹션 본문에 그대로 활용할 수 있습니다.

## 4단계: 출력 구조 — 담당자별 섹션

생성·채워진 `~/.claude/weekly/YYMMDD/commits-by-issue.md`는 **담당자(owner) 단위**로 섹션을 나눕니다. 이슈 단위만 나열하지 않고, 담당자별로 묶어두면 "내 꺼만" 먼저 정리하기 쉽습니다.

**구조**

- **제목**: `# 커밋 목록 (담당자별)`
- **최상위 섹션**: `## {담당자명}({한글명})` — 예: `## Sunghwan Kim(김성환)`, `## Gyujin Choi(최규진)`
- **하위 블록**: 각 담당자 섹션 안에 해당 담당자 이슈만 `### MATS-XXXX` 블록으로 나열 (Jira URL, **상태**, **요약**, 커밋 목록)
- **마지막 섹션**: `## 이슈 없음` — Jira 이슈 키가 없는 커밋만 모음

1단계 스크립트는 이슈별로만 출력하므로, **에이전트가 3단계(요약 채우기) 전후에** Jira `fields=assignee` 등으로 담당자를 조회한 뒤, 위 구조로 재구성(담당자별로 묶고, 각 블록에서 중복 "담당자" 줄은 제거)합니다.

**상태 기준**: mats-monorepo `.claude/plans` + Jira API를 참고하되, 불일치 시 **플랜 기준**. 문서에서 "완료"로 둔 이슈는 필요 시 Jira에서도 완료됨으로 맞춥니다(5단계 아래 "문서–Jira 상태 동기화" 참고).

## 4-2. commits-by-issue.md 활용

포함 내용 요약:

- 기준 설명 (main 최근 N일 + 오픈 PR HEAD)
- 총 커밋 수, 이슈 있음/없음 건수
- **담당자별 섹션**: `## 담당자명` → `### MATS-XXXX` (또는 `## 이슈 없음`)
- 각 이슈: **상태**(완료/진행 중), **요약**, Jira URL, 커밋 목록

**보고서 작성 시**

1. **이슈별 작업 요약**: 3단계에서 채운 자연어 요약을 보고서에 인용합니다.
2. **섹션별 블록 구성**: 주간 보고서의 대주제(예: "Unifying storage test interface")에 맞춰 관련 MATS-XXXX 이슈들을 묶고, 위 요약과 Jira URL을 사용해 한 섹션을 채웁니다.
3. **Tasks 블록**: 필요 시 해당 섹션 이슈들을 Jira URL 리스트 형태로 정리해 Confluence/카드 임베드용으로 사용합니다.
4. **이슈 없음**: "이슈 없음" 섹션은 리팩터/문서/설정 등 이슈에 안 묶인 작업으로 간단히 나열하거나 별도 소제목으로 정리합니다.

## 5단계: 추가 Jira 정보 (선택)

특정 이슈의 요약/상태/설명이 필요하면 Jira REST API를 사용합니다.
인증 및 호출 방법은 프로젝트의 `.claude/skills/jira-api-access/SKILL.md`를 따릅니다 (`.netrc` + `requests` 등).

- 이슈 요약: 보고서 본문에 인용
- 상태/해결 이슈: "해결된 이슈" 등 목록 작성 시 참고
- 담당자/라벨: 필요 시 동일 API로 확장

## 문서–Jira 상태 동기화 (선택)

문서에서 "완료"로 둔 이슈가 Jira에서는 "Developer in Review" 등으로 남아 있을 수 있습니다. 문서 기준으로 Jira를 맞추려면:

1. **비교**: 문서에서 "완료"인 이슈만 골라, Jira `GET /rest/api/3/issue/{key}?fields=status`로 현재 상태 조회.
2. **차이 목록**: 문서=완료, Jira≠완료됨(Done/Complete)인 이슈를 나열.
3. **전환**: 해당 이슈에 대해 `GET .../transitions`로 "완료됨"(또는 Done)으로 가는 transition id를 찾고, `POST .../transitions`로 전환 실행.

Jira Transition API 사용법은 프로젝트 `.claude/skills/jira-issue-management/jira-issue-transition.md` 참고.

## 섹션–이슈 매핑 (선택)

어떤 주제에 어떤 MATS-XXXX를 묶을지는 다음 중 하나로 관리할 수 있습니다.

- **보고서 작성 시점에 결정**: 매주 commits-by-issue.md를 보면서 해당 주 작업 내용에 맞춰 섹션을 나누고 이슈를 할당.
- **스킬 또는 별도 설정에 고정**: 예를 들어 "Unifying storage test interface" → MATS-1649, MATS-1650, … 처럼 고정 리스트를 본 SKILL.md 또는 `~/.claude/weekly/sections.yaml` 같은 파일에 두고, 보고서 초안 생성 시 참고.

스크립트는 현재 섹션 매핑을 읽지 않으며, 항상 "이슈별 그룹"만 출력합니다. 섹션 구성은 보고서 작성 단계에서 처리합니다.

## 요약

| 단계 | 위치 | 내용 |
|------|------|------|
| 1 | `weekly-report.py` | main + 오픈 PR HEAD 커밋 수집, 이슈별 그룹, YYMMDD 디렉터리에 마크다운 출력 (요약 자리 비움) |
| 2 | `weekly-place.py` | commits-by-issue + Jira 해결 이슈 → Confluence 회의록 structure 기준 분류, 배치된 항목 + 미배치 항목 출력. **3단계 전에 수행.** |
| 3 | **에이전트 (필수)** | 2단계 결과를 참고해 commits-by-issue.md 각 이슈 섹션의 **요약**: 줄을 커밋 목록 보고 1~2문장 한국어로 채움. 미수행 시 보고서에 요약 활용 불가. |
| 4 | **에이전트 + commits-by-issue.md** | **담당자별 섹션**으로 재구성: `## 담당자명` → `### MATS-XXXX`. Jira assignee 조회 후 owner 단위로 묶고, 상태(플랜 우선) 반영. "내 꺼만" 정리하기 쉽게. |
| 4-2 | `~/.claude/weekly/YYMMDD/commits-by-issue.md` | 담당자별 요약·상태·커밋 목록·Jira URL → 주간 보고서 초안 작성에 사용 |
| 5 | Jira API (선택) | 이슈 요약/상태 등 추가 정보는 `.claude/skills/jira-api-access/SKILL.md` 참고 |
| (선택) | 문서–Jira 동기화 | 문서=완료, Jira 미완료인 이슈를 Jira Transitions API로 완료됨 전환. jira-issue-transition.md 참고. |

모든 경로는 `~/.claude` 이하이며, 주간 출력은 `~/.claude/weekly/YYMMDD/`에만 생성됩니다.
