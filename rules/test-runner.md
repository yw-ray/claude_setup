---
description: "Test Runner project rules - Python code style, unittest conventions, JSON configuration, and test execution guidelines"
globs: apps/test-runner/**
alwaysApply: false
---

# Test Runner 프로젝트 - 프로젝트별 규칙

## Python 코드 루트
- **Python 코드 루트**: `apps/test-runner/` 디렉토리
- **메인 모듈**: `apps/test-runner/main.py`

## 코드 품질

### Python 코드 스타일
- **flake8 린팅**: `python3 -m flake8 .`
- **isort**: import 정렬 (black 프로필 사용)
- **작업 완료 후 자동 pep8 체크**:
  ```bash
  cd ./apps/test-runner
  # 가상 환경 확인 및 활성화 (.venv 사용)
  if [ ! -d ".venv" ]; then
    python3 -m venv .venv
  fi
  source .venv/bin/activate
  pip install --upgrade pip -q
  pip install -r requirements.txt -q

  # 린팅 체크 실행
  python -m flake8 .
  python -m isort --check-only --diff .
  ```

### Shell 스크립트 스타일
- **들여쓰기**: 2칸 공백을 사용합니다.

### PEP8 Dictionary 정렬 규칙
- **Dictionary key-value 정렬**: 여러 줄에 걸친 dictionary에서 첫 번째 key와 같은 수준으로 정렬
- **올바른 예시**:
  ```python
  @TestCase(enabled=True,
            input_schema={"gdr_on_case": {"type": "boolean", "default": True},
                          "gdr_off_case": {"type": "boolean", "default": False},
                          "start_size_in_mb": {"type": "integer", "default": 1},
                          "end_size_in_mb": {"type": "integer", "default": 1024},
                          "num_iters": {"type": "integer", "default": 20, "description": "rccl-tests -n option"},
                          "num_cycles": {"type": "integer", "default": 1,
                                         "description": rccl_test_cycle_description}})
  ```
- **핵심**: Dictionary의 key들이 첫 번째 key와 같은 수준으로 정렬되어야 하며, `category` 등의 추가 매개변수는 `input_schema`와 같은 수준에 위치해야 함


## 테스트 코드 규칙

### 테스트 개요
- unittest 프레임워크 사용
- pytest는 사용하지 않음
- source root는 `apps/test-runner/` 폴더

### 테스트 클래스 작성
- 테스트 코드는 테스트 케이스 클래스 단위로 작성
- **클래스명**: `*Test` 접미사 사용
- **메서드명**: `test_*` 접두사 사용
- **상속**: `TestCaseBaseClass` 상속

### 테스트 데이터
- **JSON 설정**: `resources/examples/` 디렉토리에 저장
- **스키마 검증**: jsonschema 사용
- **예제 파일**: 실제 사용 사례 반영

## 설정 파일 규칙

### JSON 설정 파일
- **구조**: `system_configuration`, `test_configuration`, `log_configuration`
- **네이밍**: `*_input.json`, `*_output.json`
- **검증**: 스키마 기반 검증 필수

## 커밋 메시지 특화 규칙

### 말머리 형식
- **일반 수정**: `[TestRunner/<카테고리>]` (첫 글자 대문자)
- **긴급 수정**: `[Hotfix/TestRunner/<카테고리>]`
- **스페이스**: `TestRunner` - 테스트 실행, `apps/test-runner/` 아래 변경사항 발생 시

### 카테고리 매칭
코드가 주요하게 기여하는 프로젝트 또는 카테고리를 아래 후보군 중에서 매칭하여 지정:
- `Misc`: 프로젝트 특정 불가능시 기본 카테고리 값. 전체 프로젝트에 공통적으로 적용되는 사항
- `Storage`: 스토리지 관련 프로젝트에 공통적으로 적용되는 사항, 대상 프로젝트: `NRT`, `NTT`, `NTT-NTI`, `NTI`
- `TOE` (TCP offload engine): `toe`
- `NRT` (NVMe-oF RDMA Target): `nrt`
- `NTT` (NVMe-oF TCP Target): `ntt`
- `NTT-NTI` (NTT and NTI): `ntt_nti`
- `NTI` (NVMe-oF TCP Initiator): `nvme_tcp`
- `BaseNIC` (Base Network Interface Card): `base_nic`
- `NV` (Network Virtualization): `nv`
- `RDMA` (Remote Direct Memory Access): `rdma`

### 제목 규칙
- 최대 길이: 60자 (말머리 포함)
- 스페이스, 카테고리 반드시 포함
- 예시: `[TestRunner/NTT] PROJ-123: Add NVMe-oF TCP Target test support`

### 본문 규칙
- 변수들은 코드 블럭으로 감싸줘

## 커밋 전 마무리 작업

커밋 메시지 작성 직전에 GitHub Actions 워크플로우들이 정상적으로 동작하는지 로컬에서 확인:

1. **PEP8 포맷 체크** (`.github/workflows/pr-checker-test-runner-format.yml`):
   ```bash
   cd ./apps/test-runner
   # 가상 환경 확인 및 활성화 (.venv 사용)
   if [ ! -d ".venv" ]; then
     python3 -m venv .venv
   fi
   source .venv/bin/activate
   pip install --upgrade pip -q
   pip install -r requirements.txt -q

   # 포맷 체크 실행
   python -m isort --check-only --diff .
   python -m flake8 .
   ```

2. **Unit Test 실행** (`.github/workflows/pr-checker-test-runner-unittest.yml`):
   ```bash
   cd ./apps/test-runner
   python3 -m unittest
   ```

3. **Test Class Info 확인** (`.github/workflows/register-testclass-info.yml`):
   ```bash
   cd ./apps/test-runner
   python3 main.py info >/dev/null
   ```
   - 에러 없이 실행되는지만 체크

**참고**:
- Github action 중 Coverity 체크는 생략 가능합니다.
- 모든 체크가 통과된 후 바로 커밋 메시지 작성 진행합니다.
