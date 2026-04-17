---
description: "Airflow workflow project rules - DAG conventions, coding style, and development guidelines for Apache Airflow 2.7.3"
globs: apps/airflow/**
alwaysApply: false
---

# Airflow Workflow 프로젝트 - 프로젝트별 규칙

## 프로젝트 개요
- **플랫폼**: Apache Airflow 2.7.3
- **목적**: 테스트 관리 및 워크플로우 자동화
- **주요 컴포넌트**: DAG, Operator, 유틸리티 함수

## 코딩 스타일 및 컨벤션

### Python 코딩 스타일
- 인덴테이션: 4 spaces

### Airflow DAG 작성 규칙
- DAG ID 형식: `{project_name}_{app_name}` (예: test_management_machine_initialization)
- tags 필드 활용하여 DAG 분류

### 파일 구조
- **dags/**: DAG 정의 파일들
- **dags/util/**: 공통 유틸리티 함수
- **dags/resources/scripts/**: 실행 스크립트
- **tests/**: 테스트 코드 (pytest 사용)

## 개발 가이드라인

### 환경 설정
- Docker Compose 기반 개발 환경
- requirements.txt 의존성 관리

## 추천 패턴

### 새 DAG 생성 시
```python
from util import create_dag_with_run_check
from util.execute_params import get_execute_params

dag = create_dag_with_run_check(
    DAG_NAME,
    default_args=default_args,
    description='DAG 설명',
    schedule=None,
    catchup=False,
    params=get_execute_params(),
    tags=["태그1", "태그2"]
)
```

### Operator 생성 시
- util 모듈의 공통 함수 활용
- 환경변수와 파라미터 적절히 활용
- 타임아웃과 풀 설정 필수

## 유틸리티 함수 활용
- `execute_params.py`: 실행 파라미터 관리
- `server.py`: 서버 관련 작업
- `workload.py`: 워크로드 실행
- `short_batch_commons.py`: 배치 작업 공통 기능

## 개발 환경 특이사항
- git 명령어 수행 시 interactive 모드를 피하기 위해서 임시 파일로 빼는 것을 권장

## 커밋 전 마무리 작업

커밋 메시지 작성 직전에 GitHub Actions 워크플로우들이 정상적으로 동작하는지 로컬에서 확인:

1. **PEP8 포맷 체크** (`.github/workflows/pr-checker-pep8-format.yml`):
   ```bash
   cd ./dags
   python3 -m flake8 --select F,E --ignore E501,E722 --show-source
   ```

2. **Unit Test 실행** (`.github/workflows/pr-checker-unittest.yml`):
   ```bash
   string=`python3 -m airflow config list | grep sqlite`
   if [[ $string != "sql_alchemy_conn = sqlite://"* ]]; then
     echo "airflow test db should be sqlite!"
     exit 1
   fi
   python3 -m airflow db init
   python3 -m pytest tests/
   ```

**참고**:
- Github action 중 Coverity 체크는 생략 가능합니다.
- 모든 체크가 통과된 후 바로 커밋 메시지 작성 진행합니다.
