---
description: "로컬에서 현재 작업 branch를 NFS 경로에 partial clone하여 실험 실행하는 워크플로우"
---

# 로컬 실험 실행 워크플로우

## 개요

원격 executor에서 test-runner를 실행하려면 codebase가 NFS 경로에 있어야 합니다. 현재 작업 중인 branch를 실험하기 위해 `/mats/temp/...` 경로에 partial clone하고, 로컬에서 직접 백그라운드로 실행하는 워크플로우입니다.

**중요**: Airflow, Django 등 다른 component는 전혀 사용하지 않습니다. test-runner만으로 실험을 구동합니다.

## 경로 구조

- **임시 실험 경로**: `/mats/temp/{run_id}` (NFS 마운트, 원격 executor에서도 접근 가능)
- **Codebase 경로**: `/mats/temp/{run_id}/mats-monorepo/apps/test-runner`
- **Workspace 경로**: `/mats/temp/{run_id}/workspace/launch-1`
- **Config 경로**: `/mats/temp/{run_id}/workspace/launch-1/config.json`
- **로그 경로**: `/mats/temp/{run_id}/workspace/launch-1/run.log`

## 워크플로우

### 1. 사전 준비

**현재 작업 branch 확인**

```bash
cd /home/sh/cursor/mats-monorepo
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
```

**임시 run_id 생성**

```bash
RUN_ID="storage-test-${BRANCH_NAME}-$(date +%Y%m%d-%H%M%S)"
```

### 2. Workspace 및 Codebase 준비

**Partial clone을 `/mats/temp/...` 경로에 수행**

```bash
TEMP_WORKSPACE="/mats/temp/${RUN_ID}"
mkdir -p "${TEMP_WORKSPACE}/workspace/launch-1"

cd "${TEMP_WORKSPACE}"
git clone --filter=blob:none --depth=1 --sparse \
  "file:///home/sh/cursor/mats-monorepo" mats-monorepo

cd mats-monorepo
git sparse-checkout set apps/test-init apps/test-runner
git checkout "${BRANCH_NAME}"
```

**참고**: 로컬 repository를 clone하려면 `file://` 프로토콜 사용. 또는 remote URL 사용 후 branch 체크아웃.

### 3. Config 파일 준비

**Config 파일 생성**

물리 머신 정보(hostname, IP, BDF 등)가 포함된 config 파일은 codebase에 포함하지 않고, 로컬에서만 관리합니다.

```bash
# 예: Python으로 config 생성
python3 -c "
import json

config = {
    'test_class': 'STORAGE',
    'system_configuration': {
        'initiator': {
            'devices': [
                {
                    'device': {
                        'hostname': 'mats15',
                        'model': 'ConnectX-7',
                        'bdf': '0000:2a:00.0',
                        'type': 'NIC',
                        'switch_ip_addr': '10.15.7.5',
                        'switch_interface': 'ethernet1/1/6:3'
                    },
                    'ip_addr': '172.18.100.53',
                    'mac_addr': '50:00:e6:dd:9c:96',
                    'vlan_id': 1
                }
            ]
        },
        'target': {
            'devices': [
                {
                    'device': {
                        'hostname': 'mats16',
                        'model': 'ConnectX-7',
                        'bdf': '0000:2a:00.0',
                        'type': 'NIC',
                        'switch_ip_addr': '10.15.7.5',
                        'switch_interface': 'ethernet1/1/17:1'
                    },
                    'cpu': '0-15',
                    'ip_addr': '172.18.100.54',
                    'mac_addr': '50:00:e6:e2:d2:8e',
                    'vlan_id': 1,
                    'storage_dev_id': 'abcd:1234',
                    'num_storage': 8
                }
            ]
        }
    },
    'log_configuration': {},
    'test_configuration': {
        'test_features': {
            'hardware_feature': {
                'ATTACH_NVME': None
            },
            'workload_feature': {
                'IO_QUEUE_SIZE': {'value': 128},
                'ADMIN_QUEUE_SIZE': {'value': 32},
                'NUM_IO_QUEUES': {'value': 32}
            }
        }
    },
    'test_case': {
        'fio_randrw_4k_bandwidth_test': {'runtime': 60}
    }
}

with open('${TEMP_WORKSPACE}/workspace/launch-1/config.json', 'w') as f:
    json.dump(config, f, indent=4)
"
```

### 4. 실험 실행 (백그라운드)

**Screen으로 백그라운드 실행**

```bash
cd "${TEMP_WORKSPACE}/workspace/launch-1"
SCREEN_NAME=$(echo "storage-test-${RUN_ID}" | tr '/' '-')

screen -d -m -S "${SCREEN_NAME}" -L -Logfile run.log bash -c "
  export IPMI_USER=\$IPMI_USER
  export IPMI_PASSWORD=\$IPMI_PASSWORD
  export SWITCH_USER=\$SWITCH_USER
  export SWITCH_PASSWORD=\$SWITCH_PASSWORD
  python /mats/temp/${RUN_ID}/mats-monorepo/apps/test-runner/main.py \
    run config.json report.json
"
```

### 5. 실행 모니터링

**로그 확인**

```bash
# Screen 세션 접속
screen -r ${SCREEN_NAME}

# 로그 실시간 확인
tail -f ${TEMP_WORKSPACE}/workspace/launch-1/run.log
```

**결과 확인**

```bash
# 리포트 확인
cat ${TEMP_WORKSPACE}/workspace/launch-1/report.json
```

## 통합 스크립트 예시

```bash
#!/bin/bash
# live_experiment.sh

set -e

# 현재 작업 디렉토리에서 branch 확인
CURRENT_DIR=$(pwd)
BRANCH_NAME=$(git -C "${CURRENT_DIR}" rev-parse --abbrev-ref HEAD)
RUN_ID="storage-test-${BRANCH_NAME}-$(date +%Y%m%d-%H%M%S)"
TEMP_WORKSPACE="/mats/temp/${RUN_ID}"
LAUNCH_ID="launch-1"
SCREEN_NAME=$(echo "storage-test-${RUN_ID}" | tr '/' '-')

echo "=== Live Experiment Setup ==="
echo "Branch: ${BRANCH_NAME}"
echo "Run ID: ${RUN_ID}"
echo "Workspace: ${TEMP_WORKSPACE}"

# 1. Workspace 생성
echo "Creating workspace..."
mkdir -p "${TEMP_WORKSPACE}/workspace/${LAUNCH_ID}"

# 2. Partial clone (로컬 repository 사용)
echo "Cloning repository..."
cd "${TEMP_WORKSPACE}"
git clone --filter=blob:none --depth=1 --sparse \
  "file://${CURRENT_DIR}" mats-monorepo

cd mats-monorepo
git sparse-checkout set apps/test-init apps/test-runner
git checkout "${BRANCH_NAME}"

# 3. Config 파일 생성 (예시 - 실제 물리 머신 정보로 수정 필요)
echo "Creating config file..."
# ... (config 생성 로직)

# 4. 실험 실행 (백그라운드)
echo "Starting experiment in background..."
cd "${TEMP_WORKSPACE}/workspace/${LAUNCH_ID}"

screen -d -m -S "${SCREEN_NAME}" -L -Logfile run.log bash -c "
  export IPMI_USER=\$IPMI_USER
  export IPMI_PASSWORD=\$IPMI_PASSWORD
  export SWITCH_USER=\$SWITCH_USER
  export SWITCH_PASSWORD=\$SWITCH_PASSWORD
  python /mats/temp/${RUN_ID}/mats-monorepo/apps/test-runner/main.py \
    run config.json report.json
"

echo ""
echo "=== Experiment Started ==="
echo "Run ID: ${RUN_ID}"
echo "Screen session: ${SCREEN_NAME}"
echo ""
echo "Monitor with:"
echo "  screen -r ${SCREEN_NAME}"
echo ""
echo "Check logs:"
echo "  tail -f ${TEMP_WORKSPACE}/workspace/${LAUNCH_ID}/run.log"
```

## 주의사항

1. **로컬 Repository Clone**: `file://` 프로토콜 사용 시 절대 경로 필요. 또는 remote URL 사용 후 branch 체크아웃.

2. **NFS 동기화**: `/mats/temp/`가 NFS 마운트인 경우, 파일 생성 후 약간의 대기 시간 필요할 수 있음.

3. **환경 변수**: `IPMI_USER`, `IPMI_PASSWORD`, `SWITCH_USER`, `SWITCH_PASSWORD` 등이 설정되어 있어야 함.

4. **원격 Executor 접근**: 실험 실행 시 원격 executor(mats15, mats16 등)에 SSH 접근 가능해야 함.

5. **Workspace 정리**: 실험 완료 후 `/mats/temp/${RUN_ID}` 정리 (선택사항)

6. **Screen 세션 관리**: 여러 실험을 동시에 실행할 경우 screen 세션 이름 충돌 방지

7. **물리 머신 정보**: hostname, IP, BDF 등이 포함된 config 파일은 codebase에 포함하지 않음
   - 로컬에서만 관리
   - 필요시 로컬에서 생성하여 사용

## 참고 파일

- [apps/test-runner/main.py](../../apps/test-runner/main.py) - test-runner 메인 실행 파일
- [.claude/docs/nfs-path-mapping.md](../../.claude/docs/nfs-path-mapping.md) - NFS 경로 매핑 가이드
