# Phase 5 — k6 Performance Tests

## Mục tiêu

Viết 4 k6 test scripts kiểm tra hiệu năng các endpoints chính.

## Scripts (k6/scripts/)

### Thresholds chung (BẮTBUỘC tất cả scripts)

```javascript
export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500'],  // p95 < 500ms
    http_req_failed:   ['rate<0.01'],  // error rate < 1%
  },
  stages: [
    { duration: '10s', target: N },   // ramp-up
    { duration: Xs,    target: N },   // sustain
    { duration: '10s', target: 0 },   // ramp-down
  ],
}
```

### login.js — 100 VUs · 30s

```javascript
// k6/scripts/login.js
import http from 'k6/http'
import { check, sleep } from 'k6'

export const options = {
  stages: [
    { duration: '10s', target: 100 },
    { duration: '30s', target: 100 },
    { duration: '10s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed:   ['rate<0.01'],
  },
}

export default function () {
  const res = http.post('http://api.buffaloedu.app/auth/login', JSON.stringify({
    email:    'teacher@buffaloedu.app',
    password: 'Test@123456',
  }), { headers: { 'Content-Type': 'application/json' } })

  check(res, {
    'status 200':     r => r.status === 200,
    'has accessToken': r => JSON.parse(r.body).accessToken !== undefined,
  })
  sleep(1)
}
```

### submit_exam.js — 50 VUs · 60s

- `setup()`: login → lấy token
- Flow: StartSubmission → SubmitAnswer × N → FinalizeSubmission
- Check: status 200, score returned

### fetch_result.js — 200 VUs · 30s

- `setup()`: lấy danh sách result IDs
- Flow: GET /results/{id}
- Check: status 200, score field present

### question_bank.js — 100 VUs · 30s

- Flow: GET /questions?subject=math&difficulty=3&page=1&page_size=20
- Check: status 200, items array present

## Chạy local

```bash
k6 run --dry-run k6/scripts/login.js         # syntax check
k6 run k6/scripts/login.js                    # chạy thật
k6 run --out json=results.json k6/scripts/login.js  # export kết quả
```

## Quality Gate

```bash
k6 run --dry-run k6/scripts/login.js        # 0 syntax errors
k6 run --dry-run k6/scripts/submit_exam.js
k6 run --dry-run k6/scripts/fetch_result.js
k6 run --dry-run k6/scripts/question_bank.js
```
