---
description: "Resolve PR review comments: read comments, make code changes, force push, and reply. Use when user says '/resolve <PR_NUMBER>', 'PR 코멘트 처리', '리뷰 반영', or asks to address/resolve PR review feedback."
---

# Resolve PR Comments

## Trigger Commands

- `/resolve <PR_NUMBER>` — e.g., `/resolve 42`
- `PR 코멘트 처리 <PR번호>`
- `리뷰 반영 <PR번호>`

## Overview

Read review comments on my PR, analyze and address each, make code changes,
amend + force push, and reply to each comment explaining the resolution.

## Autonomous Execution Principle

> **Execute autonomously from start to finish.**
> Detect repo → fetch comments → analyze → make changes → present summary → (confirm) → push + reply.
> Only pause for user confirmation before force push.

## Workflow

### 1. Detect Repository Info

Automatically detect from current git remotes:

```bash
# Extract GHE hostname and OWNER/REPO from remote URL
# e.g., https://github.mangoboost.io/MangoBoost/BoostX-SDS.git
#   → HOSTNAME=github.mangoboost.io, OWNER=MangoBoost, REPO=BoostX-SDS

# Determine the "upstream" remote (main org repo)
# Convention: the remote whose URL contains the org name (MangoBoost)
# This is used for gh API calls

# Determine the "push" remote (personal fork)
# Convention: the remote whose URL contains the user's GitHub username
# This is used for force push
```

**Remote naming varies by project:**
- BoostX-SDS: `origin` = MangoBoost (upstream), `myfork` = personal fork
- mats-monorepo: `upstream` = MangoBoost (upstream), `origin` = personal fork

The skill must detect the correct remote by URL, not by name.

### 2. Fetch PR Info and All Comments

```bash
GH_HOST_FLAG=""  # set to "--hostname <host>" if GHE

# PR metadata
gh api repos/${OWNER}/${REPO}/pulls/<PR> ${GH_HOST_FLAG} \
  --jq '{title: .title, head_branch: .head.ref, head_repo: .head.repo.full_name, state: .state, author: .user.login}'

# Review comments (line-specific) — paginate to get all
gh api repos/${OWNER}/${REPO}/pulls/<PR>/comments ${GH_HOST_FLAG} --paginate

# Issue comments (general PR-level)
gh api repos/${OWNER}/${REPO}/issues/<PR>/comments ${GH_HOST_FLAG} --paginate

# Reviews (review body text + state)
gh api repos/${OWNER}/${REPO}/pulls/<PR>/reviews ${GH_HOST_FLAG} --paginate
```

### 3. Ensure Correct Branch

```bash
HEAD_BRANCH=<from PR info .head.ref>
CURRENT_BRANCH=$(git branch --show-current)

# Switch if needed
if [ "$CURRENT_BRANCH" != "$HEAD_BRANCH" ]; then
  git checkout "$HEAD_BRANCH" 2>/dev/null \
    || git checkout -b "$HEAD_BRANCH" ${PUSH_REMOTE}/"$HEAD_BRANCH"
fi
```

### 4. Analyze and Categorize Comments

**Filter out:**
- Own comments (match git user or PR author)
- Bot comments
- Already-resolved threads
- Outdated comments on lines that no longer exist

**Categorize each remaining comment:**

| Category | Action | Example |
|----------|--------|---------|
| **Code change** | Modify code + reply | "Add nil check here", "Move to Debug level" |
| **Question** | Reply only | "Why is this needed?", "Is this intentional?" |
| **Disagreement** | Reply with explanation | Conflicts with project convention |
| **Unclear** | Ask user before proceeding | Ambiguous request |

**For each comment, extract:**
- `id` — for API reply
- `path` — file path
- `line` / `original_line` — line number
- `body` — comment text
- `diff_hunk` — surrounding code context
- `in_reply_to_id` — thread parent (only process latest in each thread)

### 5. Present Analysis to User

Before making changes, show a summary:

```
PR #<number> 리뷰 코멘트 분석:

| # | 작성자 | 파일 | 내용 (요약) | 처리 방식 |
|---|--------|------|-------------|-----------|
| 1 | reviewer1 | internal/manager/foo.go:42 | Add nil check | 코드 수정 |
| 2 | reviewer1 | internal/agent/bar.go:15 | Why Debug level? | 답변만 |
| 3 | reviewer2 | pkg/driver/baz.go:88 | Rename variable | 코드 수정 |

진행할까요?
```

If user approves (or modifies the plan), proceed. If user wants to skip specific comments, respect that.

### 6. Address Each Actionable Comment

For each comment requiring code change:
1. **Read** the relevant file and understand context
2. **Determine** the fix based on the comment + project conventions
3. **Apply** the change using Edit tool
4. **Record** what was done: `{comment_id, file, line, change_summary}`

**Decision rules:**
- Clear code request → implement directly
- Question only → prepare reply, no code change
- Conflicts with project conventions → explain in reply, no change (or ask user)
- Ambiguous → ask user

### 7. Format Code

Run the project's code formatting command. Check CLAUDE.md or project config for the correct command:

- Go projects: `./scripts/apply_format.sh` or `gofmt`
- Python projects: `flake8` + `black` / `isort`
- Frontend projects: `prettier` + `eslint --fix`

### 8. Amend and Force Push (Requires Confirmation)

> **MUST confirm with user before this step.**

Show the full diff of changes:
```bash
git diff          # unstaged
git diff --cached # staged
```

After user confirms:
```bash
git add -A
git commit --amend --no-edit
git push ${PUSH_REMOTE} ${HEAD_BRANCH} --force
```

If **no code changes** were made (all comments were questions/informational), skip this step.

### 9. Reply to Each Comment on GitHub

**For review comments (line-specific):**
```bash
gh api repos/${OWNER}/${REPO}/pulls/<PR>/comments/<COMMENT_ID>/replies \
  ${GH_HOST_FLAG} \
  -f body="<reply>"
```

**For issue comments (general) — post a new comment:**
```bash
gh api repos/${OWNER}/${REPO}/issues/<PR>/comments \
  ${GH_HOST_FLAG} \
  -f body="<reply>"
```

### Reply Format

- **All replies in English**
- Keep replies **concise** (1-2 sentences)
- Start with `Done.` for implemented changes
- Explain reasoning for non-changes

**Examples:**
- `Done. Added nil check before accessing cluster.Status.`
- `Done. Moved to Debug level as suggested.`
- `Good point — this is intentional because the caller guarantees non-nil. No change needed.`
- `Done. Renamed to defaultFabricProvider for clarity.`

## Output to User

```
PR #<number> 리뷰 코멘트 처리 완료!

- 코드 수정: N개
- 답변만: N개
- 스킵: N개
- 변경된 파일: file1.go, file2.go

Force push 완료 (${PUSH_REMOTE}/<branch>)
GitHub 코멘트 답변 완료
```

## Important Notes

- **1 commit per PR**: Always amend the existing commit, never add new commits
- **Force push confirmation**: Must ask user before amending + force pushing
- **English replies**: All GitHub comment replies must be in English
- **Format before push**: Always run the project's format command before amending
- **Don't over-fix**: Only address what the reviewer asked — no extra refactoring
- **Thread awareness**: Only process the latest comment in each thread
- **Respect user overrides**: If user says skip a comment, skip it
- **GHE support**: Use `--hostname` flag when the remote URL is not github.com
