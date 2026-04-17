# `feedback` - PR 리뷰 코멘트 작성

## 용도
- `review` 커맨드로 리뷰한 내용을 바탕으로 PR에 코멘트 작성
- 사용자가 필터링/수정한 피드백을 GitHub PR에 게시

## 사용법
- `feedback` - 현재 체크아웃된 PR에 리뷰 코멘트 작성
- `feedback <PR_number>` - 특정 PR에 리뷰 코멘트 작성

## 전제 조건 (필수)

### Review Context 확인
**이 커맨드는 동일 대화 세션에서 `review` 커맨드가 먼저 실행된 경우에만 동작합니다.**

다음 조건을 모두 만족해야 함:
1. 동일 대화 세션에서 `review` 커맨드가 실행되었음
2. 리뷰 결과(개선 제안 목록)가 존재함
3. 사용자가 리뷰 결과를 확인하고 피드백 항목을 선택/수정했음

**Review context가 없는 경우 즉시 중단:**
```
❌ Review context가 없습니다.
먼저 `review <PR_number>` 커맨드로 리뷰를 수행해주세요.
```

## 동작

### 0. Review Context 확인 (필수)
- 동일 대화 세션에서 `review` 커맨드 실행 여부 확인
- Review context가 없으면 **즉시 중단**하고 에러 메시지 출력
- Review context가 있으면 다음 단계 진행

### 1. 피드백 항목 선택
- `review` 결과에서 도출된 개선 제안 목록을 사용자에게 제시
- 사용자가 포함할 항목 선택 (다중 선택 가능)
- 사용자가 추가 의견이나 수정사항 입력 가능

### 2. 코멘트 작성 및 게시
```bash
gh api repos/MangoBoost/mats-monorepo/pulls/<PR_number>/reviews \
  --hostname github.mangoboost.io \
  -X POST \
  -f event="COMMENT" \
  -f body="<formatted_comment>"
```

## 코멘트 형식

### 헤더 (필수)
```markdown
> 이 리뷰는 AI(Cursor)가 초안을 작성하고, 리뷰어가 검토/필터링하여 작성되었습니다.
```

### 본문 구조
```markdown
> 이 리뷰는 AI(Cursor)가 초안을 작성하고, 리뷰어가 검토/필터링하여 작성되었습니다.

## 코드 리뷰

<전체적인 평가 - 긍정적인 톤으로>

### 개선 제안

<Critical/Major 항목은 명확하게>

---

<details>
<summary>💡 참고사항 (Minor/Nit)</summary>

<Minor 이하 항목은 여기에 - 부담 없는 톤으로>

</details>
```

## Severity별 톤 가이드

### Critical / Major
- 명확하고 직접적으로 작성
- 수정이 필요한 이유 설명
- 예시:
  ```
  **[Major] 보안 이슈**
  사용자 입력값이 검증 없이 쿼리에 사용됩니다. SQL Injection 위험이 있으므로 parameterized query 사용을 권장합니다.
  ```

### Minor / Nit / Question
- **부담 없는 톤**으로 작성
- "~하면 좋을 것 같아요", "참고로", "사소하지만" 등 사용
- `<details>` 태그로 접어서 표시
- 예시:
  ```
  - 테스트 코드가 있으면 좋을 것 같아요 (시간 되실 때 고려해주세요)
  - 참고로, `exc_info=True` 사용하면 traceback 로깅이 더 깔끔해져요
  - 사소하지만, 변수명을 좀 더 명확하게 바꾸면 가독성이 올라갈 것 같아요
  ```

## 예시 출력

```markdown
> 이 리뷰는 AI(Cursor)가 초안을 작성하고, 리뷰어가 검토/필터링하여 작성되었습니다.

## 코드 리뷰

전체적으로 잘 구조화된 변경입니다. 코드 재사용성이 향상되었고, MachineState 정보 추가는 유용한 기능이네요.

---

<details>
<summary>💡 참고사항</summary>

- 테스트 코드가 있으면 좋을 것 같아요. `MachineStateSerializer`, `retrieve()`, `update_from_maas_data()` 관련 테스트가 있으면 향후 리팩토링 시 안심이 될 것 같습니다.
- 참고로, 예외 처리에서 `exc_info=True`를 사용하면 traceback이 로깅 시스템에서 더 잘 처리돼요:
  ```python
  log.error(f"Failed to update...", exc_info=True)
  ```

</details>
```

## 참고
- GitHub CLI(`gh`)가 설치되어 있고 인증이 완료되어 있어야 함
- `--hostname github.mangoboost.io` 옵션으로 GitHub Enterprise 환경 지원
- 코멘트 작성 후 PR URL 반환
