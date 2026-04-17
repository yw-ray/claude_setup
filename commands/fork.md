# `fork` - 브랜치에서 분기

## 사용법
- `fork` - **브랜치 변경 없이** 현재 브랜치에서 새 브랜치 생성
- `fork <PR_number>` - PR의 브랜치에서 새 브랜치 생성
- `fork <branch_name>` - 해당 브랜치에서 새 브랜치 생성

## 동작
1. 파라미터가 없는 경우:
   - **브랜치 변경 없이** 현재 브랜치에서 `git checkout -b <new_branch_name>`으로 새 브랜치 생성
   - 다른 브랜치로 이동하지 않고 현재 브랜치를 기반으로 새 브랜치 생성
   - 새 브랜치명은 생략 시 작업 내용 기반으로 추천

2. PR 번호가 주어진 경우:
   - 먼저 `.cache/pr_cache.json` 캐시 파일을 확인하여 해당 PR 번호의 브랜치 정보가 있는지 확인
   - 캐시에 정보가 있으면 캐시된 브랜치 정보 사용
   - 캐시에 정보가 없으면 `gh api repos/{owner}/{repo}/pulls/{pr_number} --hostname github.mangoboost.io --jq '{head: .head.ref, headRepo: .head.repo.full_name}'`로 브랜치 정보 조회 후 캐시에 저장
   - 해당 브랜치로 이동: `git fetch upstream && git checkout {branch_name} 2>/dev/null || git checkout -b {branch_name} upstream/{branch_name}`
   - 그 브랜치에서 `git checkout -b <new_branch_name>`으로 새 브랜치 생성
   - 새 브랜치명은 생략 시 작업 내용 기반으로 추천

3. 브랜치명이 주어진 경우:
   - 해당 브랜치로 이동: `git fetch upstream && git checkout {branch_name} 2>/dev/null || git checkout -b {branch_name} upstream/{branch_name}`
   - 그 브랜치에서 `git checkout -b <new_branch_name>`으로 새 브랜치 생성
   - 새 브랜치명은 생략 시 작업 내용 기반으로 추천

## 브랜치명 규칙
- 새 브랜치명은 생략 시 작업 내용 기반으로 추천
- **중요: 이슈 번호(MATS-XXXX)를 브랜치명에 포함하지 마세요**
  - ❌ 잘못된 예: `feature/MATS-1595-test-runner-dockerization`
  - ✅ 올바른 예: `feature/test-runner-dockerization`
- 이슈 번호는 커밋 메시지에만 포함되며, 브랜치명과는 별도로 관리됩니다

## 예시
- `fork` (브랜치 변경 없이 현재 브랜치에서 새 브랜치 생성)
- `fork 12` (PR #12의 브랜치에서 새 브랜치 생성)
- `fork add-commit-rules` (add-commit-rules 브랜치에서 새 브랜치 생성)

## 참고
- **중요**: 파라미터 없이 `fork`를 실행할 때는 **브랜치 변경 없이** 현재 브랜치에서 바로 새 브랜치를 생성합니다. 다른 브랜치로 이동하지 않습니다.
- PR 번호를 사용할 경우 GitHub CLI(`gh`)가 설치되어 있고 인증이 완료되어 있어야 함
- 캐시 파일은 `.cache/pr_cache.json`에 저장되며, PR 번호와 브랜치 정보를 매핑합니다
- `switch` 커맨드와 동일하게 캐시를 활용합니다

## 참고 (로컬 리포 격리)
- 여러 에이전트가 동시에 작업할 때는 `clone`으로 에이전트마다 별도 워크스페이스를 만든 뒤, 각 클론에서 `fork`를 사용하세요. 개인 개발 워크플로우: `~/.claude/docs/personal-dev-workflow.md`
