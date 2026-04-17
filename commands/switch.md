# `switch` - 브랜치로 이동 (겸용)

## 용도
- 다른 사람이 작성한 PR을 리뷰하기 위해 해당 PR의 브랜치로 이동
- 내 작업 브랜치로 되돌아가기

## 적용 범위
- **현재 작업 경로(열린 워크스페이스)**에서만 동작한다. 브랜치 전환은 현재 열린 리포 디렉터리에서 수행된다. 다른 클론/워크스페이스를 바꾸려면 해당 폴더를 연 뒤 그 워크스페이스에서 `switch`를 실행한다.

## 사용법
- `switch <PR_number>` 또는 `switch <branch_name>`

## 동작
1. PR 번호가 주어진 경우:
   - 먼저 `.cache/pr_cache.json` 캐시 파일을 확인하여 해당 PR 번호의 브랜치 정보가 있는지 확인
   - 캐시에 정보가 있으면 캐시된 브랜치 정보 사용
   - 캐시에 정보가 없으면 `gh api repos/{owner}/{repo}/pulls/{pr_number} --hostname github.mangoboost.io --jq '{head: .head.ref, headRepo: .head.repo.full_name}'`로 브랜치 정보 조회 후 캐시에 저장
   - 캐시 파일 형식: `{"<pr_number>": {"branch": "<branch_name>", "headRepo": "<owner/repo>", "cached_at": "<timestamp>"}}`
2. 브랜치명이 주어진 경우: 해당 브랜치로 직접 이동
3. 로컬 브랜치로 이동: `git fetch upstream && git checkout {branch_name} 2>/dev/null || git checkout -b {branch_name} upstream/{branch_name}`

## 예시
- `switch 12` (PR #12의 브랜치로 이동)
- `switch add-commit-rules` (특정 브랜치로 이동)

## 참고
- PR 번호를 사용할 경우 GitHub CLI(`gh`)가 설치되어 있고 인증이 완료되어 있어야 함
- 캐시 파일은 `.cache/pr_cache.json`에 저장되며, PR 번호와 브랜치 정보를 매핑합니다
- 캐시를 무시하고 강제로 API를 호출하려면 캐시 파일을 삭제하거나 수동으로 수정할 수 있습니다

## 참고 (로컬 리포 격리)
- 여러 에이전트를 쓸 때는 에이전트마다 `clone`으로 만든 별도 워크스페이스에서 `switch`를 사용하세요. 개인 개발 워크플로우: `~/.claude/docs/personal-dev-workflow.md`
