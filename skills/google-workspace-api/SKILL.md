# Google Workspace API 사용법 (개인 환경)

개인 환경에서 Google Workspace API를 사용하기 위한 개인 설정 정보입니다.

**일반적인 사용법은 codebase의 [Google Workspace API Access skill](../mats-monorepo/.claude/skills/google-workspace-api-access/SKILL.md)을 참고하세요.**

## 개인 환경 설정

### 프로젝트 정보
- **Quota Project**: `mangoboost-automation`
- **Scope**: `cloud-platform`, `drive.readonly`, `spreadsheets.readonly`
- **차단된 scope**: `gmail.readonly`, `calendar.readonly`, `documents.readonly` (회사 정책)

### 초기 설정 (한 번만)

```bash
# 1. ADC 인증 (scope 포함)
gcloud auth application-default login --scopes=https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive.readonly,https://www.googleapis.com/auth/spreadsheets.readonly

# 2. Quota Project 설정
gcloud auth application-default set-quota-project mangoboost-automation

# 3. gcloud CLI 인증 (API 활성화용)
gcloud auth login
gcloud config set project mangoboost-automation
gcloud services enable sheets.googleapis.com
```

### API 호출 시 주의사항

모든 API 호출 시 `X-Goog-User-Project: mangoboost-automation` 헤더를 포함해야 합니다.

```bash
TOKEN=$(gcloud auth application-default print-access-token)

# 예시: Sheets API 호출
curl -H "Authorization: Bearer $TOKEN" \
     -H "X-Goog-User-Project: mangoboost-automation" \
     "https://sheets.googleapis.com/v4/spreadsheets/{SPREADSHEET_ID}/values/{RANGE}"
```

## 테스트 완료된 스프레드시트

- **ID**: `1dmwbvQZlYr8NsalZxZfLpE7gfj3EXsETDDhMsng5GT0`
  - **제목**: "IT Asset Tracking"
  - **시트**: Server, Device List, Machine List, Card List, Cable List, Service, User List, Subscription 등

- **ID**: `1EqfBghNr2PoVmm76GMNSGcbkBzTK0ZnCgaroGgBslHM`
  - **제목**: "[MB-Shell & BaseNIC] Bitfile Log"
  - **시트**: Bitfile log, Bit Compare Util., BaseNIC Perf Test, (DONT USE) Backup Bit Log
