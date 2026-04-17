# `next` - 다음 작업 후보 조회

## 용도
- Jira MATS 이슈 중 최근 업데이트된 항목을 조회
- 진행 중인 이슈를 제외하고, 다음에 할 만한 작업을 카테고리별로 제안

## 사용법
- `next` - 최근 약 30일 이내 업데이트된 MATS 이슈 조회 후 다음 작업 후보 제시
- `next MATS-1660` - 지정한 키(들)는 "진행 중"으로 간주하고 제외 (쉼표로 여러 개 가능)

## 동작

1. **Jira 조회**: MATS 프로젝트, `updated >= -30d` JQL로 이슈 검색 (최대 50건, `updated DESC`)
2. **필드**: key, summary, status, issuetype, updated, assignee, components
3. **분류**: 상태·타입 기준으로 아래처럼 구분
   - 바로 손대기 좋은: 접수됨/작업, 스코프 작은 이슈
   - 단계 나누면 할 만한: 접수됨 스토리
   - 스코프 큰 것: 에픽 또는 대규모 스토리
   - 리뷰 마무리용: Developer in Review 등
4. **제외**: 사용자가 "진행 중"으로 지정한 이슈 키는 후보에서 제외
5. **출력**: 카테고리별 표 + 짧은 추천(선택)

## 출력 형식

- 카테고리별로 표(키 | 제목 | 상태) 나열
- 마지막에 "추천" 1~2줄 (바로 끝낼 수 있는 것, 리뷰 반영용 등)

## 참고

- Jira API: `.claude/skills/jira-api-access/SKILL.md`, `.claude/skills/jira-issue-management/SKILL.md` (mats-monorepo 쪽)
- 인증: `~/.netrc` (machine: mangoboost.atlassian.net)
- 엔드포인트: `GET https://mangoboost.atlassian.net/rest/api/3/search/jql?jql=...&maxResults=50&fields=...`

## 스킬

상세 JQL·요청 예시·파싱 방법은 `~/.claude/skills/next-work/SKILL.md` 참고.
