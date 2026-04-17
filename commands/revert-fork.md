# `revert-fork` - 커밋을 새 브랜치로 옮기고 기존 브랜치 revert

## 사용법
- `revert-fork` 또는 `revert-fork <branch_name>`

## 상황
- 이미 작업 내용을 다른 브랜치에서 작업을 완료하고 커밋까지 진행한 상황

## 동작
1. `CURRENT_BRANCH=$(git branch --show-current)` - 현재 작업 중인 브랜치 확인
2. `git checkout -b <new-branch-name>` - 새 브랜치 생성 및 이동
3. `git checkout $CURRENT_BRANCH` - 기존 브랜치로 돌아가기 (변수 사용)
4. `git reset --hard HEAD~1` - 기존 브랜치에서 커밋과 변경사항 모두 취소
5. `git checkout <new-branch-name>` - 새 브랜치로 이동

## 결과
- **기존 브랜치**: 원래 상태로 복원
- **새 브랜치**: 기존 커밋이 반영된 상태

## 브랜치명
- 생략 시 작업 내용 기반으로 추천
