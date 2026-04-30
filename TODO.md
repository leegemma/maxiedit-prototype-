# TODO

기능 추가 없이 **운영·유지보수** 관점에서 챙길 항목들.
완료 시 체크박스 채우고, 의미 있는 변경은 [HISTORY.md](HISTORY.md)에도 한 줄 추가.
모든 작업은 `(source + docs)` 한 커밋 정책을 따른다 ([CLAUDE.md](CLAUDE.md) 참고).

## 우선순위 한눈에

| 우선 | 항목 | 상태 | 주기 | 자동화 |
|---|---|---|---|---|
| 🔴 1 | CDN 의존성 SRI + 버전 핀 점검 | ✅ 완료 | 1회 + 분기 | 부분 |
| 🔴 2 | Capacitor / Gradle / AGP 보안 패치 | ✅ 완료 | 월 | Dependabot |
| 🔴 3 | Play Console 타겟 SDK / 데이터 안전 / 개인정보처리방침 | 🟨 코드 측 완료 | 연 (필수) | X |
| 🟡 4 | 에러 모니터링 도입 (window.onerror → Sentry) | 🟨 1단계 완료 | 1회 | - |
| 🟡 5 | 안드로이드 키스토어 백업 정책 | 🟨 정책 수립 | 1회 + 분기 점검 | X |
| 🟡 6 | GitHub Dependabot 활성화 | ✅ 완료 | 1회 | O |
| 🟢 7 | 캐시버스터 `?v=N` git history 일치 검사 | ✅ 완료 | push마다 | 권장 |
| 🟢 8 | iOS / Android 실기 회귀 테스트 | ⏳ 미완료 | 분기 | X |
| 🟢 9 | OSS 라이선스 고지 페이지 | ✅ 완료 | 1회 + 연 1회 | X |

---

## 🔴 1. CDN 의존성 SRI + 버전 핀 점검

- [x] **상태**: 완료 (2026-04-30) — Sortable.js / html2canvas SRI sha384 적용

**왜**: index.html이 외부 CDN에 100% 의존. SRI 없이 로드 중 → 변조·캐시 오염 방어 0.

**대상**:
- jsDelivr — Sortable.js 1.15.2
- jsDelivr — html2canvas 1.4.1
- Google Fonts (Inter / Noto Sans KR / Nanum Myeongjo) — CSS는 SRI 적용 어려움, 별도 검토
- ffmpeg.wasm 0.12.10 (lazy 로드 — 일단 제외)

**Claude Code 프롬프트**:
```
index.html의 외부 스크립트(Sortable.js, html2canvas) 두 개에 SRI 해시 추가해줘.
- jsdelivr URL의 정확한 버전은 그대로 유지
- integrity="sha384-..." + crossorigin="anonymous" 속성
- 해시는 https://www.srihash.org/ 또는 curl + openssl로 생성
- ffmpeg.wasm은 lazy라 패스
- CLAUDE.md "External dependencies" 섹션에 SRI 정책 한 줄 보강
- HISTORY.md 새 항목 (날짜 + 요약) 가장 위에 추가
```

**완료 기준**:
- 두 script 태그에 `integrity` + `crossorigin="anonymous"` 존재
- 브라우저 콘솔에 SRI 위반 에러 없음
- CLAUDE.md, HISTORY.md 갱신

---

## 🔴 2. Capacitor / Gradle / AGP 보안 패치

- [x] **상태**: 완료 (2026-04-30) — 사용자가 직접 점검·반영 확인.

**왜**: 현재 핀 — `@capacitor/core` `@capacitor/android` `@capacitor/cli` 모두 6.2.1. 6.2.x 라인에 패치가 더 나왔을 수 있음.

**Claude Code 프롬프트**:
```
package.json의 Capacitor 의존성 3종(@capacitor/core, @capacitor/android,
@capacitor/cli)을 6.2.x 최신 패치 버전으로 올려줘. 6.3+은 가지 마.
- npm view @capacitor/core versions로 6.2.x 마지막 확인
- 변경사항(BREAKING) 있는지 changelog 확인 후 보고
- AGP / Gradle Wrapper도 같이 점검 — 단, android/ 폴더는 git-ignored이고
  ~/dev/maxiedit-prototype-에서만 빌드 가능하니 권고만
- HISTORY.md 한 줄 추가
```

**완료 기준**:
- package.json 버전 갱신
- `npm install` + `cap:sync` 정상
- (가능하면) `cap:build:android` 한 번 통과 확인

---

## 🔴 3. Play Console 타겟 SDK / 데이터 안전 / 개인정보처리방침

- [x] **코드 측 완료** (2026-04-30) — `variables.gradle` `compileSdkVersion`/`targetSdkVersion` 34→35 (현 Play Store 의무 만족). `docs/privacy.html` 신규 (수집 0, 디바이스 내 처리 명시, 한·영 병기). CLAUDE.md "Play Store compliance" 섹션 신규.
- [ ] **사용자 작업 남음** — Play Console 로그인 후: (1) 데이터 안전 폼 = "수집 안 함" / "디바이스 내 처리"로 작성. (2) 개인정보처리방침 URL 등록: `https://leegemma.github.io/maxiedit-prototype/docs/privacy.html`. (3) (선택) 라이선스 URL: `https://leegemma.github.io/maxiedit-prototype/docs/licenses.html`. (4) Google 자체 심사 1~7일 대기.

**왜**: Play Store는 매년 타겟 SDK 강제 상향. 미준수 시 신규 설치 차단. 미디어 권한 쓰는 앱은 데이터 안전 + 개인정보처리방침 URL 필수.

**할 일**:
- Google Play Console 로그인 → "정책 및 프로그램" 확인
- 데이터 안전 섹션: "수집 안 함, 디바이스 내 처리" 명시
- 개인정보처리방침 URL — GitHub Pages에 1페이지 정적 호스팅으로 충분

**Claude Code 프롬프트** (개인정보처리방침 페이지 작성용):
```
docs/privacy.html 만들어줘.
- MaxiEdit는 사용자가 선택한 사진/영상을 디바이스 내에서만 처리하고,
  서버로 전송하지 않으며, 어떤 데이터도 수집하지 않음
- 권한: 사진 라이브러리 접근 (편집 목적)만
- 외부 라이브러리: Google Fonts, Sortable, html2canvas, ffmpeg.wasm 명시
- 디자인은 검정 배경 + Inter/Noto Sans KR + 본 앱 톤과 일치
- 한국어 + 영어 병기
- GitHub Pages에서 https://leegemma.github.io/maxiedit-prototype/privacy.html 로
  접근 가능하도록
```

**완료 기준**:
- privacy.html 배포됨
- Play Console에 URL 등록
- 데이터 안전 폼 채움

---

## 🟡 4. 에러 모니터링 도입

- [x] **1단계 완료** (2026-04-30) — `window.addEventListener('error' / 'unhandledrejection')` 두 핸들러를 `<script>` 최상단에 배치. 현재는 `console.error`로만 출력. CLAUDE.md "Error handling" 섹션 신규.
- [ ] **2단계 미완료** — Sentry 도입 (`@sentry/capacitor` 검토). DSN은 별도 config 변수로 분리. 강제 throw 테스트 후 대시보드 이벤트 도착 확인.

**왜**: 지금 사용자가 크래시 나도 운영자는 모름. 운영의 눈을 만들어야 함.

**1단계 — 무료, 외부 의존성 0**:
```
index.html에 전역 에러 핸들러 추가:
- window.addEventListener('error', ...)
- window.addEventListener('unhandledrejection', ...)
- 일단 console.error로만 출력하고, 추후 Sentry 도입 시 여기서 후킹
- 위치: <script> 시작 부분 (다른 코드보다 먼저)
- CLAUDE.md에 "에러 핸들링" 섹션 신규 추가
- HISTORY.md 한 줄
```

**2단계 — Sentry 도입 (별도 커밋)**:
- Sentry 무료 티어 프로젝트 생성
- DSN을 index.html에 직접 박지 말고 별도 config 변수로 분리
- Capacitor 안드로이드 네이티브 크래시도 함께 잡으려면 `@sentry/capacitor` 검토

**완료 기준**:
- 강제 throw 테스트 시 콘솔 캡처 확인
- (Sentry 도입 후) 대시보드에 이벤트 도착 확인

---

## 🟡 5. 안드로이드 키스토어 백업 정책

- [x] **점검 완료** (2026-04-30) — git 히스토리에 키 자료 0 확인 (`*.keystore`, `*.jks`, `storePassword`/`keyPassword` 평문, `signingConfigs` 모두 깨끗). `.gitignore`에 `*.keystore`, `*.jks`, `keystore.properties`, `key.properties` 패턴 사전 보강. CLAUDE.md "Android signing" 섹션 신규 (파일 위치 / `keystore.properties` 분리 패턴 / 2-location 백업 규칙 / 분기 무결성 확인).
- [ ] **사용자 작업 남음** — release signing 시작 시점에 실제 keystore 생성 + 1Password/Bitwarden + 외장 디스크 2곳 백업 + 분기 캘린더 등록.

**왜**: 키스토어 분실하면 같은 앱 ID로 업데이트 불가. **이게 사고 나면 복구 0%**.

**할 일**:
- `*.keystore` 파일 위치 확인 (`~/dev/maxiedit-prototype-/android/app/` 추정)
- 비밀번호 + 키 별칭 함께 백업
  - 1Password / Bitwarden / iCloud Keychain 중 택1
  - 추가로 암호화 zip → 외장 디스크 또는 클라우드
- `.gitignore`에 keystore 패턴 들어있는지 확인
- 키 비밀번호를 코드/스크립트에 평문으로 두지 않았는지 점검

**Claude Code 프롬프트** (점검만):
```
프로젝트 전체에서 keystore 또는 키 비밀번호가 git에 들어갔을 가능성을
점검해줘. 검색 패턴:
- *.keystore, *.jks
- "storePassword", "keyPassword" 평문
- android/app/build.gradle의 signingConfigs 섹션
.gitignore도 함께 확인. 발견 시 보고만 하고 수정은 사용자 확인 후.
```

**완료 기준**:
- 키스토어 + 비밀번호 백업 위치 2곳 이상
- git에 키 자료 0
- 분기마다 백업 무결성 확인 캘린더 등록

---

## 🟡 6. GitHub Dependabot 활성화

- [x] **상태**: 완료 (2026-04-30) — `.github/dependabot.yml` 추가 (npm + github-actions, weekly, label `deps`, semver-major skip). repo Settings → Security → Dependabot에서 활성 확인 필요.

**왜**: 의존성 보안 취약점 자동 PR. 무료, 클릭 한 번.

**Claude Code 프롬프트**:
```
.github/dependabot.yml 만들어줘.
- npm 생태계 (package.json), 주 1회
- github-actions 생태계, 주 1회
- 자동 PR 라벨: "deps"
- 메이저 버전 자동 PR은 만들지 말고 minor/patch만
- HISTORY.md 한 줄
```

**완료 기준**:
- repo Settings → Security → Dependabot 활성
- 첫 주에 PR 한두 개 도착 확인

---

## 🟢 7. 캐시버스터 `?v=N` git history 일치 검사

- [x] **상태**: 완료 (2026-04-30) — `scripts/check-cachebuster.sh` 작성. 권장 N (= main 커밋 수) 출력 + 추적 파일에 stale N 핀이 있으면 빨간 경고로 종료 코드 1. CLAUDE.md "Live URLs"에서 사용법 한 줄. pre-push hook 통합은 별도 단계 (TODO 노트 그대로).

**왜**: CLAUDE.md 정책 — push마다 N+1. 누락되면 iOS Safari가 stale 서빙.

**Claude Code 프롬프트** (자동화 스크립트):
```
scripts/check-cachebuster.sh 만들어줘.
- 최근 main에 푸시된 커밋 수와 README 또는 공유 위치의 ?v=N 값 비교
- 불일치 시 빨간 메시지로 경고
- pre-push hook 또는 GitHub Actions로 돌릴 수 있게
- 일단 단발 실행 가능하게만 짜고, hook 통합은 별도 단계
- CLAUDE.md "Live URLs" 섹션에 검사 스크립트 언급 한 줄
```

**완료 기준**:
- 스크립트 실행 시 현재 N과 권장 N 출력
- 분기당 한 번 수동 점검 OK

---

## 🟢 8. iOS / Android 실기 회귀 테스트

- [ ] **상태**: 분기 1회 반복

**왜**: 코드 안 건드려도 OS·브라우저는 알아서 바뀜. MediaRecorder 거동, `dvh` 동작, `navigator.share`, 미디어 권한 다이얼로그 등이 갑자기 변할 수 있음.

**체크 포인트**:
- iOS Safari (최신 + 한 단계 이전)
  - `app-frame`이 `100dvh` 따라가는지
  - `navigator.share` 사진/영상 저장 정상
  - 키보드 올라올 때 textedit 모달 안 가려짐
- Android Chrome (최신)
  - MediaRecorder가 MP4 직접 뱉는지 vs ffmpeg 폴백 타는지
  - 영상 25분/1GB 한도 안에서 정상
- Android APK (실기)
  - Capacitor `backgroundColor: #000` 흰 플래시 없는지
  - 미디어 권한 다이얼로그
  - 시스템 뒤로가기 동작

**완료 기준**:
- 체크 결과를 짧게 HISTORY.md에 한 줄로 기록
- 회귀 발견 시 별도 이슈/커밋

---

## 🟢 9. OSS 라이선스 고지 페이지

- [x] **상태**: 완료 (2026-04-30) — `docs/licenses.html` 작성 (Sortable, html2canvas, ffmpeg.wasm, Capacitor, Heroicons, Inter, Noto Sans KR, Nanum Myeongjo). CLAUDE.md "External dependencies"에서 링크. Play Console "라이선스" 항목 등록 가능.

**왜**: ffmpeg.wasm은 LGPL 듀얼이라 고지 의무 있음. 다른 의존성도 일괄 정리해두면 안전.

**대상**:
- Sortable.js (MIT)
- html2canvas (MIT)
- ffmpeg.wasm (LGPL/MIT 듀얼)
- Google Fonts: Inter (OFL), Noto Sans KR (OFL), Nanum Myeongjo (OFL)
- Heroicons (MIT)
- Capacitor (MIT)

**Claude Code 프롬프트**:
```
docs/licenses.html 만들어줘.
- 위 6종 라이브러리 + 폰트 라이선스 전문 또는 링크
- 본 앱 디자인 톤과 일치 (검정/Inter/Noto Sans KR)
- 00_home 헤더에 작은 "ⓘ" 또는 "정보" 진입점 추가 검토 (별도 커밋 OK)
- GitHub Pages에서 접근 가능
- CLAUDE.md "External dependencies" 섹션에서 이 페이지로 링크
```

**완료 기준**:
- licenses.html 배포
- Play Console "라이선스" 항목에 URL 등록 가능

---

## 작업 시 참고

- 한 항목 = 한 커밋이 원칙 ([SKILLS.md](SKILLS.md)의 simplify 정책과 정합)
- 큰 항목(예: 4번 Sentry)은 1단계/2단계 나눠서 별도 커밋
- 도큐 스킵 금지 — code 변경 없이 정책만 바꿔도 CLAUDE.md/HISTORY.md 한 줄
- 막히면 SKILLS.md의 review / security-review 호출 고려
