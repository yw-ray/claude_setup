# `finish` - 커밋 전 마무리 작업 수행

커밋 메시지 작성 직전에 GitHub Actions 워크플로우들이 정상적으로 동작하는지 로컬에서 확인해야 합니다.

## 사용법
- `finish`

## 동작
- 커밋 전 마무리 작업을 수행하고 모든 체크가 통과되면 커밋 메시지 작성 진행

## 수행 항목
1. **가상환경 확인 및 활성화**:
   - **Django (`apps/django`)**: `apps/django/.venv` (또는 `venv`) 확인
     - 가상환경이 없으면 생성: `cd apps/django && python -m venv .venv`
     - 활성화: `cd apps/django && source .venv/bin/activate` (또는 `venv/bin/activate`)
     - 의존성 설치: `pip install --upgrade pip && pip install -r requirements.txt`
   - **Frontend (`apps/frontend`)**: 가상환경 선택사항 (Node.js 프로젝트는 일반적으로 Python venv 불필요)
   - **Airflow (`apps/airflow`)**: `apps/airflow/.venv` 확인 및 활성화
   - **Test Runner (`apps/test-runner`)**: `apps/test-runner/.venv` (또는 `venv`) 확인 및 활성화
   - 활성화 후 Python 버전 확인: `python --version` (Django는 Python 3.11 필요)
2. **Github Action 검증 확인**: 공통적으로 GitHub Actions 워크플로우 파일 (`.github/workflows/pr-checker-*.yml`)을 참고하여 로컬에서 수행 가능한 동일한 체크를 수행합니다.
   - **Frontend 프로젝트의 경우**: Build 테스트는 생략합니다 (시간이 오래 걸리고 불필요). ESLint, Prettier, Unit Test만 수행합니다.
   - 다른 프로젝트의 경우: 워크플로우 파일에 따라 수행 가능한 체크를 모두 수행합니다.
3. **플랜 파일 업데이트 (필수, 관련 플랜이 있을 때)**: `.claude/plans/`에 현재 작업과 관련된 플랜 파일이 있으면 반드시 완료된 작업 항목을 반영합니다.
   - 플랜 파일 찾기: `.claude/plans/` 폴더의 모든 `.md` 파일을 확인하고, 현재 작업 내용과 관련된 플랜 파일을 찾습니다.
   - 작업 항목 확인: 플랜 파일에서 완료된 작업 항목을 확인합니다 (변경된 파일, 커밋 메시지 내용 등을 기반으로 판단).
   - 플랜 파일 업데이트: 완료된 작업 항목에 체크박스(`- [x]`) 추가 또는 완료 표시(`✅`) 추가.
   - 커밋 메시지 반영: 플랜 파일 업데이트 내용을 커밋 메시지의 Changes 섹션에 포함합니다.

**구현 가이드라인:**
- **커밋 메시지 작성 시 반드시 `.claude/skills/commit-rules/SKILL.md`를 읽고 그 규칙을 따라 생성한다.** 특히 본문 규칙의 Changes 섹션: 기능적 개선사항 중심으로 작성하고, 구체적인 파일명·파일별 나열은 하지 않는다.
- 코드 박스의 언어는 `text` 또는 `gitcommit`을 사용
- `COMMIT_MSG.txt` 같은 파일을 생성하지 않습니다 (버전 관리 혼란 방지)
- 커밋 메시지는 채팅에만 노출되며, 사용자가 직접 복사하여 사용합니다

## 커밋 메시지 제공 방식

커밋 메시지는 **마크다운 코드 박스(```)로 감싸서 채팅에 노출**되어 사용자가 직접 확인하고 복사할 수 있습니다.

**출력 형식:**

```text
[컴포넌트명] <Jira 이슈>: 제목

This patch <커밋 내용 요약>. <추가 설명이나 배경 정보>.

Changes:
- <변경사항 1>
- <변경사항 2>
- <변경사항 3>

Related to: plans/<filename>.md (<phase_name>)
```

## 참고
- `.claude/rules/<app>.md` 파일이 존재하는 경우, 해당 파일의 프로젝트별 커밋 전 마무리 작업 지침을 우선적으로 참고
- Coverity 체크는 생략 (로컬에서 수행 불가)
- Frontend 프로젝트의 Build 테스트는 생략 (로컬에서 수행하지 않음)
- 각 체크 실패 시 오류 메시지 표시 및 수정 안내
- 모든 체크 통과 후 커밋 메시지 작성 규칙에 따라 커밋 메시지 생성
- 관련 플랜 파일이 없거나 찾을 수 없는 경우에만 플랜 업데이트 단계를 건너뜁니다 (있으면 필수)
- COMMIT 메시지는 반드시 코드 박스 형태로 제공하며, 임시 파일 등에 작성하지 않습니다

## 추후 작업 개선을 위한 문서화 추천 (선택)

마무리 시 선택적으로 다음을 검토하고, 필요하면 문서화를 추천합니다. (위의 플랜 파일 업데이트와 별개이며, 필수 아님.)

- **스킬(skills)**: 반복되는 작업 절차·패턴이 있으면 `.claude/skills/` 또는 프로젝트의 `.claude/skills/`에 SKILL 문서로 정리
- **문서(docs)**: 기능·아키텍처·API 동작 등이 복잡하거나 팀이 공유할 만하면 `.claude/docs/`에 문서 추가
- **플랜(plans)**: 미완료·후속 작업이 남았으면 `.claude/plans/`에 후속 계획을 기록하거나 기존 플랜에 항목 추가
