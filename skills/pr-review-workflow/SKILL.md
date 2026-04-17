---
description: "PR review workflow - prepare temporary directories for reviewing PRs and branches without affecting the main repository"
---

# PR 리뷰 워크플로우

다른 사람이 작성한 PR이나 브랜치를 리뷰할 때, repo 내부가 아닌 임시 폴더에서 작업하여 안전하게 리뷰할 수 있도록 도와주는 스크립트와 워크플로우입니다.

## 개요

PR 리뷰 시 repo의 작업 디렉토리를 건드리지 않고 임시 폴더에서 작업할 수 있도록 합니다:
- PR 번호로 리뷰: `/tmp/pr-review-<PR_number>`
- 브랜치명으로 리뷰: `/tmp/review-<branch_name>`

## 스크립트 파일

### `scripts/review-pr`

PR 리뷰용 임시 폴더를 준비합니다.

**사용법:**
```bash
~/.claude/skills/pr-review-workflow/scripts/review-pr <PR_number>
```

**예시:**
```bash
~/.claude/skills/pr-review-workflow/scripts/review-pr 100
cd /tmp/pr-review-100
```

**동작:**
1. `/tmp/pr-review-<PR_number>` 디렉토리 생성 (기존 폴더가 있으면 삭제)
2. repository clone
3. PR 브랜치 fetch 및 checkout
4. PR 정보 조회 명령어 안내

### `scripts/review-branch`

브랜치 리뷰용 임시 폴더를 준비합니다.

**사용법:**
```bash
~/.claude/skills/pr-review-workflow/scripts/review-branch <branch_name>
```

**예시:**
```bash
~/.claude/skills/pr-review-workflow/scripts/review-branch feature-auth
cd /tmp/review-feature-auth
```

**동작:**
1. `/tmp/review-<branch_name>` 디렉토리 생성 (기존 폴더가 있으면 삭제)
2. repository clone
3. 브랜치 fetch 및 checkout

### `scripts/cleanup-review`

리뷰 임시 폴더를 정리합니다.

**사용법:**
```bash
# 특정 리뷰 폴더 삭제
~/.claude/skills/pr-review-workflow/scripts/cleanup-review <PR_number|branch_name>

# 모든 리뷰 폴더 삭제
~/.claude/skills/pr-review-workflow/scripts/cleanup-review --all
```

**예시:**
```bash
~/.claude/skills/pr-review-workflow/scripts/cleanup-review 100
~/.claude/skills/pr-review-workflow/scripts/cleanup-review feature-auth
~/.claude/skills/pr-review-workflow/scripts/cleanup-review --all
```

## 워크플로우

### PR 리뷰 예시

```bash
# 1. PR 리뷰 환경 준비
~/.claude/skills/pr-review-workflow/scripts/review-pr 100

# 2. 임시 폴더로 이동
cd /tmp/pr-review-100

# 3. PR 정보 조회
gh api repos/MangoBoost/mats-monorepo/pulls/100 --hostname github.mangoboost.io \
  --jq '{title: .title, body: .body, author: .user.login, state: .state, head: .head.ref, base: .base.ref}'

# 4. 변경사항 확인
git diff main --name-status
git diff main -- <file_path>

# 5. 리뷰 코멘트 확인
gh api repos/MangoBoost/mats-monorepo/pulls/100/comments --hostname github.mangoboost.io
gh api repos/MangoBoost/mats-monorepo/pulls/100/reviews --hostname github.mangoboost.io

# 6. 리뷰 완료 후 정리
~/.claude/skills/pr-review-workflow/scripts/cleanup-review 100
```

### 브랜치 리뷰 예시

```bash
# 1. 브랜치 리뷰 환경 준비
~/.claude/skills/pr-review-workflow/scripts/review-branch feature-auth

# 2. 임시 폴더로 이동
cd /tmp/review-feature-auth

# 3. 변경사항 확인
git log main..feature-auth --oneline
git diff main --name-status

# 4. 리뷰 완료 후 정리
~/.claude/skills/pr-review-workflow/scripts/cleanup-review feature-auth
```

## 중요 사항

### 임시 폴더 사용 이유

- **repo 보호**: 작업 중인 브랜치나 uncommitted 변경사항을 건드리지 않음
- **안전한 리뷰**: 실수로 commit이나 push할 위험 없음
- **깔끔한 환경**: 매번 깨끗한 상태에서 리뷰 가능

### 임시 폴더 경로

- PR 리뷰: `/tmp/pr-review-<PR_number>`
- 브랜치 리뷰: `/tmp/review-<branch_name>`

### 주의사항

- 작업 시작 시 기존 폴더가 있으면 자동으로 삭제하고 새로 생성합니다
- 리뷰 완료 후 수동으로 정리하거나 `cleanup-review` 스크립트를 사용하세요
- 임시 폴더는 시스템 재부팅 시 자동으로 삭제될 수 있습니다 (`/tmp`의 특성)

## 관련 문서

- `~/.claude/commands/review.md`: review 명령어 사용법 (AI 에이전트용)
