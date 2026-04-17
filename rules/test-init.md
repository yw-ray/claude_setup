---
description: "Test Init project rules - shell script conventions, argument parsing patterns, and test initialization guidelines"
globs: apps/test-init/**
alwaysApply: false
---

# Test Init 프로젝트 - 프로젝트별 규칙

## 프로젝트 개요
- **목적**: 테스트 초기화 (하드웨어 설정, 패키지 설치, 비트스트림 프로그래밍, 디바이스 관리)
- **디렉토리**: `apps/test-init/`

## 코드 품질

### Shell 스크립트 스타일
- **들여쓰기**: 2칸 공백을 사용합니다.

### Shell Script Argument Parsing
- **기본 원칙**: `install_package_soc.sh` 스타일의 compact한 argument 파싱 사용
- **파싱 모드 분리**: keyword-based와 positional-based 파싱을 혼합하지 않음
- **모드 결정**: `$1`이 `--`로 시작하는지 확인해서 파싱 모드 결정
- **표준 포맷**:
  ```bash
  # 변수 초기화
  VAR1=""
  VAR2=""

  # 파싱 모드 확인
  if [[ $# -gt 0 && "$1" =~ ^-- ]]; then
    # keyword-based 파싱
    while [[ "$#" -gt 0 ]]; do
      case $1 in
        '') ;;
        --param1) VAR1="$2"; shift ;;
        --param2) VAR2="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
      esac
      shift
    done
  else
    # positional-based 파싱 (하위 호환성)
    if [[ $# -eq 1 ]]; then
      VAR1="$1"
    fi
  fi
  ```
