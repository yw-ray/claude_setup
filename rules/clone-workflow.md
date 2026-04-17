---
description: "Clone workflow rules - agent-isolated workspace, cursor open path, use current workspace only"
alwaysApply: false
---

# Clone 워크플로우 규칙

에이전트별 격리된 워크스페이스(clone)를 쓸 때, **어디서 작업할지**에 대한 규칙.

## 에이전트 동작 규칙

- **작업 대상은 항상 현재 열린 워크스페이스(폴더) 경로다.** 다른 경로(예: 원본 모노레포)를 가정하지 말 것.
- `clone` / `use` 는 해당 경로를 **`cursor <경로>`** 로 새 창에서 열어서, 사용자는 그 창에서만 작업하면 됨. 선언이나 "지정된 클론 경로" 개념 없이, **열린 창 = 그 경로** 이므로 환경이 완전히 분리됨.
- "계획한 작업 해줘", "플랜 실행해줘", `new`, `finish` 등은 **현재 워크스페이스** 기준으로만 수행할 것.
- clone으로 경로를 만들었다면, `clone` 실행 시 **`cursor <target_path>`** 가 실행되어 새 창에서 열리므로, 그 창에서 계속 작업하라고 안내할 것.

## Clone / Use 커맨드 (참고)

- **`clone`**: 격리용 클론 생성 후 **`cursor <target_path>`** 실행하여 해당 경로를 새 Cursor 창에서 연다. 그 창에서만 이후 작업을 수행하면 됨.
- **`use`**: 이미 있는 clone(또는 리포) 경로를 **`cursor <경로>`** 로 새 Cursor 창에서 연다. 선언 없이 새 창 = 완전 분리.
- 클론을 만든 뒤에는, **그 클론을 연 Cursor 창(워크스페이스)** 에서만 `new`, `finish`, 플랜 실행 등을 수행한다. 에이전트는 현재 워크스페이스가 클론 경로라고 가정하고 동작한다.

## 가상환경(.venv)

- 클론(워크스페이스)에서 Python 가상환경이 필요할 때 **해당 워크스페이스 안에서 .venv를 각자 구축**해서 쓴다. 의존성 격리를 위해 다른 경로의 .venv를 재사용하지 않음. 자세한 기준: [~/.claude/docs/venv.md](~/.claude/docs/venv.md).

## 참고

- `clone` 커맨드 상세: `~/.claude/commands/clone.md`
- `use` 커맨드 상세: `~/.claude/commands/use.md`
- 개인 개발 워크플로우: `~/.claude/docs/personal-dev-workflow.md`
