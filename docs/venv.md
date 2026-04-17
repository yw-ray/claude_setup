# 가상환경(.venv) – 워크스페이스마다 각자 구축

## 요약

- **의존성 격리를 위해 워크스페이스(클론)마다 .venv를 각자 구축**한다. 다른 경로의 .venv를 재사용하지 않음.
- 각 워크스페이스에서 해당 앱 디렉터리로 이동한 뒤 `python -m venv .venv` → `pip install -r requirements.txt` 로 구축하면 됨.

## 워크스페이스별 구축

- **클론/별도 경로**에서 작업할 때 (`clone` / `use` 로 연 창):
  - 그 워크스페이스 안에서 **해당 앱의 .venv를 새로 만들고** `pip install -r requirements.txt` 로 의존성 설치.
  - 예: `cd apps/django && python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`
- **requirements.txt가 바뀌면** 해당 워크스페이스의 .venv에서 `pip install -r requirements.txt` 로 맞춰 주면 됨.
- .venv 삭제·재생성은 requirements 변경이나 환경 꼬임이 있을 때만 하면 됨.

## 정리

- .venv = **워크스페이스(경로)마다 하나씩 구축**. 재사용·공유 없이 의존성 격리.
