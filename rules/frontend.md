---
description: "React frontend project rules - component patterns, state management with Zustand, Material-UI styling, and React best practices"
globs: apps/frontend/**
alwaysApply: false
---

# React Frontend 프로젝트 - 프로젝트별 규칙

## 프로젝트 개요
- **플랫폼**: React 18.x
- **목적**: 테스트 관리 시스템 프론트엔드
- **주요 기술**: React, Material-UI, Zustand, Formik

## 코딩 스타일 및 컨벤션

### JavaScript/JSX 코딩 스타일
- ESLint 규칙 준수
- 인덴테이션: 4 spaces

### React 컴포넌트 작성 규칙
- 함수형 컴포넌트 사용
- hooks를 활용한 상태 관리
- immer를 사용한 불변 상태 업데이트 선호
- Material-UI 컴포넌트 활용

### 파일 구조
- **src/components/**: 재사용 가능한 컴포넌트
- **src/scenes/**: 페이지별 컴포넌트
- **src/stores/**: Zustand 상태 관리
- **src/utils/**: 유틸리티 함수

## 개발 가이드라인

### 상태 관리
- Zustand를 사용한 전역 상태 관리
- immer를 활용한 불변 상태 업데이트
- 로컬 상태는 useState, useEffect 활용

### 컴포넌트 설계
- 단일 책임 원칙 준수
- props를 통한 데이터 전달
- 재사용 가능한 컴포넌트 설계

### 스타일링
- Material-UI의 sx prop 활용
- theme.js를 통한 일관된 디자인 시스템
- 반응형 디자인 고려

## 추천 패턴

### 새 컴포넌트 생성 시
```jsx
import { useState, useEffect } from "react";
import { Box, Typography } from "@mui/material";

export default function ComponentName({ prop1, prop2 }) {
    const [state, setState] = useState(initialValue);

    useEffect(() => {
        // side effects
    }, [dependencies]);

    return (
        <Box>
            <Typography>Content</Typography>
        </Box>
    );
}
```

### Zustand 스토어 생성 시
```jsx
import { create } from "zustand";
import { produce } from "immer";

const useStore = create((set) => ({
    state: initialState,
    actions: {
        updateState: (newValue) =>
            set(
                produce((state) => {
                    state.value = newValue;
                }),
            ),
    },
}));
```

## 커밋 메시지 특화 규칙

### 말머리 형식
- 모노레포 구조에 맞게 컴포넌트명 사용 (글로벌 룰 참고: `.claude/skills/commit-rules/SKILL.md`)
- 특정 페이지/기능에만 해당하는 변경사항: `[Frontend/<page_or_feature>]` 형식 사용 (예: `[Frontend/Launch]`, `[Frontend/TestRun]`, `[Frontend/Scenario]`)
- 여러 페이지에 영향을 미치는 변경사항: `[Frontend]` 사용
- 페이지/기능 영역은 대문자로 시작
- 컴포넌트 이름보다는 어떤 페이지나 기능에서의 변경인지 명시

### 제목 규칙
- 말머리를 포함한 제목의 총 길이가 60자를 넘지 않아야 함 (글로벌 룰과 일치)
- 커밋 메시지만 코드박스로 감싸서 노출
- push 명령어는 별도로 제공하지 않음

## 커밋 전 마무리 작업

커밋 메시지 작성 직전에 GitHub Actions 워크플로우들이 정상적으로 동작하는지 로컬에서 확인:

1. **ESLint 체크** (`.github/workflows/pr-checker-code-quality.yml`):
   ```bash
   npx eslint src --format=compact
   ```
   - 문제가 발견되면 `npx eslint src --fix`로 자동 수정 시도

2. **Prettier 포맷 체크** (`.github/workflows/pr-checker-code-quality.yml`):
   ```bash
   npx prettier src --list-different
   ```
   - 문제가 발견되면 `npx prettier src --write`로 자동 수정

3. **Unit Test 실행** (`.github/workflows/pr-checker-code-quality.yml`):
   ```bash
   npm test
   ```

4. **Build 테스트는 생략** (`.github/workflows/pr-checker-code-quality.yml`)
   - 빌드 테스트는 로컬에서 수행하지 않음 (시간이 오래 걸리고 불필요)

**참고**:
- 모든 체크가 통과된 후 바로 커밋 메시지 작성 진행합니다.
