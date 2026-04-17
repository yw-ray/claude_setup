# Weekly Report Command

## 개요

주간 보고서 작성을 위한 자료 수집 및 배치 workflow입니다. 1주간 진행된 작업(커밋, 이슈)을 수집하고, 기존 Confluence 문서 structure에 맞게 배치합니다.

**Repository**: `mats-monorepo`

**사용법**: `/weekly`

**출력**: 기존 문서 structure에 맞게 배치된 항목들 + 배치되지 않은 항목들

## Workflow 개요

1. 자료 수집 (커밋, 이슈 등)
2. Confluence 페이지 찾기 및 기존 문서 structure 읽기
3. 수집한 자료를 기존 structure에 맞게 배치
4. 배치되지 않은 항목들 따로 모아서 제시

## 자료 수집 방법

### 자료 1: 최근 커밋 조회

최근 N일 (기본 7일) 동안의 커밋을 조회합니다.

**필요한 명령어**: `git log`

**예시 코드**:

```python
import subprocess
from datetime import datetime, timedelta

def get_recent_commits(days=7, author=None):
    """최근 N일 커밋 조회"""
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    
    # Git 사용자 이름 자동 조회
    if author is None:
        result = subprocess.run(
            ['git', 'config', 'user.name'],
            capture_output=True, text=True, cwd='/home/sh/cursor/mats-monorepo'
        )
        author = result.stdout.strip()
    
    git_log_cmd = [
        'git', 'log', '--all',
        '--since', start_date.strftime('%Y-%m-%d'),
        '--until', end_date.strftime('%Y-%m-%d'),
        '--author', author,
        '--pretty=format:%h|%s|%ad',
        '--date=short',
        '--no-merges'
    ]
    
    result = subprocess.run(git_log_cmd, capture_output=True, text=True, 
                           cwd='/home/sh/cursor/mats-monorepo')
    commits = []
    for line in result.stdout.strip().split('\n'):
        if line and 'WIP' not in line and 'index on' not in line:
            parts = line.split('|', 2)
            if len(parts) == 3:
                commits.append({
                    'hash': parts[0],
                    'message': parts[1],
                    'date': parts[2]
                })
    return commits
```

**주의사항**:
- `--all` 옵션으로 모든 브랜치 포함 (PR 커밋 포함)
- WIP 커밋 제외
- 커밋 메시지에서 카테고리 추출 가능 (예: `[Django]`, `[Frontend]` 등)

### 자료 2: 최근 해결된 Jira 이슈 조회

최근 N일 해결된 Jira 이슈를 조회합니다.

**필요한 API**: Jira JQL 쿼리 (`GET /rest/api/3/search/jql`)

**예시 코드**:

```python
import netrc
import requests
from requests.auth import HTTPBasicAuth
from urllib.parse import quote
from datetime import datetime, timedelta

def get_resolved_issues(days=7, assignee_name=None):
    """최근 N일 해결된 이슈 조회"""
    secrets = netrc.netrc()
    host = 'mangoboost.atlassian.net'
    login, account, password = secrets.authenticators(host)
    
    server = "https://mangoboost.atlassian.net"
    
    # JQL 쿼리 구성
    jql = f'project = MATS AND resolutiondate >= -{days}d ORDER BY resolutiondate DESC'
    if assignee_name:
        jql += f' AND assignee in ("{assignee_name}")'
    
    url = f"{server}/rest/api/3/search/jql"
    params = {
        'jql': jql,
        'maxResults': 50,
        'fields': 'key,summary,resolutiondate,assignee'
    }
    
    response = requests.get(
        url,
        auth=HTTPBasicAuth(login, password),
        headers={'Accept': 'application/json'},
        params=params,
        timeout=10
    )
    
    if response.status_code == 200:
        data = response.json()
        issues = []
        for issue in data.get('issues', []):
            assignee = issue.get('fields', {}).get('assignee', {})
            assignee_name_field = assignee.get('displayName', '') if assignee else ''
            
            issues.append({
                'key': issue.get('key'),
                'summary': issue.get('fields', {}).get('summary'),
                'resolved': issue.get('fields', {}).get('resolutiondate', ''),
                'assignee': assignee_name_field
            })
        return issues
    return []
```

**주의사항**:
- `resolutiondate` 필드는 해결된 이슈에만 값이 있습니다
- `assignee` 필드는 `null`일 수 있습니다
- 날짜 필드는 ISO 8601 형식으로 반환됩니다

## Confluence 페이지 처리

### Confluence 페이지 찾기

MATS팀 회의록 폴더에서 날짜 형식 페이지를 찾습니다.

**필요한 API**: `GET /wiki/rest/api/content/{folder_id}/child/page`

**예시 코드**:

```python
import netrc
import requests
from requests.auth import HTTPBasicAuth
import re
from datetime import datetime, timedelta

def find_closest_meeting_page(folder_id='267584157'):
    """날짜 형식 페이지 찾기 (오늘 또는 다음 수요일과 가장 가까운 페이지)"""
    secrets = netrc.netrc()
    host = 'mangoboost.atlassian.net'
    login, account, password = secrets.authenticators(host)
    server = "https://mangoboost.atlassian.net"
    
    # 폴더 하위 페이지 조회
    url = f'{server}/wiki/rest/api/content/{folder_id}/child/page'
    params = {
        'expand': 'title,version',
        'limit': 100
    }
    
    response = requests.get(
        url,
        auth=HTTPBasicAuth(login, password),
        headers={'Accept': 'application/json'},
        params=params,
        timeout=10
    )
    
    if response.status_code == 200:
        data = response.json()
        pages = data.get('results', [])
        
        # 날짜 형식이 있는 페이지 찾기 (예: 2026.01.21 MATS)
        date_pattern = r'(\d{4})\.(\d{2})\.(\d{2})'
        matched_pages = []
        
        for page in pages:
            title = page.get('title', '')
            match = re.search(date_pattern, title)
            if match:
                year, month, day = match.groups()
                try:
                    page_date = datetime(int(year), int(month), int(day))
                    matched_pages.append({
                        'id': page.get('id'),
                        'title': title,
                        'date': page_date
                    })
                except ValueError:
                    pass
        
        if not matched_pages:
            return None
        
        # 날짜순 정렬
        matched_pages.sort(key=lambda x: x['date'], reverse=True)
        
        # 오늘 또는 다음 수요일과 가장 가까운 페이지 찾기
        today = datetime.now()
        days_until_wednesday = (2 - today.weekday()) % 7
        if days_until_wednesday == 0:
            days_until_wednesday = 7  # 오늘이 수요일이면 다음 수요일
        next_wednesday = today + timedelta(days=days_until_wednesday)
        
        target_date = next_wednesday if next_wednesday > today else today
        
        closest_page = None
        min_diff = None
        
        for page in matched_pages:
            diff = abs((page['date'] - target_date).days)
            if min_diff is None or diff < min_diff:
                min_diff = diff
                closest_page = page
        
        return closest_page
    
    return None
```

**참고**: MATS팀 회의록 폴더 ID는 `267584157`입니다.

### 문서 structure 읽기

선택된 페이지의 전체 구조를 읽어 기존 카테고리 구조를 파악합니다.

**필요한 API**: `GET /wiki/rest/api/content/{page_id}?expand=body.storage,version`

**예시 코드**:

```python
import netrc
import requests
from requests.auth import HTTPBasicAuth
import re
from html import unescape

def read_page_structure(page_id):
    """페이지의 전체 structure 읽기"""
    secrets = netrc.netrc()
    host = 'mangoboost.atlassian.net'
    login, account, password = secrets.authenticators(host)
    server = "https://mangoboost.atlassian.net"
    
    url = f"{server}/wiki/rest/api/content/{page_id}"
    params = {'expand': 'body.storage,version'}
    
    response = requests.get(
        url,
        auth=HTTPBasicAuth(login, password),
        headers={'Accept': 'application/json'},
        params=params,
        timeout=10
    )
    
    if response.status_code == 200:
        page_data = response.json()
        html_content = page_data['body']['storage']['value']
        
        # 주요 섹션 추출 (h1, h2, h3 태그로 구조 파악)
        sections = {}
        
        # h1 태그로 최상위 섹션 찾기
        h1_pattern = r'<h1[^>]*>(.*?)</h1>'
        h1_matches = re.finditer(h1_pattern, html_content)
        
        for match in h1_matches:
            section_title = match.group(1)
            # HTML 태그 제거
            section_title = re.sub(r'<[^>]+>', '', section_title)
            section_title = unescape(section_title).strip()
            
            # 다음 h1까지의 내용 추출
            start_pos = match.end()
            next_h1 = re.search(r'<h1[^>]*>', html_content[start_pos:])
            end_pos = start_pos + next_h1.start() if next_h1 else len(html_content)
            
            section_content = html_content[start_pos:end_pos]
            
            # h2, h3 구조 파악
            h2_pattern = r'<h2[^>]*>(.*?)</h2>'
            h2_matches = re.finditer(h2_pattern, section_content)
            
            subsections = []
            for h2_match in h2_matches:
                h2_title = re.sub(r'<[^>]+>', '', h2_match.group(1))
                h2_title = unescape(h2_title).strip()
                subsections.append(h2_title)
            
            sections[section_title] = {
                'content': section_content,
                'subsections': subsections
            }
        
        return sections
    
    return {}
```

**주의사항**:
- Storage format은 HTML-like 마크업이므로 정규식으로 파싱
- 주요 섹션: Summary, Projects, Maintenance 등
- Projects 하위: MATS ecosystem, Self-provisioning Console, Product evaluation system 등

## 자료 배치 및 분류

수집한 자료(커밋, 이슈)를 기존 문서 structure의 카테고리에 맞게 배치합니다.

**배치 규칙 예시**:

- `mono-repo`, `mango-workload` 관련 → Projects/MATS ecosystem/Agent Skills
- `deploy`, `docker-compose`, `CI/CD` 관련 → Projects/MATS ecosystem/CI/CD revision
- `parquet`, `pipeline`, `dashboard` 관련 → Projects/MATS ecosystem/Revise result data pipeline
- `Frontend` 버그 수정 → Maintenance/Frontend
- `Django`, `Backend` 버그 수정 → Maintenance/Backend
- `Airflow`, `Workflow` 관련 → Maintenance/Workflow
- `test-runner`, `test-init` 관련 → Maintenance/Workload

**예시 코드**:

```python
def categorize_work(commits, issues):
    """수집한 작업을 카테고리별로 분류"""
    categorized = {
        'Projects': {
            'MATS ecosystem': {
                'Agent Skills': [],
                'CI/CD revision': [],
                'Revise result data pipeline': []
            },
            'Self-provisioning Console': [],
            'Product evaluation system': []
        },
        'Maintenance': {
            'Frontend': [],
            'Backend': [],
            'Workflow': [],
            'Workload': []
        },
        'Uncategorized': []
    }
    
    # 커밋 분류
    for commit in commits:
        msg = commit['message'].lower()
        key = commit.get('key', '')  # MATS-XXXX 형식
        
        if 'mono-repo' in msg or 'mango-workload' in msg or 'workload' in msg:
            categorized['Projects']['MATS ecosystem']['Agent Skills'].append(commit)
        elif 'deploy' in msg or 'docker-compose' in msg or 'ci/cd' in msg:
            categorized['Projects']['MATS ecosystem']['CI/CD revision'].append(commit)
        elif 'parquet' in msg or 'pipeline' in msg or 'dashboard' in msg:
            categorized['Projects']['MATS ecosystem']['Revise result data pipeline'].append(commit)
        elif '[frontend]' in msg or 'frontend' in msg:
            categorized['Maintenance']['Frontend'].append(commit)
        elif '[django]' in msg or '[backend]' in msg or 'django' in msg:
            categorized['Maintenance']['Backend'].append(commit)
        elif '[airflow]' in msg or 'workflow' in msg:
            categorized['Maintenance']['Workflow'].append(commit)
        elif 'test-runner' in msg or 'test-init' in msg:
            categorized['Maintenance']['Workload'].append(commit)
        else:
            categorized['Uncategorized'].append(commit)
    
    # 이슈 분류
    for issue in issues:
        summary = issue['summary'].lower()
        key = issue['key']
        
        # 커밋과 동일한 로직으로 분류
        # ... (위와 동일한 분류 로직)
    
    return categorized
```

**배치되지 않은 항목 처리**:
- `Uncategorized` 리스트에 모아서 별도로 제시
- 사용자가 수동으로 적절한 위치에 배치할 수 있도록

## 전체 Workflow 예시

```python
import netrc
import requests
from requests.auth import HTTPBasicAuth
import subprocess
from datetime import datetime, timedelta
import re
from html import unescape
from urllib.parse import quote

# 인증 설정
secrets = netrc.netrc()
host = 'mangoboost.atlassian.net'
login, account, password = secrets.authenticators(host)
server = "https://mangoboost.atlassian.net"

# 1. 자료 수집
commits = get_recent_commits(days=7)
issues = get_resolved_issues(days=7, assignee_name="Sunghwan Kim")

# 2. Confluence 페이지 찾기
closest_page = find_closest_meeting_page(folder_id='267584157')
if closest_page:
    page_id = closest_page['id']
    print(f"Found page: {closest_page['title']} (ID: {page_id})")
    
    # 3. 문서 structure 읽기
    structure = read_page_structure(page_id)
    
    # 4. 자료 배치 및 분류
    categorized = categorize_work(commits, issues)
    
    # 5. 결과 출력
    print("\n=== 기존 structure에 맞게 배치된 항목들 ===")
    for section, subsections in categorized.items():
        if section == 'Uncategorized':
            continue
        print(f"\n{section}:")
        # ... 카테고리별 출력
    
    print("\n=== 배치되지 않은 항목들 ===")
    for item in categorized['Uncategorized']:
        print(f"- {item}")
```

## 참고 자료

- Confluence API: `mats-monorepo/.claude/skills/confluence-api-access/SKILL.md`
- Jira API: `mats-monorepo/.claude/skills/jira-issue-management/SKILL.md`
- Confluence 폴더 정보:
  - MATS팀 회의록: 폴더 ID `267584157` (날짜 형식 페이지 직접 포함)
  - Solution eval 팀 회의록: 폴더 ID `251003373` (nested 구조, 하위에 분기별 폴더)
