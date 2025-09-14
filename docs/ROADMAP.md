# Climage Roadmap

This document outlines the planned development phases for **Climage**, from the initial MVP to long-term enhancements.
The roadmap is organized in incremental phases. Each phase can be tracked as **done/pending** and updated over time.

---

## Phase 0 — Scope and Architecture ✅
- [x] Define MVP: **clipboard → upload → insert URL in buffer**
- [x] Choose technologies: **Lua (Neovim core)** + **Python (worker)**
- [x] Select initial backends: **S3/MinIO, Imgur/ImgBB, SSH/rsync**
- [x] Identify OS dependencies: `xclip`, `wl-paste`, `pbpaste`, PowerShell
- [x] Define output formats: Markdown (default), HTML (optional)
- [x] Define configuration variables

---

## Phase 1 — UX in Neovim (Lua) ⬜
- [ ] Implement commands `:ClimageUpload` and `:ClimageConfig`
- [ ] Integrate with worker asynchronously
- [ ] Show success/error messages
- [ ] Return mock URL as initial response

---

## Phase 2 — Python Worker (Clipboard) ⬜
- [ ] Capture clipboard images reliably (Linux/macOS/Windows)
- [ ] Normalize formats (e.g., TIFF → PNG)
- [ ] Return metadata (width, height, size, format)

---

## Phase 3 — Upload Backends ⬜
- [ ] Implement S3/MinIO upload
- [ ] Implement Imgur/ImgBB upload
- [ ] Implement self-hosted server upload via SSH/rsync
- [ ] Worker returns JSON:
  ```json
  { "url": "...", "width": 0, "height": 0, "size": 0, "backend": "..." }

---

## Phase 4 — Snippet Insertion ⬜
* [ ] Generate Markdown snippet (default)
* [ ] Add HTML snippet support
* [ ] Include basic alt-text
* [ ] Allow custom templates

---

## Phase 5 — Configuration and Security ⬜
* [ ] Support global, per-project, and environment-based configs
* [ ] Secure credential storage (keyring)
* [ ] Setup validation

---

## Phase 6 — Quality and Performance ⬜
* [ ] Optimize images (resize, WEBP, recompression)
* [ ] Implement local cache
* [ ] Provide offline fallback
* [ ] Support asynchronous uploads

---

## Phase 7 — Testing and CI ⬜
* [ ] Setup GitHub Actions for Linux/macOS/Windows
* [ ] Add smoke tests for Python worker
* [ ] Add lint/format checks (Lua + Python)

---

## Phase 8 — Documentation and DX ⬜
* [ ] Write complete README
* [ ] Provide quick onboarding
* [ ] Add FAQ and troubleshooting
* [ ] Record demos with asciinema/vhs
* [ ] Implement `:ClimageDoctor` diagnostic command

---

## Phase 9 — Hardening and Roadmap ⬜
* [ ] Support multiple images
* [ ] Add new upload backends
* [ ] Optional OCR for alt-text
* [ ] Implement retention policies
* [ ] Add `CONTRIBUTING.md` and open to external contributions

---

## Legend

* ✅ Completed
* ⬜ Pending
