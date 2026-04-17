# `use` - clone 경로를 Cursor로 열기 (환경 완전 분리)

## 용도
- **이미 있는 clone(또는 리포) 폴더를 새 Cursor 창에서 연다.** 선언 없이, 해당 창에서만 그 경로를 쓰므로 환경이 완전히 분리됨.

## 사용법
- `use <path>` — 절대 경로를 그대로 사용 (예: `use /home/sh/cursor/mats-monorepo-pr-214`)
- `use <hint>` — 부모 디렉터리 아래 **hint를 이름에 포함하는** 디렉터리를 찾아 그 경로 사용 (예: `use 217` → `mats-monorepo-pr-217`, `use pr-217` → `mats-monorepo-pr-217`)

## 동작
1. **경로 해석**
   - 인자가 `/` 로 시작하면 절대 경로로 사용.
   - 그 외 (hint): 현재 워크스페이스 루트에서 `git rev-parse --show-toplevel` 로 리포 루트와 이름 확인. **부모 디렉터리 = `dirname(루트)`.** 부모 아래 디렉터리 목록을 보고 **이름에 hint가 포함된** 항목을 grep(또는 일치 검색).
   - **매칭 규칙**: `ls -1 <부모>` 한 결과에 대해 hint가 **부분 문자열로 포함**된 디렉터리만 사용. (예: hint `217` → `mats-monorepo-pr-217` 매칭.)
   - 정확히 하나 매칭되면 그 경로를 해석 결과로 사용. 여러 개면 모두 나열하고 사용자에게 더 구체적인 hint 지정 요청. 없으면 "해당하는 디렉터리 없음" 안내.
2. **Cursor 실행**
   - **`cursor <해석된_절대_경로>`** 를 실행하여 해당 폴더를 새 Cursor 창에서 연다. 그 창에서 작업하면 해당 경로만 사용되므로 환경이 격리됨.
3. **안내 출력** (선택)
   - "**`cursor`** 로 `<해석된_절대_경로>` 를 열었습니다. 새 창에서 작업하세요."

## 주의
- `use` 는 **해당 폴더를 Cursor로 열기만** 함. 폴더 생성·체크아웃·clone 은 하지 않음. 선언 없이 새 창 = 완전 분리.

## 예시
- `use 217` — 부모 아래 이름에 `217` 이 포함된 디렉터리(예: `mats-monorepo-pr-217`)를 찾아 Cursor로 열기
- `use pr-217` — 부모 아래 이름에 `pr-217` 이 포함된 디렉터리(예: `mats-monorepo-pr-217`)를 찾아 Cursor로 열기
- `use mats-monorepo-pipeline-list-product-agnostic` — 부모 아래 해당 이름 디렉터리를 찾아 Cursor로 열기
- `use /home/sh/cursor/mats-monorepo-pr-214` — 절대 경로를 Cursor로 열기
