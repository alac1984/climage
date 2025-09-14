# Climage Roadmap

This document outlines the planned development phases for **Climage**, from the initial MVP to long-term enhancements.
Each phase is broken into **atomic tasks** (`X.Y`) that can be individually tracked.

---

## Phase 0 — Scope and Architecture ✅

* **0.1** Define MVP: clipboard → upload → insert URL in buffer ✅
* **0.2** Choose core technologies (Lua + Python) ✅
* **0.3** Select upload backends for MVP (S3/MinIO, Imgur/ImgBB, SSH/rsync) ✅
* **0.4** Identify OS dependencies (`xclip`, `wl-paste`, `pbpaste`, PowerShell) ✅
* **0.5** Define output formats (Markdown default, HTML optional) ✅
* **0.6** List configuration variables (e.g., backend, output format, template) ✅

---

## Phase 1 — UX in Neovim (Lua) ⬜

* **1.1** Create repo structure (`plugin/` and `lua/climage/`) ⬜
* **1.2** Add formatter/linter setup ⬜

  * **1.2.1** Configure Stylua locally ⬜
  * **1.2.2** Add `.stylua.toml` rules ⬜
  * **1.2.3** Add pre-commit hook ⬜
  * **1.2.4** Setup GitHub Actions with cache ⬜
* **1.3** Add boilerplate (`print("climage loaded")`) ⬜
* **1.4** Define user commands ⬜

  * **1.4.1** Register `:ClimageUpload` ⬜
  * **1.4.2** Register `:ClimageConfig` ⬜
  * **1.4.3** Point both to stub functions ⬜
* **1.5** Async integration with worker ⬜

  * **1.5.1** Spawn Python subprocess ⬜
  * **1.5.2** Capture stdout/stderr ⬜
  * **1.5.3** Parse response (mock JSON) ⬜
* **1.6** Show UX feedback in Neovim ⬜

  * **1.6.1** Show success notification (`vim.notify`) ⬜
  * **1.6.2** Show error notification ⬜
  * **1.6.3** Provide log/debug command (`:ClimageLogs`) ⬜
* **1.7** Insert mock URL into buffer ⬜

  * **1.7.1** Place cursor snippet insertion ⬜
  * **1.7.2** Validate Markdown output ⬜
  * **1.7.3** Support HTML as optional ⬜

---

## Phase 2 — Python Worker (Clipboard) ⬜

* **2.1** Capture clipboard images ⬜

  * **2.1.1** Linux: `xclip` (X11) ⬜
  * **2.1.2** Linux: `wl-paste` (Wayland) ⬜
  * **2.1.3** macOS: `pbpaste` ⬜
  * **2.1.4** Windows: PowerShell ⬜
* **2.2** Normalize formats ⬜

  * **2.2.1** Convert TIFF → PNG ⬜
  * **2.2.2** Ensure color consistency (RGB) ⬜
  * **2.2.3** Save temporary file in `/tmp` or OS equivalent ⬜
* **2.3** Return metadata ⬜

  * **2.3.1** Width/height ⬜
  * **2.3.2** File size (bytes) ⬜
  * **2.3.3** Format (PNG, JPG, etc.) ⬜

---

## Phase 3 — Upload Backends ⬜

* **3.1** S3/MinIO backend ⬜

  * **3.1.1** Load credentials/config ⬜
  * **3.1.2** Implement upload ⬜
  * **3.1.3** Generate public/pre-signed URL ⬜
  * **3.1.4** Return JSON ⬜
* **3.2** Imgur/ImgBB backend ⬜

  * **3.2.1** Handle API key ⬜
  * **3.2.2** POST image ⬜
  * **3.2.3** Parse response URL ⬜
  * **3.2.4** Return JSON ⬜
* **3.3** SSH/rsync backend ⬜

  * **3.3.1** Handle SSH key/credentials ⬜
  * **3.3.2** Upload via `rsync` ⬜
  * **3.3.3** Build final URL from server path ⬜
  * **3.3.4** Return JSON ⬜

---

## Phase 4 — Snippet Insertion ⬜

* **4.1** Generate Markdown snippet ⬜

  * **4.1.1** Format `![alt](url)` ⬜
  * **4.1.2** Auto-fill alt with filename ⬜
* **4.2** Add HTML snippet support ⬜

  * **4.2.1** Format `<img src="..." alt="...">` ⬜
* **4.3** Support custom templates ⬜

  * **4.3.1** Define in config ⬜
  * **4.3.2** Apply variables (url, width, height, etc.) ⬜

---

## Phase 5 — Configuration and Security ⬜

* **5.1** Global configs (\~/.config/climage/config.json) ⬜
* **5.2** Project configs (.climage.json in repo) ⬜
* **5.3** Environment-based configs ⬜
* **5.4** Secure credential storage (system keyring) ⬜
* **5.5** Config validation (`:ClimageDoctor`) ⬜

---

## Phase 6 — Quality and Performance ⬜

* **6.1** Image optimization ⬜

  * **6.1.1** Resize large images ⬜
  * **6.1.2** Support WEBP conversion ⬜
  * **6.1.3** Recompression options ⬜
* **6.2** Local cache of uploads ⬜
* **6.3** Offline fallback (store + retry later) ⬜
* **6.4** Async uploads with progress ⬜

---

## Phase 7 — Testing and CI ⬜

* **7.1** GitHub Actions for Linux/macOS/Windows ⬜
* **7.2** Smoke tests for worker ⬜
* **7.3** Unit tests for Lua integration ⬜
* **7.4** Lint/format checks (Lua + Python) ⬜

---

## Phase 8 — Documentation and DX ⬜

* **8.1** Write complete README ⬜
* **8.2** Quick onboarding guide ⬜
* **8.3** FAQ + troubleshooting ⬜
* **8.4** Record demos (asciinema/vhs) ⬜
* **8.5** Implement `:ClimageDoctor` command ⬜

---

## Phase 9 — Hardening and Roadmap ⬜

* **9.1** Support multiple images in one call ⬜
* **9.2** Add more backends (Cloudinary, Google Drive, etc.) ⬜
* **9.3** Optional OCR for alt-text ⬜
* **9.4** Retention policies (auto-delete after N days) ⬜
* **9.5** Add `CONTRIBUTING.md` and open repo to contributions ⬜

## Legend
    * ✅ Completed
    * ⬜ Pending
