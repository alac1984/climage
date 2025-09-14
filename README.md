# Climage (WIP)

> **Clipboard → URL, in one command.**
> Climage is a Neovim plugin that grabs an image from your system clipboard, uploads it to a configurable backend (S3/MinIO, Imgur/ImgBB, or your own homelab), and pastes the resulting URL directly into your text files (e.g., Markdown).

---

## Status

**🚧 Work in progress.**
APIs, commands, and configuration may change without notice. Early contributors welcome!

---

## Why

Screenshots and quick image notes are part of everyday dev/documentation. Climage removes the friction:

1. Detect image from clipboard
2. Upload to your preferred storage
3. Paste a ready-to-share URL or snippet where your cursor is

No alt-tabbing, no manual uploads, no broken links.

---

## Features (planned)

* ✅ **Neovim-first UX** (minimal, fast, async)
* 🖼️ **Clipboard image detection** across Linux/macOS/Windows
* ☁️ **Multiple upload backends** (pick one per project or globally):

  * S3/MinIO (public ACL or pre-signed URLs)
  * Imgur/ImgBB (quick plug-and-play)
  * SSH/rsync to your **homelab** + static server (Nginx/Caddy)
* ✍️ **Smart snippets** by filetype (Markdown default; HTML/others optional)
* 🧹 Optional **format conversion/optimization** (e.g., PNG → WEBP, resize)
* 🔁 **Fallback offline** (save locally, mark as pending, retry later)
* 🔎 `:ClimageDoctor` to diagnose missing deps/creds

> **Note:** The first public milestone focuses on: clipboard → upload → paste Markdown URL, with S3 + Imgur backends.

---

## Requirements

* **Neovim** ≥ 0.9
* **Clipboard tools**

  * Linux (Xorg): `xclip` or `xsel`
  * Linux (Wayland): `wl-clipboard` (`wl-paste`)
  * macOS: `pbpaste` / AppleScript (built-in)
  * Windows: PowerShell (`Get-Clipboard`)
* **Optional** (for image ops): ImageMagick
* **If using the Python worker** (recommended for rich backends/processing):

  * Python ≥ 3.12
  * Poetry (for dev)
  * SDKs per backend (e.g., `boto3` for S3) — details in future releases

---

## Installation

> **WIP:** Not released on plugin registries yet.
> Once the MVP is published, you’ll be able to install via your plugin manager (e.g., `lazy.nvim`, `packer.nvim`, `vim-plug`). For now, the repo hosts the scaffolding and CI/config.

---

## Usage (preview)

* `:ClimageUpload` — detect clipboard image → upload → paste URL/snippet at cursor
* `:ClimageDoctor` — run environment checks (clip tools, creds, backend reachability)
* `:ClimageConfig` — open or print current config/overrides

> Commands and exact names may change while WIP.

---

## Configuration (design)

Climage supports **three layers** (later ones override earlier ones):

1. Built-in defaults
2. **Global** config (e.g., `~/.config/climage/config.toml`)
3. **Project** config (e.g., `.climage.toml` at repo root)

Common keys (subject to change while WIP):

* `backend = "s3" | "imgur" | "imgbb" | "ssh"`
* `snippet = "markdown" | "html"`
* `filename_template = "{iso}-{slug}-{hash}.png"`
* `optimize = true/false` (and related options)

**Secrets** are read from **environment variables** (preferred) or OS keyring (future):

* S3/MinIO: `CLIMAGE_S3_BUCKET`, `CLIMAGE_S3_REGION`, `CLIMAGE_S3_KEY`, `CLIMAGE_S3_SECRET`, `CLIMAGE_S3_ENDPOINT`
* Imgur: `CLIMAGE_IMGUR_TOKEN`
* ImgBB: `CLIMAGE_IMGBB_KEY`
* SSH: `CLIMAGE_SSH_HOST`, `CLIMAGE_SSH_USER`, `CLIMAGE_SSH_PATH`, plus your SSH keys

---

## Roadmap (high level)

* **MVP**: Clipboard → S3/Imgur → Markdown snippet
* **Backends**: MinIO, ImgBB, SSH/rsync homelab
* **Config**: global + per-project, env-based secrets
* **Doctor**: environment validation and actionable hints
* **Optimization**: PNG→WEBP, JPEG quality, max width/height
* **HTML/reST/AsciiDoc** snippets
* **Retry queue** + offline fallback
* **More backends**: Cloudflare R2, Backblaze B2, GitHub Pages/Gist, Google Drive
* **Nice to have**: OCR alt-text (Tesseract), multi-image batch, retention policies

---

## Development

This repo ships with a solid **pre-commit** setup.

**One-time setup**

```bash
git clone git@github.com:alac1984/climage.git
cd climage
poetry install
pre-commit install
pre-commit install --hook-type pre-push
```

**Run hooks manually**

```bash
pre-commit run --all-files                  # pre-commit hooks
pre-commit run --all-files --hook-stage push  # simulate pre-push
```

**Tests**

```bash
poetry run pytest -q
```

**Style/Lint**

* Python: Ruff (lint + format)
* Lua: Stylua
* Hygiene: pre-commit-hooks (YAML/TOML checks, trailing whitespace, etc.)

---

## Troubleshooting

* **Wayland**: install `wl-clipboard` (`wl-paste`).
* **Xorg**: install `xclip` or `xsel`.
* **No tests collected** blocking push: add a tiny smoke test or temporarily push with `--no-verify` (not recommended long-term).
* **Credentials not picked up**: verify env vars are exported in your shell and Neovim inherits them; try `:ClimageDoctor` (WIP).

---

## Security & Privacy

Climage **uploads images**. Be mindful of:

* Sensitive info in screenshots (tokens, emails, internal systems).
* Public vs. pre-signed URLs.
* Retention/cleanup policies on your chosen backend.

You own your data and your infra; configure accordingly.

---

## License

MIT © André Carvalho

---

## Contributing

Issues and PRs are welcome, especially around:

* Backend adapters (S3 variations, homelab workflows)
* Cross-platform clipboard handling
* Robust diagnostics (`:ClimageDoctor`)
* Docs & examples

Let’s keep it simple, fast, and reliable.
