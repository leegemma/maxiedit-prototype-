# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**MaxiEdit** — a mobile photo/video collage flow built from Figma designs.

- Web prototype: single file [index.html](index.html). No build, no package manager, no tests for the web side. Open `index.html` directly or via VSCode Live Server.
- Android wrapper: [Capacitor 6.x](https://capacitorjs.com/) project scaffold ([package.json](package.json), [capacitor.config.json](capacitor.config.json), `www/`). The `android/` folder is generated locally with `npm run cap:add:android` and is git-ignored.

Target viewport is fixed at **393×852** (iPhone portrait). UI text is Korean.

External dependencies (loaded via CDN, no local install):
- Google Fonts — Inter, Noto Sans KR (used by buttons/UI), Nanum Myeongjo (caption serif inside `full_image`)
- Sortable.js 1.15.2 — long-press drag-reorder for selected thumbnails
- html2canvas 1.4.1 — full result PNG export
- ffmpeg.wasm 0.12.10 (lazy) — MP4 transcode fallback when MediaRecorder doesn't emit MP4

Eagerly-loaded `<script>` tags pin a `sha384` SRI hash plus `crossorigin="anonymous"` so a tampered or stale CDN response is rejected by the browser. Regenerate the hash whenever the version bumps (e.g. `curl --ssl-no-revoke -sS <url> | openssl dgst -sha384 -binary | openssl base64 -A`). ffmpeg.wasm stays unhashed because it loads its own sub-resources at runtime.

Full attribution and license texts: [docs/licenses.html](docs/licenses.html) (deployed at https://leegemma.github.io/maxiedit-prototype/docs/licenses.html). Add a row there whenever a new dependency is introduced.

## Live URLs

- GitHub repo: https://github.com/leegemma/maxiedit-prototype
- GitHub Pages: https://leegemma.github.io/maxiedit-prototype/

When sharing the Pages URL with the user, always append a cache-busting `?v=N` query (e.g. `https://leegemma.github.io/maxiedit-prototype/?v=3`). Increment N by 1 with every new push to `origin/main` so iOS Safari can't serve a stale deploy. Do not reset N across conversations — derive it from git history if unknown. The local HTTP server URL (`http://<lan-ip>:8080/`) does not need this.

`bash scripts/check-cachebuster.sh` prints the current recommended `N` (= commit count on `main`) and warns if any tracked file outside the exempt list (`HISTORY.md`, `CLAUDE.md`, the script itself) pins a stale value. Run it before sharing fresh links.

## Two working clones

This project lives in two places on disk; both point to the same GitHub remote:

- **iCloud copy** (web edits): `/Users/dreaming/Library/Mobile Documents/com~apple~CloudDocs/공동 작업/ClaudeProject/Test`
- **Clean clone** (Android build, no Korean/spaces in path): `~/dev/maxiedit-prototype-`

Android Studio cannot start an IDE inside the iCloud + Korean path, so all native build commands (`npm install`, `npm run cap:add:android`, `cap:open:android`, `cap:build:android`) MUST be run from `~/dev/maxiedit-prototype-`. Web edits/commits can happen in either; pull on the other side to stay in sync.

## Architecture

### Pages, not overlays

The app navigates between four discrete pages plus one modal. **Only one page is visible at a time — toggled via the `[hidden]` attribute** (with a global `[hidden] { display: none !important }` rule for safety on iOS Safari). The earlier overlay/z-index stacking model was removed because mobile Safari rendered every overlay simultaneously on shorter viewports.

| Page id | data-name | Reached from |
|---|---|---|
| `#page-home` | `00_home` | initial route |
| `#page-edit` | `02_edit` | home `btn_start` |
| `#page-result` | `10_result` | edit `btn_next` (≥1 photo selected) |
| `#page-single` | `12_result_single` | result indicator dot or slot tap |
| `#textedit-overlay` | `11_textedit` (modal) | `btn_text` on result/single |
| `#download-modal` | (modal) | `btn_download` on result/single |

`goTo(name)` is the single navigation primitive — it sets `hidden` on every page except the target, dismisses textedit if leaving result, runs the auto photo-picker on first edit entry, and triggers the bottom-bar slide-up animation on `02_edit`.

The whole app sits inside `.app-frame` (393×852, capped at `100dvh` to track the iOS Safari URL bar). `.app-frame { overflow: hidden }` clips to the phone-shaped viewport when the browser is wider.

### `02_edit` internal layer stack

Inside the edit page (top → bottom):

1. **Header** (`.edit-header`, `z:4`, `top: 12`) — close-X icon button (`btn-edit-close`) and reset (`btn-reset-top`, RotateCcw + 초기화 label)
2. **`preview`** (`z:1`, `top: 69`) — scaled-down `full_image` mirror at `--preview-scale: 0.4` via `transform: scale()` on a 393×522 inner inside a clipping viewport
3. **`bottom_layer_imageList`** (`z:2`, `top: calc(69px + 522px*0.4)` ≈ 277.8) — category tabs + picker grid. Picker grid uses `grid-template-columns: repeat(3, 1fr)` + `grid-auto-rows: calc((393px - 8px) / 3)` for square cells (don't rely on `aspect-ratio` alone; flaky in grid). Empty state (`.picker-empty`) is `position: absolute; inset: 0` overlaying the grid so it never participates in row sizing.
4. **`bottom_layer_select`** (`z:3`, `bottom: 0`) — sticky bottom bar. Exactly 4 thumbs visible (`flex: 0 0 248px` = 4×56 + 3×8 gap); 5th+ scroll horizontally with snap. Long-press reorders via Sortable.js (`delay: 300`). Slides up on entry via `bls-slide-up` keyframe with `cubic-bezier(0.22, 0.9, 0.3, 1)` for an iOS-like inertial feel; `goTo('edit')` toggles `.is-entering` with a forced reflow so it replays on every re-entry.

### State model

Three orthogonal state shapes:

- **`photos[]`** — items the user picked from the device. Each entry: `{ url, originalUrl, name, type: 'image' | 'video', duration? }`. For videos, `url` is a JPEG thumbnail blob (first frame, captured via a hidden `<video>` element + canvas) and `originalUrl` is the playable source. `loadPhotoFiles(fileList, append?)` populates this; the `+` tile in the picker calls it with `append: true`. Photos are reset (`revokeMedia` on every entry) when the user closes edit back to home.
- **`selected[]`** — ordered photo indices (0..N-1, max 9). Drives picker check icons (`icon_check_on`/`off` + `data-selectNumber`), preview/result slot fills, thumbnail bar, counter on `다음 N/9`, and the result-page indicator. Sortable's `onEnd` does splice-out → splice-in then calls `render()`.
- **`textLabels[]`** — 9 caption strings rendered into the `full_image` bottom legend (left col 1-4 / right col 5-9) and into each single-view slide. Edited via the `11_textedit` modal: pass `null` from `btn-text-tool` (full result) for all 9 rows, or pass `currentSingleIdx` from `btn-text-single` for that single row only. `confirmTextedit()` writes back via `data-index`, calls `renderTextareas()`, and patches the matching `.split-text` in place so flip state and scroll position survive.

When adding derived UI, plug into the matching renderer — don't add a fourth source of truth.

### Shared `full_image` component

The 3×3 color-slot grid + textarea legend is rendered identically in two places:
- `10_result` — full 393×522 size, positioned absolute at `top: 69`
- `02_edit` preview — same DOM structure inside `.preview-viewport`, scaled via CSS transform

`buildResultStyleGrid(target, onCellClick?)` populates both grids; `renderGridSlots(gridEl, { animateVideos })` syncs their colors/opacity to `selected[]`. The result grid passes `animateVideos: true` so video slots get a live `<video autoplay loop muted playsinline>` element capped at `VIDEO_CLIP_SECONDS` (currently 2). When editing grid visuals, change in one place.

### `12_result_single` (split view)

A horizontal scroll-snap track (`#split-track`) holding one `.split-slide` per selected slot. The track is sized **identically to `10_result`'s `.full-image`**: `top: 69px; height: 522px` so the visible preview area is exactly 393×522 on both pages and the indicator (`top: 615px`) lands 24px below either content area.

Each `.split-slide` is full-width (`flex: 0 0 100%`) and split 5:5:

- `.split-image` — `width: 100%`, `flex: 0 0 50%` (top half = 261px, full slide width)
- `.split-text` — `width: 100%`, `flex: 0 0 50%` (bottom half; tappable, opens `11_textedit` for that slot's caption)

Toggling `.is-flipped` on the current slide flips image and text via `flex-direction: column-reverse`. Right-swipe at slide 0 (scrollLeft 0) returns to `10_result`; the indicator's leftmost dot does the same on click.

### Outputs

PNG/MP4 always exit at the same dimensions per surface:

| Surface | Width | Height | Aspect rationale |
|---|---|---|---|
| Full (10_result) | 1080 | 1434 | matches `full_image` 393×522 ratio |
| Single (12_result_single) | 1080 | 1434 | same dimensions as 10_result; canvas is split 50/50 to mirror the on-screen image/text panels (each 1080×717 in output) |

Bumped from the original 650-wide because at 650×… text/edges were getting compressed into mush. `videoBitsPerSecond: 6_000_000` is hinted to MediaRecorder; ffmpeg fallback uses `-c:v libx264 -preset fast -profile:v high -crf 20 -movflags faststart -an`.

`drawSingleFrame(ctx, w, h, slide)` is the canvas painter shared by single PNG and MP4 export — fills white, paints either the live video frame (if `videoEl.videoWidth > 0 && readyState >= HAVE_CURRENT_DATA`) or the still thumbnail image as fallback into the image half (top 50% of canvas, or bottom when `slide.flipped`), then fills the other half white and centers the Nanum Myeongjo caption in it.

`drawFullImageFrame(ctx, w, h, slots)` paints the 3×3 grid + textarea legend the same way for full MP4 export. Full PNG still uses `html2canvas` since it captures the whole legend DOM faithfully.

### Download flow

`btn-download` (and single `btn-single-download`) opens **one shared modal** with: 사진으로 저장 / 영상으로 저장 / 모두 저장 / 취소.

- **사진** dispatches to `downloadPng()` or `downloadSinglePng()` based on `currentPage`.
- **영상** dispatches to `downloadMp4()` / `downloadSingleMp4()`. Both record a 2s canvas stream, fall back to ffmpeg.wasm transcode (lazy-loaded from CDN, ~25 MB on first use) when MediaRecorder doesn't emit MP4 natively.
- **모두 저장** — `downloadAllContent()` saves the full result first (PNG if all photos, MP4 if any video) then iterates each selected slot saving as PNG (image) or MP4 (video). Mobile share sheets fire one at a time.

`saveBlob(blob, fileName)` prefers `navigator.share({ files })` so iOS gets the native share sheet with "Save Image" / "Save Video"; falls back to anchor-download elsewhere.

### `11_textedit` modal behavior

- Each row renders `(N)` as a separate `<span class="textedit-num">` plus the editable text in an `<input>`. Structural separation is why the number prefix cannot be edited — don't try to enforce this with JS.
- Inputs have `autocomplete/autocorrect/autocapitalize="off"` to suppress mobile auto-correction.
- Both `.textedit-num` and `.textedit-input` use `font-family: inherit` (Inter / Noto Sans KR) — match the rest of the chrome, not the Nanum Myeongjo caption font.
- Confirm writes every input back to `textLabels` by `data-index`, then calls `renderTextareas()` and patches the visible single slide's `.split-text` in place.

## Visual conventions (VSCO-inspired)

The whole chrome uses a single design vocabulary:

- **Canvas**: pure black (`#000`) page surfaces with translucent panels on top.
- **Typography**: Inter / Noto Sans KR. Light weights (300–500) at small sizes (10–13px) with **wide letter-spacing** (0.16em–0.42em). Headlines use `text-transform: uppercase` for English; Korean stays as-is.
- **Hairlines**: `1px solid rgba(255,255,255,0.32)` for outlined buttons; `1px solid rgba(255,255,255,0.08)` for dividers. Ghost buttons use transparent fill with a hairline border.
- **Single primary CTA**: `#fffb8a` yellow (`btn-start`, `btn-next-main`, `btn-download`, `btn-textedit-confirm`, `btn-download-png` in the modal). Everything else is muted-white text on transparent.
- **Borders**: every button uses `border-radius: 4px` regardless of size (user preference, overrides pill defaults).
- **Tabs**: bottom-border underline indicator (`.cat-tab.is-active { border-bottom: 1px solid #fff }`), no pills.
- **Indicator dots**: 5×5 muted dot, expands to 18×5 white pill on `.is-active` with a width transition.
- **Footer button stack** (`.btn-reset` on result, `.btn-text-single`/`.btn-flip` on single): icon on top, 10px uppercase 0.22em label below, `gap: 10px; padding: 10px 20px` so all three line up vertically.
- **Thumbnail scrim**: every photographic thumbnail used as a card background must sit under a `rgba(0, 0, 0, 0.4)` overlay (40% black) so foreground text and badges stay legible regardless of the underlying image. Implement as a sibling absolute-positioned overlay above the image and below the content (see `.home-card-overlay`), not as a CSS filter — the user wants the photo's own contrast preserved with a flat darkening pass.

When designing a new chrome surface, copy from these tokens. Don't invent a new pill or new border radius.

## Error handling

A pair of global handlers sits at the top of `index.html`'s main `<script>`:

- `window.addEventListener('error', ...)` — uncaught synchronous errors and resource load failures.
- `window.addEventListener('unhandledrejection', ...)` — promise rejections that nothing else caught.

Both currently just `console.error` with structured context. This is **stage 1** of TODO.md #4 — the goal is to give a single funnel that a real reporter (Sentry, Crashlytics, etc.) can hook into later without touching the rest of the codebase. When adding stage 2, replace the `console.error` body with the reporter's `captureException`, keep the listeners themselves intact.

Don't swallow errors in app code by adding broad `try/catch` blocks just to silence them — let them bubble to these handlers so they're visible.

## Documentation policy

Every commit that changes code must also update one of:
- **`CLAUDE.md`** — when the change is about architecture, behavior, design tokens, conventions, or anything a future Claude session needs to internalize
- **[HISTORY.md](HISTORY.md)** — for every commit, append a one-line entry (date + commit short hash + summary, newest on top)

Doc edits are staged with the source change so each commit is `(source + docs)` as one atomic unit. Don't push code without the docs caught up.

See [SKILLS.md](SKILLS.md) for which Claude Code skills to invoke (and which to skip) for this project.

## Conventions picked up from the user

- **Icons**: inline Heroicons outline SVGs (24×24, `stroke-linecap` and `stroke-linejoin` set to `round` on each `<path>`) with CSS `stroke: currentColor; fill: none; stroke-width: 1.5`. Look up paths at https://heroicons.com before guessing. Icons in use: `bell` (notification), `x-mark` (close), `arrow-left` (back), `arrow-path` (reset), `arrow-down-tray` (download), `arrows-right-left` (뒤집기), `photo` (사진 저장), `film` (영상 저장), `squares-2x2` (모두 저장), `play` (video badge). The "텍스트" T glyph stays as a custom path (no direct Heroicons equivalent), and the toast success ring/check keeps its bespoke animated structure.
- **No emojis** in code or UI unless explicitly requested.
- **Korean folder names** in iCloud break Android Studio; build only from `~/dev/`.
- When adding assets, drop them in [images/](images/); the user refers to them by filename (e.g. "11_textedit.png 참고"). These are reference screenshots only — not bundled into the web app.
- The user shares Figma screenshots directly in chat as a fallback when MCP rate-limits.

## Figma ↔ Code workflow

The Figma MCP server is configured in [.vscode/mcp.json](.vscode/mcp.json); allowed tools are pinned in [.claude/settings.local.json](.claude/settings.local.json).

When the user shares a Figma URL:
- Extract `fileKey` and `nodeId` from `figma.com/design/:fileKey/...?node-id=X-Y` (convert `-` to `:` in nodeId).
- Start with `get_metadata` for structure, then `get_design_context` for the node you're implementing.
- Figma responses are React+Tailwind — adapt to this project's vanilla HTML/CSS, don't copy verbatim.

**Rate limit**: The Figma account is on Starter plan and hits tool-call limits mid-session. When limited, ask the user for a screenshot or the structure rather than retrying repeatedly.

Users identify elements by their **Figma node names** (`btn_start`, `btn_next`, `btn_text`, `full_image`, `bottom_layer_select`, `icon_check_on`, etc.). Preserve these as `data-name` attributes on the corresponding DOM elements so references stay traceable across renames.

## Play Store compliance

- **Target SDK** is pinned in [android/variables.gradle](android/variables.gradle) (`compileSdkVersion` + `targetSdkVersion`). Google Play raises the minimum every August 31 — currently the floor is **35** (Android 15). Bump both values together when the next deadline approaches; the bundled Capacitor 6.x line tolerates SDK 35 without changes.
- **Privacy policy URL** for Play Console listing: `https://leegemma.github.io/maxiedit-prototype/docs/privacy.html` ([docs/privacy.html](docs/privacy.html)). The page declares zero data collection; update its "Last updated" date if behavior ever changes.
- **Data safety form**: declare nothing collected, nothing shared, on-device processing. Aligned with what [docs/privacy.html](docs/privacy.html) states.
- **OSS attribution URL**: `https://leegemma.github.io/maxiedit-prototype/docs/licenses.html` ([docs/licenses.html](docs/licenses.html)). Register under Play Console "License" if the listing supports it.

## Android signing

Release signing is **not** wired up yet (the current Capacitor scaffold only builds debug APKs). When it lands, follow these rules so the keystore never leaks into git:

- Keystore file (`*.keystore` / `*.jks`) lives at `android/app/maxiedit-release.keystore`. Never check it in — `.gitignore` already excludes the patterns.
- Credentials live in a separate `android/keystore.properties` (also gitignored). `app/build.gradle` reads it via `Properties()` so the values never appear in source. Skeleton:
  ```properties
  # android/keystore.properties — DO NOT commit
  storeFile=maxiedit-release.keystore
  storePassword=...
  keyAlias=maxiedit
  keyPassword=...
  ```
- Back the keystore + credentials up in **two places**: a password manager (1Password / Bitwarden) and an encrypted archive on a separate device or cloud. **Losing the keystore means losing the ability to ship updates under the same package id** (`com.leegemma.maxiedit`); recovery is impossible.
- Verify backup integrity quarterly. Add a calendar reminder on the day signing is set up.

## Android build (Capacitor)

From `~/dev/maxiedit-prototype-`:

```bash
npm install                  # one-time
npm run cap:add:android      # generates android/ on first run
npm run cap:open:android     # opens in Android Studio
# or
npm run cap:build:android    # CLI build → android/app/build/outputs/apk/debug/app-debug.apk
```

`npm run cap:sync` after every `index.html` change to push the new web bundle into `android/app/src/main/assets/public`.

Capacitor config notes: `androidScheme: https`, `backgroundColor: #000` (no white flash on launch), `captureInput: true` for keyboard-aware layout. JDK 17 is the path of least resistance for Gradle; Temurin 21 also works.
