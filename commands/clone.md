# `clone` - 에이전트별 격리된 로컬 리포 생성

## 용도
- 여러 에이전트(또는 Cursor 세션)가 **코드 작업을 서로 간섭 없이** 하기 위해, 에이전트마다 **별도 워크스페이스(클론)**를 만듦
- 한 클론에서 작업 중인 변경이 다른 에이전트의 클론에 덮어쓰이지 않도록 함

## 워크플로우
- **대체로 플랜 먼저 짜고 `clone` 실행.** 플랜/작업 범위가 정해진 뒤, 해당 작업용 격리 클론을 만들 때 사용.

## 사용법
- `clone` - 현재 리포를 격리용 클론 하나 더 생성. **작업 내역(플랜·브랜치·최근 작업)을 보고 접미사를 적당히 네이밍**하여 경로 제안.
- `clone <suffix>` - 접미사를 직접 지정하여 클론 생성 (예: `clone feature-testconfig-api`)
- `clone <PR_number>` - **특정 PR을 위한 격리 클론** 생성. 클론 후 해당 PR 브랜치를 체크아웃한 상태로 둠 (예: `clone 195` → `mats-monorepo-pr-195` 생성 후 PR #195 브랜치 체크아웃)
- `clone <PR_number> new` - **해당 PR을 기반으로 한 신규 작업용 워크스페이스** 생성. **경로는 현재 플랜·브랜치·작업 맥락에 맞춰** 접미사를 정한다(케이스 A의 suffix 생략 시와 동일). PR 번호는 경로에 넣지 않는다. 클론 후 해당 PR 브랜치를 체크아웃한다 (예: `clone 164 new` → 플랜이 storage-test-phase2면 `mats-monorepo-storage-test-phase2` 등 맥락에 맞는 경로 제안 후 클론, PR #164 브랜치 체크아웃)

## 동작

**공통**
1. **현재 리포 확인**: 현재 워크스페이스 루트가 Git 리포인지 확인. `git rev-parse --show-toplevel`로 루트 경로와 리포 이름 확인.
2. **원격 URL 확인**: `git remote get-url origin` 또는 `upstream`으로 clone에 쓸 URL 결정 (가능하면 SSH/HTTPS 동일하게 유지).

**케이스 A: `clone` 또는 `clone <suffix>` (접미사는 숫자만 있는 PR 번호가 아님)**
3. **대상 경로(접미사) 결정**:
   - **`suffix` 생략 시**: **작업 내역을 보고 적당히 네이밍**하여 `<repo_name>-<suffix>` 형태로 경로 제안.
     - 참고할 것: 최근/현재 플랜 제목(`.claude/plans/` 또는 `.cursor/plans/`), 현재 브랜치명, 최근 커밋/PR 요약, 대화에서 언급된 작업 키워드.
     - 예: 플랜이 "testconfiguration-api" 관련이면 `mats-monorepo-feature-testconfig-api`, 브랜치가 `feature/redis-role-separation` 이면 `mats-monorepo-redis-role-separation`, 날짜 포함 시 `mats-monorepo-260202-testconfig-api` 등. **kebab-case, 짧고 구분 가능하게.**
     - 제안한 suffix를 사용자에게 보여 주고, 동의 후 진행하거나 사용자가 수정 제안 시 반영.
   - **`suffix` 지정 시**: 그대로 `<repo_name>-<suffix>` 로 경로 결정.
   - 경로는 현재 리포의 **부모 디렉터리**에 생성 (예: `~/work/mats-monorepo` → `~/work/mats-monorepo-<suffix>`).
4. **클론 실행**: `git clone <url> <target_path>` 실행. 이미 대상 경로가 있으면 "이미 존재함" 안내 후, **`cursor <target_path>`** 실행하여 해당 경로를 연다.
5. **설정 디렉터리**: 원본 리포에 `.vscode`가 있으면 새 클론에 **복사**한 뒤, 해당 클론만의 **시각 구분**을 위해 `workbench.colorCustomizations`(타이틀 바·액티비티 바 색)를 접미사 기준 색으로 merge한다. 같은 접미사면 같은 색, 다른 접미사면 다른 색이라 창을 구분하기 쉽다. `.cursor`는 원본에 있으면 **심볼릭 링크**로 연결. 클론 쪽에 이미 해당 이름이 있으면 건너뜀.
6. **Cursor 실행**: **`cursor <target_path>`** 를 실행하여 해당 경로를 새 Cursor 창에서 연다. (선택) "새 Cursor 창에서 `<target_path>` 가 열렸습니다." 안내 출력.

**케이스 B: `clone <PR_number>` (인자가 숫자만 있는 PR 번호)**
3. **PR 브랜치 정보 조회**: `switch`/`fork`와 동일하게 PR 브랜치 확인.
   - 먼저 `.cache/pr_cache.json` 캐시 확인. 없으면 `gh api repos/{owner}/{repo}/pulls/<PR_number> --hostname github.mangoboost.io --jq '{head: .head.ref, headRepo: .head.repo.full_name}'` 로 조회 후 캐시에 저장.
   - `branch`: PR의 head 브랜치명, `headRepo`: head가 있는 원격 저장소 (예: `MangoBoost/mats-monorepo` 또는 fork).
4. **대상 경로**: 현재 리포의 **부모 디렉터리**에 `<repo_name>-pr-<PR_number>` 형태로 경로 결정 (예: `~/work/mats-monorepo-pr-195`). 이미 해당 경로가 있으면 "이미 존재함" 안내 후 해당 경로에서 PR 브랜치만 체크아웃하도록 안내한 뒤 **`cursor <target_path>`** 실행.
5. **클론 실행**: `git clone <url> <target_path>` 실행.
6. **설정 디렉터리**: 케이스 A와 동일(.vscode 복사 후 접미사별 색 적용, .cursor는 심볼릭 링크).
7. **PR 브랜치 체크아웃**: 새 클론 디렉터리에서 `git fetch upstream` (또는 headRepo가 upstream이 아니면 해당 remote 추가 후 fetch) 후, `git checkout <branch_name>` 또는 `git checkout -b <branch_name> upstream/<branch_name>` (또는 headRepo에 맞는 remote) 로 해당 PR 브랜치 체크아웃.
8. **Cursor 실행**: **`cursor <target_path>`** 를 실행하여 해당 경로를 새 Cursor 창에서 연다. (선택) "PR #<number> 브랜치가 체크아웃된 상태로 열렸습니다." 안내 출력.

**케이스 C: `clone <PR_number> new` (해당 PR 기반 신규 작업용 워크스페이스)**
3. **PR 브랜치 정보 조회**: 케이스 B와 동일.
4. **대상 경로**: **현재 플랜·브랜치·작업 맥락에 맞춰** 접미사를 정한다. 케이스 A의 suffix 생략 시와 동일한 기준(최근/현재 플랜 제목, 브랜치명, 커밋·PR 요약, 대화 키워드)으로 `<repo_name>-<suffix>` 형태로 경로 제안. PR 번호는 경로에 넣지 않는다. 제안한 suffix를 사용자에게 보여 주고 동의 후 진행하거나 수정 제안 시 반영. 이미 해당 경로가 있으면 "이미 존재함" 안내 후 해당 경로에서 PR 브랜치만 체크아웃하도록 안내한 뒤 **`cursor <target_path>`** 실행.
5. **클론 실행**: `git clone <url> <target_path>` 실행.
6. **설정 디렉터리**: 케이스 A와 동일(.vscode 복사 후 접미사별 색 적용, .cursor는 심볼릭 링크).
7. **PR 브랜치 체크아웃**: 케이스 B와 동일.
8. **Cursor 실행**: **`cursor <target_path>`** 를 실행하여 해당 경로를 새 Cursor 창에서 연다. (선택) "PR #<number> 브랜치가 체크아웃된 신규 작업용 워크스페이스로 열렸습니다." 안내 출력.

## 주의
- 기존 브랜치는 수정하지 않음. 새 디렉터리에 새 클론만 생성.
- 동일한 `suffix`로 이미 디렉터리가 있으면 클론하지 않고, **`cursor <target_path>`** 실행하여 해당 경로를 연다.

## 예시
- `clone` — 작업 내역 기반으로 접미사 제안 후 클론
- `clone feature-testconfig-api` — `mats-monorepo-feature-testconfig-api` 생성
- `clone 195` — `mats-monorepo-pr-195` 생성 후 PR #195 브랜치 체크아웃
- `clone 164 new` — 현재 플랜/맥락으로 경로 제안(예: storage-test-phase2) 후 클론, PR #164 브랜치 체크아웃 (164 기반 신규 작업용, 경로에는 PR 번호 미포함)

## 참고
- PR 번호를 사용할 경우 GitHub CLI(`gh`)가 설치되어 있고 인증이 완료되어 있어야 함. `switch`/`fork`와 동일하게 `.cache/pr_cache.json` 캐시 활용.
- 개인 개발 워크플로우 전체: `~/.claude/docs/personal-dev-workflow.md`
- **.venv**: 클론(워크스페이스)마다 **해당 경로 안에서 .venv를 각자 구축**해서 쓴다. 의존성 격리를 위해 다른 경로의 .venv를 재사용하지 않음. 자세한 기준: [~/.claude/docs/venv.md](~/.claude/docs/venv.md).
- **.vscode / .cursor**: 클론 생성 직후 원본에 `.vscode`가 있으면 새 클론에 **복사**하고, 해당 워크스페이스만 `workbench.colorCustomizations`로 타이틀/액티비티 바 색을 접미사별로 적용해 창 구분이 되게 함. `.cursor`는 원본에 있으면 **심볼릭 링크**로 연결. 클론 쪽에 이미 같은 이름이 있으면 건너뜀. 원본이 없으면 아무 작업도 하지 않음.
- `new`, `fork`, `switch` 등은 **현재 열린 워크스페이스(클론)** 안에서만 동작. 여러 에이전트를 쓰려면 에이전트마다 다른 클론을 열고, 각 클론에서 `new`/`fork` 등을 사용하세요.
