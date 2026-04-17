---
description: "Common rules applied to all projects - development environment, security, commit messages, code quality standards, and general best practices"
alwaysApply: true
---

# 공통 Cursor Rules - 모든 프로젝트 적용

## 로컬 규칙 참고
- `.claude/rules/<app>.md` 파일이 존재하는 경우, 해당 파일의 규칙을 우선적으로 참고하고 적용
- 앱별 규칙과 공통 규칙이 충돌하는 경우, 앱별 규칙을 우선 적용

## test-dev 미사용 (개인 환경)
- **test-dev.mangoboost.io(개발 서버)는 사용하지 않는다.** 개발 서버는 버전 관리되지 않음.
- API 호출·테스트 분석 시에는 **testexec.mangoboost.io**(프로덕션 Backend), **test.mangoboost.io**(프로덕션 Frontend)를 사용한다.

## 개발 환경

### Git Repository 사용 원칙

**Remote 설정:**
- **upstream**: `MangoBoost/mats-monorepo` (메인 저장소)
- **origin**: `<user>/mats-monorepo` (개인 fork 저장소)

**사용 원칙:**
- `upstream`은 `main` 브랜치만 존재 (서비스 repo는 단일 branch 모드)
- 기본 브랜치는 항상 `upstream/main`에서 당겨옴
- `origin/<branch_name>`은 작업 브랜치 (개인 작업 내용)
- `origin/main`은 관리하지 않음 (항상 `upstream/main`에서 당겨옴)
- 작업 브랜치는 `origin`에 push하여 PR 생성

### Git 작업 규칙

- 커밋은 자동화하지 말 것 (git add, git commit, git push는 유저가 진행, 기본적으로 git alias에 의해 차단)
- 브랜치 이름은 20자 내외로. 입력하기에 너무 길지 않아야 함.
- 브랜치 명에 이슈 번호 적지 않을 것.

### 보안 토큰 관리

- API 토큰 및 기타 보안 정보는 `~/.config/my-secrets/` 디렉토리에 저장 (XDG Base Directory 표준 준수)
- 환경 변수는 `~/.config/my-secrets/tokens.env` 파일에 저장
- 파일 형태의 인증 정보(예: JSON 키 파일)는 `~/.config/my-secrets/<service>/` 디렉토리에 저장
- `~/.profile` 파일에서 `source ~/.config/my-secrets/tokens.env`로 환경 변수로 로드
- Python 코드에서 토큰을 사용할 때는 환경 변수에서 읽어오거나, Bearer 토큰이 아닌 경우 `.netrc` 파일도 사용 가능
- 예시:
  ```bash
  # ~/.config/my-secrets/tokens.env 파일 형식 (KEY=VALUE 형식, export 포함)
  # export SENTRY_API_TOKEN=sntryu_...
  # export JIRA_API_TOKEN=your_jira_token
  # export SLACK_BOT_OAUTH_TOKEN=xoxp-...   # 또는 xoxb-... (Slack API, 로컬 메시지 조회 등)

  # Google Workspace API (Refresh Token 방식)
  # export G_CLIENT_ID="your-client-id.apps.googleusercontent.com"
  # export G_CLIENT_SECRET="your-client-secret"
  # export G_REFRESH_TOKEN="your-refresh-token"

  # ~/.profile에 추가
  # if [ -f "$HOME/.config/my-secrets/tokens.env" ]; then
  #     source "$HOME/.config/my-secrets/tokens.env"
  # fi
  ```

  **디렉토리 구조:**
  ```
  ~/.config/my-secrets/
  ├── tokens.env                    # 환경 변수 (API 토큰 등)
  └── google-workspace/
      └── service-account.json      # Google Workspace API 서비스 계정 키 (선택사항)
  ```

  **Google Workspace API 토큰 생성:**
  - Refresh Token 방식을 사용 (`get_gtoken` bash 함수)
  - `~/.bashrc`에 정의된 `get_gtoken()` 함수로 access token 획득
  - curl만 사용하며 Python 스크립트 불필요
  - 사용 예시: `TOKEN=$(get_gtoken) && curl -H "Authorization: Bearer $TOKEN" https://www.googleapis.com/gmail/v1/users/me/profile`

  ```python
  import os
  import netrc

  def get_api_token(service, token_key=None, use_netrc=False):
      """
      Load API token from environment variable or .netrc file.

      Args:
          service: Service name (e.g., 'sentry', 'jira')
          token_key: Environment variable key (e.g., 'SENTRY_API_TOKEN')
          use_netrc: If True and token not found in env, try .netrc (for non-Bearer tokens)
      """
      # 1. 환경 변수에서 먼저 확인
      if token_key:
          token = os.environ.get(token_key)
          if token:
              return token

      # 2. Bearer 토큰이 아닌 경우 .netrc 파일 사용 (예: Jira)
      if use_netrc:
          try:
              secrets = netrc.netrc()
              # service에 따라 호스트명 결정
              host_map = {
                  'jira': 'mangoboost.atlassian.net',
                  'sentry': 'testexec.mangoboost.io',
              }
              host = host_map.get(service)
              if host:
                  login, account, password = secrets.authenticators(host)
                  return password
          except (FileNotFoundError, netrc.NetrcParseError, OSError, KeyError):
              pass

      raise ValueError(f"API token for {service} not found")
  ```

## PR 리뷰 환경 (다른 사람의 PR 리뷰)

**주의**: 이 섹션은 **다른 사람이 작성한 PR을 리뷰**하는 경우를 다룹니다. codebase와는 다른 개념이며, 리뷰어로서 다른 사람의 코드를 검토하고 피드백을 제공하는 워크플로우입니다.

**내 PR에 대한 리뷰 코멘트 처리**: 내가 작성한 PR에 대한 리뷰어의 피드백을 처리하는 경우는 `.claude/skills/pr-feedback-workflow/SKILL.md`를 참고하세요.

### PR 브랜치로 이동

**주의**: PR 리뷰 컨텍스트에서는 `origin`에 작업 내용이 있는 것이 아니라, `upstream`에 올라온 PR 버전을 fetch해야 합니다.

**방법 1: `switch` 예약어 사용 (내 작업 브랜치용)**
- `switch <PR_number>` 또는 `switch <branch_name>` 예약어 사용
- **한계**: `switch` 명령어는 `origin` 내의 작업 내용을 우선적으로 체크하므로, PR 리뷰 시에는 동작하지 않을 수 있음
- 내 작업 브랜치로 이동할 때만 사용
- 자세한 내용은 "예약어" 섹션의 `switch` 커맨드 참고

**방법 2: PR 리뷰 전용 - 수동으로 PR 브랜치 가져오기**
- PR의 head 브랜치를 `upstream`에서 직접 fetch: `git fetch upstream pull/<PR_ID>/head:pr-<PR_ID>` 후 `git checkout pr-<PR_ID>`
- 또는 PR의 head 브랜치가 fork 저장소에 있는 경우, 해당 원격 저장소에서 fetch 필요
- **권장**: PR 리뷰 시에는 이 방법을 사용

### 리뷰 작업 규칙

- 리뷰할 때 최신 commit의 변경사항만 보면 됨 (HEAD~1과 비교)
- 터미널에 diff를 찍기보다는 `.tmp` 폴더 아래에 임시파일로 떨구고 파일을 직접 읽는 방식 사용
  - 예시: `git diff HEAD~1 > ../tmp/git_diff.txt` 후 read_file 도구 사용
- 작업이 끝난 이후에는 생성한 임시파일 삭제

## 커밋 메시지 작성 규칙

**참고**: 상세한 커밋 메시지 작성 규칙은 `.claude/skills/commit-rules/SKILL.md`를 참고하세요.

### 핵심 규칙
- 커밋 메시지는 영어로 작성
- 형식: `[컴포넌트명] <Jira 이슈>: 제목` 또는 `[컴포넌트명] hotfix: 제목`
- 본문: "This patch"로 시작하는 요약 → Changes → Related to (선택)
- **커밋 메시지에는 `.gitignore`에 포함된 파일을 제외한 변경된 파일만 반영한다. `.gitignore`에 포함된 파일(예: `.cursor/`, `.cursorrules*`, `.env.local`, `airflow.cfg` 등)에 대한 변경 이력은 커밋 메시지에 적지 않는다.**
- Jira 이슈 정보 확인: 커밋 메시지에 Jira 이슈 번호가 포함된 경우, `.claude/skills/jira-api-access/SKILL.md` 또는 `.claude/skills/jira-issue-management/SKILL.md`를 참고하여 이슈 정보를 확인하고 더 정확한 커밋 메시지를 작성할 수 있습니다.

## Jira 이슈 생성 규칙

### 이슈 제목 (Summary)
- **Jira 이슈 제목(summary)은 반드시 영어로 작성합니다**
- 한글로 작성된 이슈 제목은 영어로 수정해야 합니다
- 이슈 설명(description)은 한글 또는 영어 모두 사용 가능합니다

### 이슈 타입
- 기본 이슈 타입은 **Story** (스토리)를 사용합니다
- 이슈 타입 ID: `10006` (Story)
- Task (작업, ID: `10007`)는 특별한 경우에만 사용
- Bug 이슈는 **RBug** (ID: `10009`)를 사용합니다

### 상위 에픽 지정
- Jira 이슈 생성 시 적절한 상위 에픽(epic)을 지정해야 합니다
- 에픽은 작업의 큰 범주를 나타내며, 프로젝트의 구조화된 관리를 위해 필요합니다
- 에픽 키는 `parent` 필드에 지정합니다
  ```json
  {
    "fields": {
      "parent": {
        "key": "MATS-XXXX"
      }
    }
  }
  ```
- 에픽을 확인하려면 Jira에서 관련 에픽을 검색하거나, 기존 이슈의 에픽 정보를 참고합니다

### Jira Troubleshooting

#### 에픽에 이슈 연결하기
- **에픽 링크 필드**: `customfield_10014`를 사용하여 에픽에 이슈를 연결합니다
- **에픽 이름 필드**: `customfield_10011`은 직접 설정할 수 없습니다 (읽기 전용)
- **에픽 연결 방법**:
  ```bash
  curl -X PUT --netrc "https://mangoboost.atlassian.net/rest/api/3/issue/MATS-XXXX" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{"fields": {"customfield_10014": "MATS-35"}}'
  ```
- **확인 방법**: 이슈 조회 시 `customfield_10014` 필드에 에픽 키가 설정되어 있는지 확인
- **참고**: 에픽 링크 필드 ID는 프로젝트마다 다를 수 있으므로, 기존 이슈의 `customfield_10014` 값을 확인하여 사용

### 출력 형식
- 커밋 메시지는 코드박스로 감싸서 제공 (git 명령어 없이)

## 코드 품질 표준

**참고**: 상세한 코딩 스타일 및 린팅 설정은 `.claude/skills/coding-style/SKILL.md`를 참고하세요.

### 일반 규칙
- 저장 시 자동 포맷팅과 import 정리
- 작업 완료 후 린팅 체크 수행

### Django 마이그레이션 규칙
- **마이그레이션 파일은 절대 직접 생성하거나 수정하지 않음**
- 마이그레이션은 반드시 `makemigrations` 명령어를 사용하여 생성
- 생성된 마이그레이션 파일은 사용자의 명시적인 요청 없이는 수정하지 않음
- 마이그레이션 파일 생성은 사용자가 직접 `makemigrations` 명령어를 실행하여 수행

## Python 프로젝트 로컬 가상화 환경

### 모노레포 구조 (mats-monorepo)
- Python 가상환경은 **각 앱별로 독립적으로 구축** (`apps/<app>/.venv`)
  - 각 앱이 서로 다른 의존성을 가지므로 모듈별로 분리하여 구축
  - 예: `apps/airflow/.venv`, `apps/django/.venv`
- 각 앱의 가상환경 활성화: `cd apps/<app> && source .venv/bin/activate`
- 가상환경 활성화 확인: `which python` 명령으로 가상환경 경로 확인
- 가상환경이 비활성화된 상태에서 Python 명령 실행 시 자동으로 활성화 안내

### 단일 프로젝트 구조 (기존 프로젝트)
- Python 가상환경은 `.venv` 디렉토리에 위치 (프로젝트 루트)
- Python 명령 실행 시 가상환경 활성화 필요: `source .venv/bin/activate`
- 가상환경 활성화 확인: `which python` 명령으로 가상환경 경로 확인
- 가상환경이 비활성화된 상태에서 Python 명령 실행 시 자동으로 활성화 안내

## 문서화 규칙

**참고**: 상세한 언어 사용 규칙은 `.claude/skills/language-rules/SKILL.md`를 참고하세요.

### 핵심 규칙
- 모든 코드, 주석, docstring은 영어로 작성
- 단순 변경사항에 대한 주석은 작성하지 않음
- 구현 변경을 설명하는 주석 추가하지 않기 (예: "inherited from X", "replaced by Y")
- **플랜 단계/섹션 참조 금지**: 코드·주석·docstring에서는 플랜의 Step, Phase, § 등 단계/섹션 표기를 참조하지 않는다. 동작·의도는 해당 표기 없이 설명한다.

## 일반 베스트 프랙티스

- 민감한 정보 코드에 직접 포함 금지
- 하드코딩된 설정값 사용 자제
- 가급적 테스트 코드 작성
- 코드에는 항상 영어만 사용할 것
- 구조화된 설정 파일 선호

## 테스트 분석 관련 정보

테스트는 PipelineRun 객체와 1:1 대응하며, 다른 객체와의 연관성은 codebase내 모델간 관계를 참고한다.

### API 엔드포인트

테스트 분석 시 유용한 API 엔드포인트 (서비스 URL: https://testexec.mangoboost.io):
- `/api/pipelineruns/<test_id>` - 테스트 실행 정보 조회
  - `raw_query`: 사용자가 입력한 원본 데이터
  - `context`: 검증된 데이터 (package_info_soc, package_info 등 포함)
  - `enriched_raw_query`: enriched된 데이터 (queued 상태일 때만)
  - `pipeline`: Pipeline 정보 (id, name 등)
  - 테스트 로그 링크: https://test.mangoboost.io/testrun/<test_id>
- `/api/pipelines/<pipeline_id>` - Pipeline 상세 정보
  - `pipelinestage_set`: Pipeline의 모든 stages (일부 경우 포함되지 않을 수 있음)
- `/api/pipelinestages?pipeline=<pipeline_id>` - Pipeline의 모든 stages 조회
  - 각 stage의 `template` 필드: StageTemplate ID 또는 None
  - `conf_template`: 로컬 템플릿 (template이 없을 때 사용)
- `/api/stagetemplates/<template_id>` - StageTemplate의 template_body 확인
  - Jinja 템플릿 로직 확인 필요

**분석 시 확인 사항**:
1. `raw_query` vs `context` 비교로 입력값과 검증된 값을 확인
2. Pipeline stages와 각 stage의 template 소스 확인 (StageTemplate 또는 conf_template)
3. StageTemplate의 template_body에서 Jinja 변수 사용 패턴 확인

### 테스트 워크스페이스 경로

테스트 ID 기반 워크스페이스 경로:
- 테스트 디렉토리: `/mnt/mats/storage/system_run_dev_<test_id>/`
- 워크스페이스 경로: `/mnt/mats/storage/system_run_dev_<test_id>/workspace/`
- launch가 있는 경우: `/mnt/mats/storage/system_run_dev_<test_id>/workspace/launch_0/`
- 테스트 ID 찾기: `ls /mnt/mats/storage | grep "system_run_dev_<test_id>"`
- 파일 찾기: `find /mnt/mats/storage/system_run_dev_<test_id> -name "<filename>" 2>/dev/null`
- 테스트 로그 링크: https://test.mangoboost.io/testrun/<test_id>
  - 채팅에서 테스트 ID를 노출하는 경우 hyperlink 걸어주면 좋을듯
- 분석 예시:
  ```bash
  # run.log 분석
  grep -E "(fio|nvme|spdk|nvmf)" /mnt/mats/storage/system_run_dev_<test_id>/workspace/run.log

  # launch가 있는 경우
  grep -E "(fio|nvme|spdk|nvmf)" /mnt/mats/storage/system_run_dev_<test_id>/workspace/launch_0/run.log

  # 워크스페이스 내 모든 파일 확인
  ls -la /mnt/mats/storage/system_run_dev_<test_id>/workspace/
  ```

**중요 제약사항**:
- **절대 `/mnt/mats/storage/` 경로를 iterate하지 말 것**: `find /mnt/mats/storage -maxdepth ...` 같은 명령어는 사용 금지
  - 이유: 파일이 너무 많고 시간이 오래 걸리기 때문
- 테스트 분석 시에는 사용자가 제시한 특정 테스트 ID만 확인
- 여러 테스트를 찾아야 하는 경우, 사용자에게 테스트 ID 목록을 요청하거나 API를 통해 조회

**참고**:
- Initialize 단계까지의 디버깅 (템플릿 렌더링, 변수 설정 등): API를 우선 활용
- Workload 수행 단계까지 진행된 로그 분석 이슈: workspace 로그 파일 확인

## Django 서비스 환경 로깅 시스템 경로

서비스 환경의 로그 경로 및 구조:
- 서비스 로그 루트: `/mnt/mats/vm_home/mango-test-mgmt/web/logs/`
- 로깅 설정 파일: `web/mango_test_mgmt/settings/logging.py`
- BASE_DIR: `web/` 디렉토리 (logging.py에서 자동 계산)

로그 구조:
- Django core 로그: `/mnt/mats/vm_home/mango-test-mgmt/web/logs/django/`
  - `django_info.log`, `django_warning.log`, `django_error.log`
  - `request_info.log`, `request_warning.log`, `request_error.log`
- 앱별 로그: `/mnt/mats/vm_home/mango-test-mgmt/web/logs/application/<app_name>/`
  - 각 앱마다 `{app_name}_info.log`, `{app_name}_warning.log`, `{app_name}_error.log`

사용 예시:
- 특정 앱의 ERROR 로그 확인: `/mnt/mats/vm_home/mango-test-mgmt/web/logs/application/<app_name>/<app_name>_error.log`
- Django request ERROR 로그: `/mnt/mats/vm_home/mango-test-mgmt/web/logs/django/request_error.log`
- 로그 구조 및 설정 상세: `web/mango_test_mgmt/settings/logging.py` 파일 참고

## Sentry 에러 추적 시스템

Sentry는 self-hosted로 운영되며 에러 추적 및 모니터링에 사용됩니다.

### Sentry 엔드포인트 정보
- **도메인**: `https://testexec.mangoboost.io:9000`
- **Organization**: `sentry`
- **이슈 링크 형식**: `https://testexec.mangoboost.io:9000/organizations/sentry/issues/<issue_id>/`
  - 예시: `https://testexec.mangoboost.io:9000/organizations/sentry/issues/17/`

### 커밋 메시지에 Sentry 이슈 링크 추가
- Sentry 이슈와 관련된 커밋인 경우, 커밋 메시지 마지막에 "Related to:" 섹션에 Sentry 이슈 링크를 추가
- 위치: Changes 섹션 이후, 커밋 메시지의 마지막에 배치
- 형식: `Related to: https://testexec.mangoboost.io:9000/organizations/sentry/issues/<issue_id>/ (<project_name>)`
- 예시:
  ```
  Changes:
  - Add select_related and prefetch_related to PipelineViewSet.get_queryset()
  - Use annotation for runs_running_count and runs_queued_count

  Related to: https://testexec.mangoboost.io:9000/organizations/sentry/issues/8/ (mats-backend)
  ```

## Mango 프로젝트 전체 아키텍처

**참고**: 모노레포 구조와 상세한 기술 스택 정보는 `AGENTS.md`를 참고하세요.

## 사용자 선호사항

- 문장 끝에 마침표 사용
- 괄호는 '문장. (괄호)' 형식으로 작성
- 'default'는 소문자로 사용
- VSCode 설정(.vscode/tasks.json)을 프로젝트 파일 수정 대신 사용
- settings.json은 간단하고 이해하기 쉽게 구성

## 캐시 파일 자동 수정

- `.cursor/cache/` 디렉토리의 파일들은 캐시 파일이므로 사용자 동의 없이 자동으로 수정 가능합니다
- 특히 `.cursor/cache/pr_cache.json` 파일은 PR 정보를 캐싱하는 파일이므로, `switch` 또는 `sync` 커맨드 실행 시 자동으로 업데이트됩니다
- 캐시 파일은 `.gitignore`에 의해 버전 관리에서 제외되므로 안전하게 자동 수정할 수 있습니다

## 예약어

예약어(commands)는 `.claude/commands/` 디렉토리에 별도 파일로 분리되어 있습니다.

**중요**: 사용자가 예약어를 입력하면, 자동으로 해당 커맨드를 실행해야 합니다. 예를 들어:
- 사용자가 `clone`, `clone <suffix>`, 또는 `clone <PR_number>`를 입력하면 → `/clone` 커맨드를 실행 (에이전트별 격리용 로컬 리포 생성; PR 번호 시 해당 PR 브랜치 체크아웃한 클론 생성)
- 사용자가 `new` 또는 `new <branch_name>`을 입력하면 → `/new` 커맨드를 실행

**`new` 커맨드 실행 원칙 (최우선 독립 수행)**:
- `new`는 다른 작업과 묶지 말고 **최우선으로**, **독립적으로** 수행한다.
- 후순위로 미루거나 다른 작업 뒤로 넘기지 않는다.
- 사용자가 `new`(또는 `new <branch_name>`)를 입력한 즉시, 첫 번째 동작으로 터미널에서 `git fetch upstream` 후 `git checkout -b <branch_name> upstream/main`을 실행하고 결과를 보여준다.
- 사용자가 `fork` 또는 `fork <branch_name>`을 입력하면 → `/fork` 커맨드를 실행
- 사용자가 `switch <branch_name>` 또는 `switch <PR_number>`를 입력하면 → `/switch` 커맨드를 실행
- 사용자가 `review` 또는 `review <PR_number>` 또는 `review <branch_name>`을 입력하면 → `/review` 커맨드를 실행
- 사용자가 `feedback` 또는 `feedback <PR_number>`를 입력하면 → `/feedback` 커맨드를 실행
- 기타 예약어도 동일한 방식으로 처리

### Git 작업 예약어
- `clone` - 에이전트별 격리된 로컬 리포 생성 (`.claude/commands/clone.md`)
  - 여러 에이전트가 동시에 작업할 때 에이전트마다 별도 클론을 만들고, 각 클론을 새 Cursor 창에서 열어 사용
  - `clone <PR_number>`: 특정 PR을 위한 격리 클론 생성 (접미사 `pr-<number>`, 해당 PR 브랜치 체크아웃)
  - 개인 개발 워크플로우: `~/.claude/docs/personal-dev-workflow.md`
- `new` - 새로운 작업 시작 (`.claude/commands/new.md`). **최우선 독립 수행**: 다른 작업과 묶지 말고 즉시 터미널에서 실행한다.
- `fork` - 브랜치에서 분기 (`.claude/commands/fork.md`)
  - 파라미터가 없으면 현재 브랜치에서 새 브랜치 생성
  - PR 번호 또는 브랜치명을 파라미터로 주면 해당 브랜치에서 새 브랜치 생성
  - PR 번호를 사용할 경우 `switch` 커맨드와 동일하게 캐시를 활용합니다
- `switch` - 브랜치로 이동 (`.claude/commands/switch.md`)
  - PR 번호를 사용할 경우, `.cursor/cache/pr_cache.json`에 캐시된 브랜치 정보를 우선 사용하여 GitHub API 호출을 생략합니다
  - 캐시에 정보가 없을 때만 GitHub API를 호출하고 결과를 캐시에 저장합니다
- `sync` - 현재 브랜치를 특정 브랜치에 rebase (`.claude/commands/sync.md`)
  - 파라미터가 없으면 `upstream/main`에 rebase
  - 브랜치명 또는 PR 번호를 파라미터로 주면 해당 브랜치에 rebase (로컬 브랜치 우선, 없으면 원격 브랜치)
  - PR 번호를 사용할 경우 `switch` 커맨드와 동일하게 캐시를 활용합니다
- `review` - PR 코드 리뷰 (`.claude/commands/review.md`)
  - `review <PR_number>`: PR 번호로 리뷰 (upstream에서 fetch)
  - `review <branch_name>`: 브랜치명으로 리뷰 (upstream에서 fetch)
  - `review`: 현재 HEAD 리뷰 (main 대비 변경사항)
  - **중요**: PR 리뷰 시 origin이 아닌 upstream에서 fetch (`git fetch upstream pull/<PR>/head:pr-<PR>`)
- `feedback` - PR 리뷰 코멘트 작성 (`.claude/commands/feedback.md`)
  - `review` 결과를 바탕으로 사용자가 필터링한 피드백을 PR에 게시
  - AI 리뷰 + 사용자 필터링 정보가 헤더에 명시됨
  - Minor 이하는 `<details>` 태그로 접어서 부담 없는 톤으로 작성

### 커밋 전 마무리 작업 예약어
- `finish` - 커밋 전 마무리 작업 수행 (`.claude/commands/finish.md`)

각 예약어의 상세 내용은 해당 파일을 참고하세요.
