# `review` - PR 코드 리뷰

## 용도
- 다른 사람이 작성한 PR을 리뷰
- 특정 브랜치의 변경사항을 리뷰
- 현재 HEAD의 변경사항을 리뷰

## 자율 실행 원칙 (필수)

> **처음부터 끝까지 자율적으로 실행한다. 중간에 yes/no 또는 확인 질문을 하지 않는다.**
> Fetch → 분석 → 리뷰 → GitHub 코멘트 게시까지 한 번에 완료한다.

## 리뷰 에이전트 역할 (필수)

리뷰 수행 시 **pr-review-agent** 역할을 따른다. 동작 전 **반드시** 다음 파일을 읽고, **세 관점(중립·비판·긍정) + 합의 요약** 형식으로 출력한다.

- **~/.claude/agents/pr-review-agent.md** — PR 리뷰 전용 에이전트, 세 관점 합의 규칙
- **~/.claude/agents/neutral-reviewer.md** — 중립 관점 (사실·구조·기준)
- **~/.claude/agents/critical-reviewer.md** — 비판적 관점 (위험·엣지케이스·보안·성능)
- **~/.claude/agents/positive-reviewer.md** — 긍정적 관점 (잘된 점·의도·건설적 제안)

출력은 **(1) 공통 (2) 중립 관점 (3) 비판적 관점 (4) 긍정적 관점 (5) 합의 요약** 다섯 부분으로 구성한다. Cursor에서 pr-review-agent가 neutral/critical/positive 세 에이전트를 **오케스트레이션**하도록 설정한 경우에는 해당 에이전트들이 병렬/순차 실행되고, 그렇지 않은 경우에는 위 네 파일을 읽은 뒤 한 번에 세 관점을 반영한 리뷰를 작성한다.

## 사용법
- `review <PR_number>` - PR 번호로 리뷰
- `review <branch_name>` - 브랜치명으로 리뷰
- `review` - 현재 HEAD 리뷰 (최신 커밋: HEAD vs HEAD~1)

## 스크립트 사용 (선택사항)

임시 폴더 준비를 위한 헬퍼 스크립트가 제공됩니다. 자세한 내용은 `~/.claude/skills/pr-review-workflow/SKILL.md`를 참고하세요.

**스크립트 위치:** `~/.claude/skills/pr-review-workflow/scripts/`

**예시:**
```bash
# PR 리뷰 환경 준비
~/.claude/skills/pr-review-workflow/scripts/review-pr 100
cd /tmp/pr-review-100

# 브랜치 리뷰 환경 준비
~/.claude/skills/pr-review-workflow/scripts/review-branch feature-auth
cd /tmp/review-feature-auth

# 리뷰 완료 후 정리
~/.claude/skills/pr-review-workflow/scripts/cleanup-review 100
~/.claude/skills/pr-review-workflow/scripts/cleanup-review --all
```

## 동작

### 임시 폴더에서 작업

모든 review 작업은 repo 내부가 아닌 임시 폴더에서 수행합니다. 이를 통해 repo의 작업 디렉토리를 건드리지 않고 안전하게 리뷰를 수행할 수 있습니다.

### 1. PR 번호가 주어진 경우 (`review 100`)
1. **임시 폴더 생성 및 repository clone**
   
   **스크립트 사용 (권장):**
   ```bash
   ~/.claude/skills/pr-review-workflow/scripts/review-pr 100
   cd /tmp/pr-review-100
   ```
   
   **또는 수동으로:**
   ```bash
   REVIEW_DIR="/tmp/pr-review-${PR_number}"
   rm -rf "$REVIEW_DIR"
   mkdir -p "$REVIEW_DIR"
   cd "$REVIEW_DIR"
   git clone https://github.mangoboost.io/MangoBoost/mats-monorepo.git .
   git fetch origin pull/${PR_number}/head:pr-${PR_number}
   git checkout pr-${PR_number}
   ```
2. PR 정보 조회:
   ```bash
   gh api repos/MangoBoost/mats-monorepo/pulls/${PR_number} --hostname github.mangoboost.io \
     --jq '{title: .title, body: .body, author: .user.login, state: .state, head: .head.ref, base: .base.ref}'
   ```
3. PR의 변경사항 분석:
   - **리뷰 분석 대상은 최신 커밋(HEAD vs HEAD~1)만 사용한다.** main vs HEAD 전체가 아님.
   - 변경 파일 목록: `git show HEAD --name-status` 또는 `git diff HEAD~1 HEAD --name-status`
   - 상세 diff (리뷰에 사용): `git diff HEAD~1 HEAD` 또는 `git show HEAD`
   - (선택) 맥락 참고용: `git log main..HEAD --oneline`, `git diff main --name-status` — 리뷰 코멘트 작성 시 분석 대상으로 쓰지 않음
4. 리뷰 코멘트 및 기존 리뷰 확인:
   ```bash
   gh api repos/MangoBoost/mats-monorepo/pulls/${PR_number}/comments --hostname github.mangoboost.io
   gh api repos/MangoBoost/mats-monorepo/pulls/${PR_number}/reviews --hostname github.mangoboost.io
   ```
5. 코드 리뷰 수행 및 결과 제시
6. **작업 완료 후 임시 폴더 정리**
   ```bash
   ~/.claude/skills/pr-review-workflow/scripts/cleanup-review ${PR_number}
   # 또는
   rm -rf /tmp/pr-review-${PR_number}
   ```

### 2. 브랜치명이 주어진 경우 (`review feature-branch`)
1. **임시 폴더 생성 및 repository clone**
   
   **스크립트 사용 (권장):**
   ```bash
   ~/.claude/skills/pr-review-workflow/scripts/review-branch feature-branch
   cd /tmp/review-feature-branch
   ```
   
   **또는 수동으로:**
   ```bash
   REVIEW_DIR="/tmp/review-${branch_name}"
   rm -rf "$REVIEW_DIR"
   mkdir -p "$REVIEW_DIR"
   cd "$REVIEW_DIR"
   git clone https://github.mangoboost.io/MangoBoost/mats-monorepo.git .
   git fetch origin ${branch_name}:${branch_name}
   git checkout ${branch_name}
   ```
2. 변경사항 분석:
   - **리뷰 분석 대상은 최신 커밋(HEAD vs HEAD~1)만 사용한다.** main vs HEAD 전체가 아님.
   - 변경 파일: `git show HEAD --name-status` 또는 `git diff HEAD~1 HEAD --name-status`
   - 상세 diff: `git diff HEAD~1 HEAD` 또는 `git show HEAD`
   - (선택) 맥락 참고용: `git log main..${branch_name} --oneline` — 리뷰 코멘트 작성 시 분석 대상으로 쓰지 않음
3. 코드 리뷰 수행 및 결과 제시
4. **작업 완료 후 임시 폴더 정리**
   ```bash
   ~/.claude/skills/pr-review-workflow/scripts/cleanup-review ${branch_name}
   # 또는
   rm -rf /tmp/review-${branch_name}
   ```

### 3. 파라미터 없는 경우 (`review`)
1. 현재 브랜치에서 **최신 커밋(HEAD vs HEAD~1)**만 리뷰 (repo 내부에서 직접 리뷰):
   - **리뷰 분석 대상은 HEAD vs HEAD~1이다.** main vs HEAD 전체가 아님.
   - 변경 파일: `git show HEAD --name-status` 또는 `git diff HEAD~1 HEAD --name-status`
   - 상세 diff: `git diff HEAD~1 HEAD` 또는 `git show HEAD`
   - (선택) 맥락 참고용: `git log main..HEAD --oneline` — 리뷰 코멘트 작성 시 분석 대상으로 쓰지 않음
2. 코드 리뷰 수행 및 결과 제시

**참고**: 파라미터 없는 경우는 현재 작업 중인 브랜치를 리뷰하므로 repo 내부에서 직접 수행합니다 (임시 폴더 사용 안 함).

## 리뷰 출력 형식 (세 관점 + 합의)

```markdown
## PR #<number> 리뷰 (또는 브랜치명 리뷰)

**PR 제목**: <title>
**작성자**: <author>
**변경 파일**: <file_list>

---

### 변경사항 요약
<변경사항 간략 요약>

---

### 1. 중립 관점 (neutral-reviewer)
<사실·구조·기준 위주, 균형 있는 좋은 점/개선 제안>

### 2. 비판적 관점 (critical-reviewer)
<위험·엣지케이스·보안·성능·엄격한 기준 위주 지적>

### 3. 긍정적 관점 (positive-reviewer)
<잘된 점·의도·건설적 제안 위주>

### 4. 합의 요약
<세 관점을 조정한 최종 코멘트. 반드시 수정(Critical), 개선 권장(Suggestion), 좋은 점 한 줄 요약 포함.>
```

## 중요 사항

### 리뷰 시 비교 대상 (필수)
- **분석·리뷰에 사용하는 diff는 항상 최신 커밋만: HEAD vs HEAD~1** (`git show HEAD` 또는 `git diff HEAD~1 HEAD`).
- main vs HEAD 전체 diff는 리뷰 분석 대상으로 사용하지 않는다. 맥락 참고용으로만 쓸 수 있음.

### 임시 폴더 사용
- PR 번호나 브랜치명이 주어진 경우, **repo 내부가 아닌 임시 폴더에서 작업**합니다
- 임시 폴더 경로: `/tmp/pr-review-<PR_number>` 또는 `/tmp/review-<branch_name>`
- 작업 시작 시 기존 폴더가 있으면 삭제하고 새로 생성합니다 (`rm -rf` 후 `mkdir -p`)
- 작업 완료 후 임시 폴더는 수동으로 삭제합니다: `rm -rf /tmp/pr-review-<PR_number>`
- 임시 폴더를 사용하면 repo의 작업 디렉토리를 건드리지 않고 안전하게 리뷰할 수 있습니다

### Repository clone
- 임시 폴더에서 repository를 clone하여 작업합니다
- PR은 `refs/pull/<PR_number>/head` 레퍼런스로 접근합니다
- 브랜치는 `origin` remote에서 직접 fetch합니다

### Severity 레벨
- `[Critical]`: 반드시 수정 필요 (버그, 보안 이슈, race condition 등)
- `[Suggestion]`: 개선 권장 (성능, 유지보수성, 코드 스타일 등)

### 리뷰하지 않아도 되는 항목
- **@staticmethod 인스턴스 호출**: `@staticmethod` 메서드를 인스턴스에서 호출하는 것은 Python에서 정상 동작하며, 문맥에 따라 더 자연스러울 수 있음. 굳이 `ClassName.method()` 형식으로 변경할 필요 없음.

## 예시
- `review 100` - PR #100 리뷰 (임시 폴더 `/tmp/pr-review-100`에서 작업)
- `review feature-auth` - feature-auth 브랜치 리뷰 (임시 폴더 `/tmp/review-feature-auth`에서 작업)
- `review` - 현재 HEAD 리뷰 (repo 내부에서 직접 작업)

## 참고
- GitHub CLI(`gh`)가 설치되어 있고 인증이 완료되어 있어야 함
- `--hostname github.mangoboost.io` 옵션으로 GitHub Enterprise 환경 지원
- 파라미터 없는 경우(`review`)는 현재 브랜치를 리뷰하므로 repo 내부에서 직접 수행
