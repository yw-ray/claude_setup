# `new` - 새로운 작업 시작

## 사용법
- `new` 또는 `new <branch_name>`

## 동작
- `git fetch upstream` 후 `git checkout -b <branch_name> upstream/main`으로 새로운 브랜치 생성

## 브랜치명
- 생략 시 작업 내용 기반으로 추천
- **중요: 이슈 번호(MATS-XXXX)를 브랜치명에 포함하지 마세요**
  - ❌ 잘못된 예: `feature/MATS-1595-test-runner-dockerization`
  - ✅ 올바른 예: `feature/test-runner-dockerization`
- 이슈 번호는 커밋 메시지에만 포함되며, 브랜치명과는 별도로 관리됩니다

## 주의
- 기존 브랜치는 내용이 그대로 유지되어야 함. 즉, 기존 브랜치를 수정하지 않도록 주의

## 참고 (로컬 리포 격리)
- 여러 에이전트가 동시에 작업할 때는 먼저 `clone`으로 격리된 워크스페이스를 만들고, **해당 클론 폴더를 새 Cursor 창에서 연 뒤** 그 안에서 `new`를 실행하세요.
- 개인 개발 워크플로우: `~/.claude/docs/personal-dev-workflow.md`
