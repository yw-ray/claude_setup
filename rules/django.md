---
description: "Django backend project rules - API design, database optimization, testing conventions, and Django-specific best practices"
globs: apps/django/**
alwaysApply: false
---

## 로컬 Cursor 규칙 (프로젝트별)

### 내부 데이터 처리 원칙

- 내부 애플리케이션 간 데이터 (예: `raw_query`, `context`, 내부 serializer 등)는 방어적 파싱/검증/폴백 로직을 지양한다.
- 코드는 단순하고 직선적으로 작성한다. (데이터 형태는 올바르다고 가정한다.)
- Fail-fast로 동작한다. (이런 내부 payload에 대해 광범위한 `try/except`로 예외를 삼키지 않는다.)

# 로컬 Cursor 규칙 (개인)

## 백엔드 도메인
- backend_domain: testexec.mangoboost.io
- API base url: https://test.mangoboost.io/

## Assistant Workflow (Personal)
- **로컬 서비스 사용 금지**: 로컬 서비스(localhost, 127.0.0.1, 로컬 포트)는 개발용으로 데이터가 없거나 깡통 상태이므로 절대 사용하지 않음
- 로컬 DB는 보지 않는다.
- 로컬 환경에는 유의미한 데이터가 없음
- 데이터 조회는 반드시 서비스 인스턴스의 API를 통해 조회해야 함
- API 데이터를 로컬로 수집하여 테스트한다.
- **서비스 URL: https://testexec.mangoboost.io 사용. test-dev.mangoboost.io(개발 서버)는 사용하지 않음.** (개발 서버는 버전 관리되지 않음)
- API 엔드포인트 예시:
  - `https://testexec.mangoboost.io/api/pipelineruns/` - 테스트 실행 목록 조회
  - `https://testexec.mangoboost.io/api/pipelineruns/<test_id>` - 특정 테스트 실행 정보 조회
  - `https://testexec.mangoboost.io/api/pipelines/` - Pipeline 목록 조회
  - 기타 API 엔드포인트는 `common.md`의 "테스트 분석 관련 정보" 섹션 참고
- Django shell이나 직접 DB 쿼리 대신 API 호출을 사용
- curl 또는 Python requests를 사용하여 API 호출
- 로컬 서버 실행 명령어(`python manage.py runserver` 등)는 실행하지 않음

## 코드 스타일 & 아키텍처

### 일반 규칙
- string의 경우 작은 따옴표로 작성 우선
- type hint에서 python generic을 typing package보다 우선함. 즉, 가급적 typing package를 사용하지 않음.
  - 예시
    - list[int] > typing.List[int]
    - dict[str, int] > typing.Dict[str, int]
    - set[int] > typing.Set[int]
    - Callable[[int], str] > typing.Callable[[int], str]
    - str | None > typing.Optional[str]
    - str | int | None > typing.Union[str, int, None]

### Django Models
- 모델 메서드에 영어 docstring 추가
- `__str__` 메서드 항상 구현
- `Meta` 클래스에 `verbose_name`, `ordering` 설정
- `unique_together`, `index_together` 활용
- `db_index=True`로 자주 조회되는 필드 최적화

### Django Views
- 하드코딩된 딕셔너리 대신 serializer 사용
- 딕셔너리 언패킹 (`{**dict1, **dict2}`) 선호

## Django 설정 & 환경

### 설정 구성
- 로컬 개발에는 `mango_test_mgmt.settings.local` 사용

### 코드 품질
- flake8 린팅: `--select=F,E --ignore=E501,E722`
- black 포맷팅: `--line-length=120`
- 작업 완료 후 자동으로 모든 파일에 대한 pep8 체크 수행:
  - <root>/web에서 수행 해야 함.
  - 수행 명령어: `python -m flake8 --select F,E --ignore E501,E722 --per-file-ignores="mango_test_mgmt/settings/*.py:F401,F403,F405,E402 __init__.py:F401 */apps.py:F401" --show-source`
- **F841 에러 해결**: 사용하지 않는 변수 할당이 발생하는 경우, 변수에 할당하지 말고 객체 생성만 수행. 예: `obj = Model.objects.create(...)` → `Model.objects.create(...)`

## API 설계 & 데이터베이스

### API 설계
- Django REST Framework serializer 사용
- 구조화된 응답 선호
- 적절한 HTTP 상태 코드 사용

### 쿼리 최적화
- `select_related()`로 ForeignKey 관계 최적화
- `prefetch_related()`로 ManyToMany 관계 최적화
- `only()`, `defer()`로 필요한 필드만 조회
- `bulk_create()`, `bulk_update()` 사용

## 성능 & 보안

### 캐싱 전략
- `@cached_property`로 계산 비용이 큰 속성 캐싱
- `cache.get()`, `cache.set()`으로 데이터베이스 부하 감소
- `select_for_update()`로 동시성 제어

## 자동화 & 테스트

### 시그널 활용
- `pre_save`, `post_save`로 데이터 변경 감지
- `pre_delete`, `post_delete`로 정리 작업
- `m2m_changed`로 ManyToMany 관계 변경 감지

### 테스트 컨벤션 규칙
- `TestBaseClass` 상속으로 데이터베이스 격리
- 테스트 클래스 이름은 `TestClass` suffix 사용 (예: `MyFeatureTestClass`)
- `@patch`로 외부 의존성 모킹
- `mango_test_mgmt.settings.local`를 세팅 모듈로 사용.
- 가급적이면 전체 테스트 일괄 수행은 지양하고, 프로젝트별 테스트를 수행.
  - pipelines는 크기 때문에 파일별 테스트를 수행.
  - 테스트 디버그 관계로 재수행을 하는 경우 관련 테스트만 수행.
- 현재 DB 스키마에는 기존 작업이 남아있을 수 있음 마이그레이션 시 무시 할 것.
  - 예) 기존 작업에서 test_layout이 필수가 되었는데, main에는 반영 안된 상황에서 새로운 작업이 개시됨. 이런 경우 새로운 작업에서는 기존 작업의 맥락을 잊어버려야 함.

#### TestBaseClass 상속 구조
- 모든 테스트 클래스는 `TestBaseClass`를 상속해야 함
- `TestBaseClass`는 `APITestCase`를 상속하여 APIClient 기능 제공
- `self.client = Client()` 직접 정의 금지

#### super().setUp() 반드시 호출
- 모든 테스트 클래스에서 `super().setUp()` 반드시 호출
- 단순히 `super().setUp()`만 호출하는 불필요한 `setUp` 메서드 제거

## Daily Report 작성 규칙

사용자가 "daily report 작성해줘" 또는 유사한 요청을 하면 다음을 단계별로 수행:

### 1. Django 서비스 로그 검토
- 어제 일자(00:00:00 ~ 23:59:59)의 Django 서비스 로그 검토
- 로그 경로: `/mnt/mats/vm_home/mango-test-mgmt/web/logs/`
- 주요 확인 대상:
  - `django/django_error.log` (현재 파일 및 날짜 파일)
  - `django/request_error.log` (현재 파일 및 날짜 파일)
  - `application/*/*_error.log` (현재 파일 및 날짜 파일)
- 발견된 에러에 대한 분석 및 수정 필요 여부 리포트

### 2. 테스트 실패 사례 분석
- 어제 오전 9시 이후 ~ 현재 시점까지의 테스트 중 실패 사례 분석
- API를 통해 조회: `https://testexec.mangoboost.io/api/pipelineruns/`
- 필터링: `is_success=False`
- 각 실패 케이스에 대한 상세 분석:
  - 실패한 Stage/Task
  - Failure Context 분석
  - 로그 파일 경로 확인 (`/mnt/mats/vm_home/mango-workflow/logs/`) - DAG ID와 TASK ID 이용하여 구체적 경로 조회
  - 원인 분석 및 패턴 파악
- **참고**: 테스트 분석은 일자별로 겹쳐도 괜찮음

### 주의사항
- **단계별 수행**: 한 번에 모든 작업을 수행하지 말고, 각 단계를 완료한 후 다음 단계로 진행
- **월요일 처리**: 오늘이 월요일이면 지난주 금요일 이후부터 조회
- **휴일 이후**: 휴일 이후 출근일이면 사용자가 N일 치를 요청할 것임

## 커밋 메시지 특화 규칙

### 본문 구조
- 구조: 설명 → Changes 순서로 작성
- Changes 이후 추가 텍스트 붙이지 않기
- Changes 뒤에 나오는 메시지는 가급적 본문 위치로 보내기

## 커밋 전 마무리 작업

커밋 메시지 작성 직전에 GitHub Actions 워크플로우들이 정상적으로 동작하는지 로컬에서 확인:

1. **PEP8 포맷 체크** (`.github/workflows/pr-checker-pep8-format.yml`):
   ```bash
   cd ./web
   python -m flake8 --select F,E --ignore E501,E722 --per-file-ignores="mango_test_mgmt/settings/*.py:F401,F403,F405,E402 __init__.py:F401 */apps.py:F401" --show-source
   ```

2. **Django Unit Test 실행** (`.github/workflows/pr-checker-test-mgmt-django.yml`):
   ```bash
   cd ./web
   rm */migrations/[0-9]*.py || true
   python manage.py makemigrations
   python manage.py test
   ```

**참고**:
- Github action 중 Coverity 체크는 생략 가능합니다.
- 모든 체크가 통과된 후 바로 커밋 메시지 작성 진행합니다.
