---
description: "Python 가상환경(.venv) 확인·생성·활성화. 최초 세션 및 Python 명령 실행 전에 적용. 모노레포/단일 프로젝트 경로 규칙."
---

# Python 가상환경 설정 스킬

Python 명령 실행 전에 가상환경(.venv)이 올바르게 설정되어 있는지 확인하고, 없으면 생성·활성화 절차를 따른다. **최초 세션**에서 가상환경을 못 잡는 문제를 줄이기 위해, 적용 시점과 체크 순서를 명시한다.

## 적용 시점

다음 상황에서는 **반드시** 이 스킬을 적용한다.

- **Python 관련 명령**을 실행하기 직전: `python`, `pip`, `pytest`, `manage.py`, `flake8`, `makemigrations` 등
- **최초 세션**에서 워크스페이스가 모노레포(또는 단일 Python 프로젝트)이고, 대화·열린 파일이 Python 앱을 건드리는 경우
- 사용자가 "Django 실행해줘", "테스트 돌려줘", "pip install 해줘" 등을 요청한 경우

위 상황에서는 **먼저** 가상환경 존재·활성화를 확인하고, 필요하면 아래 절차를 따른다.

## 워크스페이스·경로 규칙

- **모노레포 (mats-monorepo 등)**: 가상환경은 **앱별로 독립** (`apps/<app>/.venv`).
  - 예: `apps/django/.venv`, `apps/airflow/.venv`, `apps/test-runner/.venv`
- **단일 프로젝트**: 프로젝트 루트의 `.venv`
- **다른 경로의 .venv 재사용 금지**: 클론/워크스페이스마다 **그 경로 안에서** .venv를 새로 만들고 쓴다. 다른 워크스페이스의 .venv를 참조하지 않는다.
  - 상세: [~/.claude/docs/venv.md](~/.claude/docs/venv.md)

## 세션 시작·실행 전 체크

Python 명령을 **실행하기 전에** 다음을 수행한다.

1. **대상 앱/경로 결정**: 열린 파일 경로, 사용자 요청, 또는 cwd로 `apps/django` / `apps/airflow` / `apps/test-runner` 등 판단.
2. **.venv 존재 여부**: 해당 경로에 `apps/<app>/.venv`(또는 단일 프로젝트면 루트 `.venv`)가 있는지 확인.
3. **활성화 여부**: 터미널에서 `which python`이 해당 .venv 안의 python을 가리키는지 확인.

- **.venv가 없으면**: ".venv가 없습니다. 다음으로 생성·활성화한 뒤 진행할까요?" 안내 후 아래 생성·활성화 절차 제시 또는 실행.
- **.venv는 있는데 비활성화**: "가상환경이 활성화되어 있지 않습니다. `cd apps/<app> && source .venv/bin/activate` 후 다시 실행해 주세요." 안내 또는 해당 명령 실행.

## 생성·활성화 절차

- **생성**: `cd <app_path> && python -m venv .venv` (또는 `python3 -m venv .venv`)
- **활성화**: `cd <app_path> && source .venv/bin/activate`
- **의존성 설치**: 활성화된 상태에서 `pip install -r requirements.txt` (모노레포는 `apps/<app>/requirements.txt`)

한 번에 수행할 때 예시:

```bash
cd apps/django && python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
```

## 터미널 명령 실행 시

`python` / `pip` / `pytest` / `manage.py` 등을 **실행하는** 터미널 명령을 제안할 때:

- 해당 앱의 **가상환경이 활성화된 셸**에서 실행한다고 가정하고 명령을 제시하거나,
- 명령 앞에 `(cd apps/<app> && source .venv/bin/activate && ...)` 형태로 활성화를 포함하거나,
- "먼저 `cd apps/<app> && source .venv/bin/activate` 실행 후 아래 명령을 실행하세요"라고 명시한다.

최초 세션에서는 가상환경이 없거나 비활성화된 상태일 수 있으므로, 위 체크를 먼저 수행한 뒤 명령을 실행한다.

## 확인 방법

- **활성화 여부**: `which python` → `.../apps/<app>/.venv/bin/python` (또는 `.../.venv/bin/python`) 이면 활성화됨.
- Python 명령 실행 전에 `which python`으로 가상환경 활성화 여부를 확인할 수 있다.

## 참조

- **~/.claude/docs/venv.md** — .venv 정책 (워크스페이스마다 각자 구축, 재사용 금지)
- **~/.claude/rules/common.md** — "Python 프로젝트 로컬 가상화 환경" 섹션 (모노레포/단일 프로젝트 경로, 활성화 안내)
