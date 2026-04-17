---
description: "Personal Claude/Cursor settings management - Git repository setup and workflow for managing personal rules and commands"
---

# 개인 설정 관리 (Personal Settings Management)

개인 Claude/Cursor 설정 파일(`~/.claude/rules`, `~/.claude/commands`)을 Git 저장소로 관리하는 방법을 설명합니다.

## 개요

개인 설정 파일들을 별도 Git 저장소로 관리하면:
- 여러 환경(개발 머신, 서버 등)에서 설정 동기화 가능
- 설정 변경 이력 추적 및 롤백 가능
- 팀원과 설정 공유 가능 (선택적)

## 저장소 구조

개인 설정 저장소는 다음과 같은 구조를 가집니다:

```
.claude/
├── commands/          # Git 작업 예약어 커맨드 정의
│   ├── new.md
│   ├── fork.md
│   ├── switch.md
│   ├── sync.md
│   └── finish.md
├── rules/            # 프로젝트별 규칙 파일
│   ├── common.md     # 공통 규칙
│   ├── django.md
│   ├── frontend.md
│   └── ...
├── skills/           # 개인 스킬 문서 (선택적)
│   └── personal-settings-management/
│       └── SKILL.md
└── scripts/          # 설치 및 유틸리티 스크립트
    ├── claude-git    # Git 래퍼 스크립트
    ├── git-wrapper   # Cursor Agent Git 명령어 차단 래퍼
    └── install.sh    # 자동 설치 스크립트
```

## 최초 세팅

### 1. 저장소 초기화

**중요**: WSL 환경에서는 Windows 경로를 사용합니다. WSL에서 구동되는 Cursor도 기본적으로 Windows 경로(`C:/Users/<username>/.claude`)를 환경 설정 경로로 사용하기 때문입니다.

기존 `.claude` 디렉토리를 Git 저장소로 변환:

```bash
# Windows 경로에서 초기화 (WSL 환경)
cd /mnt/c/Users/USER/.claude  # 실제 사용자명으로 변경 필요
git init
git remote add origin <your-personal-repo-url>
```

**심볼릭 링크 설정** (WSL에서 `~/.claude`로 접근하기 위해):

```bash
# Linux 홈 디렉토리에 심볼릭 링크 생성
ln -s /mnt/c/Users/USER/.claude ~/.claude
```

이렇게 하면 Windows와 WSL 양쪽에서 동일한 설정 파일을 사용할 수 있습니다.

### 2. 스크립트 및 Git Alias 설치

**자동 설치 (권장):**

```bash
cd /mnt/c/Users/USER/.claude  # 또는 ~/.claude (Unix/Linux)
./scripts/install.sh
```

이 스크립트는 다음을 설치합니다:
- `claude-git`: 개인 설정 저장소용 Git 래퍼 (`/usr/local/bin/claude-git`)
- `git` wrapper: Cursor Agent의 자동 Git 명령어 실행 차단 (`/usr/local/bin/git`)
- Git alias `claude`: `git claude` 명령어 사용 가능

**Git Wrapper 목적:**
- Cursor Agent 환경에서 `git add/commit/push` 자동 실행 차단
- 의도치 않은 커밋 방지

### 3. 초기 커밋 및 푸시

```bash
git claude add .
git claude commit -m "Initial commit: personal Claude rules and commands"
git claude push -u origin main
```

## 사용 방법

### Git 명령어 사용

`git claude` 명령어를 통해 개인 설정 저장소를 관리:

```bash
# 상태 확인
git claude status

# 변경사항 스테이징 및 커밋
git claude add .
git claude commit -m "Update rules: add new project rules"

# 푸시 및 풀
git claude push
git claude pull

# 로그 확인
git claude log --oneline
```

### 일반적인 워크플로우

1. **규칙 파일 수정**
   - `rules/common.md` 또는 프로젝트별 규칙 파일 편집

2. **변경사항 확인 및 커밋**
   ```bash
   git claude status
   git claude diff
   git claude add .
   git claude commit -m "Update: add new workflow rules"
   ```

3. **원격 저장소에 푸시**
   ```bash
   git claude push
   ```

4. **다른 환경에서 동기화**
   ```bash
   git claude pull
   ```

## 주의사항

- 개인 설정은 프로젝트 저장소에 포함되지 않으며, 각 개발자가 별도로 관리합니다
- Windows 파일 시스템 경로를 사용하는 경우, Git 작업 성능이 저하될 수 있습니다
- 여러 환경에서 동기화할 때는 충돌에 주의하세요
- 심볼릭 링크는 WSL에서 `~/.claude`로 접근하기 위한 것이며, Git 작업은 실제 Windows 경로에서 수행됩니다
- **Git Wrapper**: Cursor Agent 환경에서 `git add/commit/push` 등이 차단됩니다. 터미널에서 직접 실행하거나 `claude-git`를 사용하세요

## 참고

- 개인 저장소의 `README.md`에 더 자세한 내용이 있습니다
- 프로젝트 공통 규칙은 프로젝트 저장소의 `.claude/skills/` 또는 `AGENTS.md`를 참고하세요
