---
description: "Next work workflow - query Jira MATS issues (recent 30d), exclude in-progress, categorize and suggest next tasks"
---

# 다음 작업 후보 조회 (next)

`next` 커맨드 실행 시 Jira MATS 이슈를 조회해 다음에 할 만한 작업을 카테고리별로 제안하는 워크플로우입니다.

## 개요

- **트리거**: 사용자가 `next` 또는 `다음 작업 뭐할지 검토해줘` 등으로 요청
- **동작**: Jira API로 최근 30일 이내 업데이트된 MATS 이슈 조회 → 진행 중으로 지정된 키 제외 → 카테고리별 분류 → 표 + 추천 출력

## Jira 조회

**원칙**: 자체 스크립트를 새로 만들지 않는다. 기존 Jira 스크립트를 우선 사용하고, 필요 시 requests/curl로 폴백한다.

- **우선 사용**: `jira_search.py` (모노레포 `.claude/skills/jira-api-access/scripts/jira_search.py`)
- **폴백 허용**: requests 또는 curl로 `/rest/api/3/search/jql` 직접 호출
- **JQL**: `project = MATS AND updated >= -30d ORDER BY updated DESC`
- **파라미터**: `maxResults=50`, `fields=key,summary,status,issuetype,created,updated,assignee,components,priority`

### 사용 예 (CLI, 스크립트 우선)

```bash
# 모노레포 루트에서
python .claude/skills/jira-api-access/scripts/jira_search.py \
  "project = MATS AND updated >= -30d ORDER BY updated DESC" \
  --max-results 50 \
  --fields key,summary,status,issuetype,updated,assignee,components
```

### 사용 예 (Python에서 함수로)

```python
import sys
sys.path.insert(0, ".claude/skills/jira-api-access/scripts")
import jira_search

issues = jira_search.search_issues(
    "project = MATS AND updated >= -30d ORDER BY updated DESC",
    max_results=50,
    fields="key,summary,status,issuetype,updated,assignee,components",
)
# issues: 이슈 dict 목록 (None이면 실패)
```

### 응답에서 사용할 필드

- `issues[].key`
- `issues[].fields.summary`
- `issues[].fields.status.name`
- `issues[].fields.issuetype.name`
- `issues[].fields.updated` (날짜만 표시 시 앞 10자)
- `issues[].fields.assignee.displayName` (없으면 Unassigned)
- `issues[].fields.components[].name` (쉼표로 연결)

## 제외 규칙

- 사용자가 "MATS-1660은 진행 중" 등으로 지정한 이슈 키는 후보 목록에서 제외
- 필요 시 "진행 중" 상태(예: In Progress)인 이슈만 따로 빼거나, 사용자 지정 키만 제외

## 카테고리 분류

| 카테고리 | 기준 |
|----------|------|
| 바로 손대기 좋은 | 접수됨(Received) + 작업(Task) 또는 스코프 작은 스토리; 또는 Developer in Review |
| 단계 나누면 할 만한 | 접수됨 스토리 (한 번에 끝내기 어렵지만 단계 나눌 수 있는 것) |
| 스코프 큰 것 | 에픽 또는 참조 많은 스토리 (예: TestLayout 제거 등) |
| 리뷰 마무리용 | 상태가 Developer in Review |

완료됨(완료됨/해결됨 등) 이슈는 "다음 작업 후보"에서 제외하고, 미완료만 분류합니다.

## 출력 형식

- **표**: 카테고리별로 `키 | 제목 | 상태` 형태 표
- **추천**: 1~2줄 (바로 끝낼 수 있는 이슈, 리뷰 반영만 하면 되는 이슈 등)
- 사용자가 지정한 "진행 중" 이슈는 출력하지 않음

## 참고

- **next 실행 시**: Jira 데이터는 `jira_search.py`를 우선 사용하고, 필요 시 requests/curl 폴백 허용. 단, **자체 스크립트를 새로 만들지 않는다.**
- 커맨드 정의: `~/.claude/commands/next.md`
- Jira 스크립트·API 상세: mats-monorepo `.claude/skills/jira-api-access/SKILL.md`, `.claude/skills/jira-issue-management/SKILL.md`
