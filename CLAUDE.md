# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Static HTML prototype of **MaxiEdit** — a mobile photo-editor flow built from Figma designs. Single file: [index.html](index.html). No build, no package manager, no tests. Open `index.html` directly in a browser (or VSCode Live Server) to run.

Target viewport is fixed at **393×852** (iPhone portrait). UI text is Korean.

External dependencies (loaded via CDN, no local install):
- Google Fonts — Inter, Noto Sans KR, Nanum Myeongjo
- Sortable.js 1.15.2 — long-press drag-reorder for selected thumbnails

## Architecture

### Screens as stacked overlays

Frames from Figma, implemented as a base screen + three overlays (all absolutely positioned, `hidden` by default, toggled via `.is-open`):

- `00_home` — base screen (`.screen`) — home with `btn_camera` (inert) + `btn_start`
- `02_edit` — overlay (`z-index: 100`), opened by `btn_start`
- `10_result` — overlay (`z-index: 200`), opened by bottom `btn_next` in `02_edit`
- `11_textedit` — modal dialog (`z-index: 300`), opened by `btn_text` in `10_result`

Close handlers: overlay-background click + Escape key. The top-most open overlay closes first (keydown handler checks textedit → result → edit).

### `02_edit` internal layer stack

Inside `.edit`, three stacked layers with deliberate z-index:

1. Base (`.preview`, `z:1`) — scaled-down `full_image` preview. Aspect ratio locked via `transform: scale(var(--preview-scale))` on a 393×522 inner element inside a clipping `.preview-viewport` whose dimensions are `calc(393px * var(--preview-scale))` and `calc(522px * var(--preview-scale))`.
2. `bottom_layer_imageList` (`z:2`) — category tabs + picker grid. Picker shows ~3.3 rows, scrolls vertically with iOS momentum. Grid rows pinned to square via `grid-auto-rows: calc((393px - 8px) / 3)` (don't rely on `aspect-ratio` alone — unreliable in grid context).
3. `bottom_layer_select` (`z:3`) — sticky bottom bar. Exactly 4 thumbs visible (`flex: 0 0 248px` = 4×56 + 3×8 gap); 5th+ scroll horizontally with snap. Long-press reorders via Sortable.js (`delay: 300`).

Header (`edit-header`, `z:4`) floats above preview with close-X and reset buttons.

Layer names mirror Figma names; users reference them that way in prompts.

### State model

Two orthogonal state arrays, each with a single dedicated renderer:

- **`selected[]`** — ordered photo indices (drives check icons, preview/result slots, thumbnail bar, counter). `render()` rebuilds all derived DOM. `MAX_SELECT = 9` enforced in `togglePhoto()`. Sortable `onEnd` does splice-out → splice-in then calls `render()`.
- **`textLabels[]`** — 9 strings shown in the `full_image` bottom legend (columns: left 4 / right 5). `renderTextareas()` rebuilds both `#preview-textarea` and `#result-textarea` from this array. Edited via the `11_textedit` modal (confirm writes back, cancel is a no-op).

When adding derived UI, plug into the matching renderer — don't add a third source of truth.

### Shared `full_image` component

The 3×3 color-slot grid + textarea legend is rendered identically in two places:
- `10_result` — full 393×522 size, positioned absolute at top: 94
- `02_edit` preview — same DOM structure inside `.preview-viewport`, scaled via CSS transform

`buildResultStyleGrid(target)` populates both grids; `renderGridSlots(gridEl)` syncs their colors/opacity to `selected`. When editing grid visuals, change in one place.

### `11_textedit` modal behavior

- Each row renders `(N)` as a separate **`<span class="textedit-num">`** plus the editable text in an `<input>`. Structural separation is why the number prefix cannot be edited — don't try to enforce this with JS.
- Inputs have `autocomplete/autocorrect/autocapitalize="off"` to suppress mobile auto-correction.
- Confirm writes every input back to `textLabels` by `data-index`, then calls `renderTextareas()`.

## Figma ↔ Code workflow

The Figma MCP server is configured in [.vscode/mcp.json](.vscode/mcp.json); allowed tools are pinned in [.claude/settings.local.json](.claude/settings.local.json).

When the user shares a Figma URL:
- Extract `fileKey` and `nodeId` from `figma.com/design/:fileKey/...?node-id=X-Y` (convert `-` to `:` in nodeId).
- Start with `get_metadata` for structure, then `get_design_context` for the node you're implementing.
- Figma responses are React+Tailwind — adapt to this project's vanilla HTML/CSS, don't copy verbatim.

**Rate limit**: The Figma account is on Starter plan and hits tool-call limits mid-session. When limited, ask the user for a screenshot (drop under [images/](images/)) or the structure rather than retrying repeatedly. The user has frequently pasted screenshots directly into chat as an alternative.

Users identify elements by their **Figma node names** (e.g. `btn_start`, `btn_next`, `btn_text`, `full_image`, `bottom_layer_select`, `icon_check_on`). Preserve these as `data-name` attributes on the corresponding DOM elements so references stay traceable across renames.

## Conventions picked up from the user

- **Icons**: shadcn/ui style = inline Lucide SVGs with `stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round`. Look up paths at https://lucide.dev before guessing. Icons in use: `x` (close), `arrow-left` (back), `rotate-ccw` (reset), `download`, `type` (T, "텍스트").
- **Button radius**: all button-shaped elements use `border-radius: 4px` (user preference, overrides pill/circle defaults). Applies to `.btn-*`, `.cat-tab`, `.thumb-remove`.
- **File creation path**: new project files go under `/Users/dreaming/Library/Mobile Documents/com~apple~CloudDocs/공동 작업/ClaudeProject/`.
- **No emojis** in code or UI unless explicitly requested.
- When adding assets, drop them in [images/](images/); the user refers to them by filename (e.g. "11_textedit.png 참고").
