# `sync` - 현재 브랜치를 특정 브랜치에 rebase

**실행 규칙:** 이 명령을 수행할 때는 아래 스크립트 실행을 **우선한다**. 스크립트를 대체하여 수동으로 `git fetch`/`git rebase` 등을 실행하지 않는다.

**실행할 명령 (필수):**
- 인자 없음: `~/.claude/scripts/sync`
- 인자 있음: `~/.claude/scripts/sync <인자>` (예: `~/.claude/scripts/sync 241`, `~/.claude/scripts/sync add-commit-rules`)
- 실행 위치: 현재 워크스페이스 루트( git 리포인 경우 해당 디렉터리)

## 사용법
- `sync` - upstream/main에 rebase (기본 동작)
- `sync <branch_name>` - 해당 브랜치에 rebase
- `sync <PR_number>` - 해당 PR의 브랜치에 rebase

## 용도
- 현재 브랜치를 특정 브랜치(또는 PR)의 최신 변경사항과 동기화

## 동작
1. 타겟 브랜치 결정:
   - 파라미터가 없는 경우: `upstream/main` 사용
   - PR 번호가 주어진 경우:
     - 먼저 `.cache/pr_cache.json` 캐시 파일을 확인하여 해당 PR 번호의 브랜치 정보가 있는지 확인
     - 캐시에 정보가 있으면 캐시된 브랜치 정보 사용
     - 캐시에 정보가 없으면 `gh api repos/{owner}/{repo}/pulls/{pr_number} --hostname github.mangoboost.io --jq '{head: .head.ref, headRepo: .head.repo.full_name}'`로 브랜치 정보 조회 후 캐시에 저장
     - 타겟 브랜치: 로컬에 `<branch_name>` 브랜치가 있으면 로컬 브랜치 사용, 없으면 원격에서 fetch 후 원격 브랜치 사용
   - 브랜치명이 주어진 경우:
     - 로컬에 `<branch_name>` 브랜치가 있으면 로컬 브랜치 사용
     - 없으면 `upstream/<branch_name>` 또는 `origin/<branch_name>`에서 fetch 후 사용
2. Fetch 및 rebase:
   - PR 번호인 경우: `headRepo` 정보를 사용하여 해당 원격 저장소에서 fetch (필요시)
   - 브랜치명인 경우: `git fetch upstream` 또는 `git fetch origin` (필요시)
   - HEAD만 rebase target에 붙이기 (PR 1번 뒤에 PR 2번을 붙인 경우, PR 1번 수정 시):
     - 현재 브랜치: A -> B -> C (PR 1의 B 위에 PR 2의 C를 붙인 상태)
     - 타겟 브랜치: A -> B' (PR 1이 수정되어 B'로 변경됨)
     - 목표: A -> B' -> C' (C만 B' 위에 붙이기)
     - 브랜치 이름 저장: `BRANCH_NAME=$(git branch --show-current)`
     - `git rebase --onto <target_branch> HEAD~1 $BRANCH_NAME` - HEAD(C)만 타겟 브랜치(B') 위에 rebase
     - 브랜치 이름을 직접 지정하여 detached HEAD 상태를 방지
     - HEAD~1(B)는 버려지고, HEAD(C)만 B' 위에 붙음
     - 결과: A -> B' -> C'

## 예시
- `sync` (upstream/main에 rebase)
- `sync add-commit-rules` (add-commit-rules 브랜치에 rebase)
- `sync 12` (PR #12의 브랜치에 rebase)

## 주의
- **일반 `git rebase <target>` 명령은 절대 사용하지 않음** - 반드시 `git rebase --onto` 방식만 사용
- `git rebase --onto`는 현재 브랜치의 커밋만 타겟 브랜치 위에 붙이고, 기존 base 커밋은 버림
- **브랜치 이름을 직접 지정하여 detached HEAD 상태를 방지**: `git rebase --onto <target> <old_base> <branch_name>` 형식 사용
- rebase 충돌이 발생할 수 있음
- 충돌 발생 시 충돌 파일을 확인하고 수정할 수 있도록 안내
- `git add`가 block되어 있으므로 `git rebase --continue`는 실행하지 않음
- 사용자가 직접 충돌을 해결한 후 `git add` 및 `git rebase --continue`를 수동으로 실행해야 함
- PR 번호를 사용할 경우 GitHub CLI(`gh`)가 설치되어 있고 인증이 완료되어 있어야 함
- PR의 경우 headRepo가 upstream이 아닐 수 있으므로, 해당 원격 저장소에서 fetch가 필요할 수 있음
