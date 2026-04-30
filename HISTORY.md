# HISTORY

이 파일은 의미 있는 변경에 대한 시간순 changelog입니다.
설계/구조의 큰 변동은 [CLAUDE.md](CLAUDE.md)에 정리되고, 이 파일은 짧은 한 줄 요약을 누적합니다.
새 항목은 **위쪽**(가장 최근이 위)에 추가합니다.

| 날짜 | 커밋 | 요약 |
|---|---|---|
| 2026-04-30 | (this commit) | TODO #9 처리 — `docs/licenses.html` 신규 (Sortable / html2canvas / ffmpeg.wasm / Capacitor / Heroicons + Inter / Noto Sans KR / Nanum Myeongjo). CLAUDE.md "External dependencies"에서 링크 |
| 2026-04-30 | 84112c8 | TODO #4 1단계 — `<script>` 최상단에 `error` / `unhandledrejection` 전역 핸들러 추가 (현재는 console.error로만, Sentry 후킹 지점 확보). CLAUDE.md "Error handling" 섹션 신규 |
| 2026-04-30 | c28a1b7 | TODO #6 처리 — `.github/dependabot.yml` 추가 (npm + github-actions, weekly, label `deps`, semver-major skip) |
| 2026-04-30 | b9536b1 | TODO #1 처리 — Sortable.js 1.15.2 / html2canvas 1.4.1 `<script>`에 SRI(sha384) + crossorigin="anonymous" 적용. CLAUDE.md "External dependencies"에 해시 갱신 규칙 한 줄 추가. ffmpeg.wasm은 lazy라 제외 |
| 2026-04-29 | 89fa7ca | 12_single을 10_result와 골격 통일(.split-track top:69 height:522, image/text 5:5, indicator top:615), 출력 1080×1434로 통일, 다음/닫기/뒤로 버튼 다듬기(높이 32, padding 0 12 1, 좌측 8), bottom_layer_select 우측 padding 0 + 썸네일 영역 flex:1 1 0으로 확장 + 5번째 이상 추가 시 자동 스크롤, letter-spacing 0.18em 일괄 제거, GNB 탭 좌우 padding 14→10, btn-text-single/flip/btn-reset 라벨 크기 일괄 +1px |
| 2026-04-29 | c40871a | 아이콘 전면 Heroicons outline 전환(11종, stroke 1.5), thumb-remove 빨간 원형 + X 아이콘, bottom_layer_select 썸네일 30% 검정 scrim, 12_single 하단 툴바 좌정렬, 다이얼로그 메시지 줄바꿈, 다음/초기화/다운로드/텍스트/뒤집기/확인 버튼 폰트 +1px |
| 2026-04-28 | e7b9544 | SKILLS.md 추가 — 어떤 Claude Code 스킬을 언제 쓸지 정책 문서화 |
| 2026-04-28 | acf43c3 | HISTORY.md 도입 — 모든 코드 커밋에 doc 업데이트를 함께 stage하는 정책 명문화 |
| 2026-04-28 | 09987ad | CLAUDE.md 전면 갱신 (페이지 모델 / VSCO 톤 / 12_single / 1080-wide 출력 / Capacitor 빌드 반영) |
| 2026-04-27 | df91177 | Capacitor config / package.json 다듬기 (6.2.1, backgroundColor #000) |
| 2026-04-27 | dc40d1f | MP4 화질 개선 — 캔버스 1080-wide, videoBitsPerSecond 6 Mbps, ffmpeg fast/high/crf 20 |
| 2026-04-27 | df91177 이전 | VSCO 리스타일 / 다운로드 모달 통합 / 단일 PNG 출력 일치 / 영상 25분·1GB 한도 / textedit 폰트 / 영상저장 진행 인디케이터 등 다수 |
