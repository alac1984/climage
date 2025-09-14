# ARCHITECTURE.md

## 🎯 MVP — Goal

The initial goal of **Climage** is simple and personal:

> **Capture an image from the clipboard → upload it to a home server via SSH/rsync → insert the resulting URL into the Neovim buffer.**

---

## ⚙️ Components

### Core (Lua, Neovim)

* Expose command `:ClimageUpload`.
* Call Python worker asynchronously.
* Parse JSON response from worker.
* Insert snippet into buffer (`![](url)` by default).

### Worker (Python)

* Detect image from clipboard.
* Normalize format (convert to PNG).
* Upload the image to home server via **SSH/rsync**.
* Return JSON object `{url, width, height, size, backend}`.

---

## ☁️ Backend (MVP)

* **Home server** accessible via SSH/rsync.
* Configurable folder structure (e.g., `~/public_html/images/`).
* Final URL will be based on configured host (e.g., `https://myserver/images/<filename>.png`).

---

## 🖥️ Supported Operating Systems

* **Linux (Xorg/Wayland)** → `xclip` or `wl-paste`.
* **macOS** → `pbpaste`.
* **Windows** → PowerShell.

*(For the MVP, Linux support is enough. Cross-platform expansion will follow later.)*

---

## 🔌 Dependencies

### Lua / Neovim

* Neovim >= 0.9
* [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim) (for async execution)

### Python

* Python 3.x
* `Pillow` (image normalization)
* `paramiko` (for SSH) or direct `rsync` binary usage
* `json` (standard library)

### System

* Linux: `xclip` or `wl-paste`
* macOS: `pbpaste`
* Windows: PowerShell

---

## 🔄 Workflow

1. User runs `:ClimageUpload` in Neovim.
2. Core (Lua) spawns Worker (Python).
3. Worker:

   * Captures image from clipboard.
   * Converts it to PNG if needed.
   * Saves a temporary local file.
   * Uploads it via SSH/rsync to the server.
   * Builds the public URL.
   * Returns JSON to stdout.
4. Core receives JSON, extracts URL, and inserts snippet into buffer:

   ```markdown
   ![](https://myserver/images/<filename>.png)
   ```

---

## 🔧 Minimum Configuration (MVP)

* `backend = "ssh"`
* `ssh_host = "myserver"`
* `ssh_user = "andre"`
* `ssh_path = "~/public_html/images/"`
* `url_prefix = "https://myserver/images/"`
* `snippet_format = "markdown"`

---

## 📌 Known Limitations (MVP)

* Only **one backend** (SSH/rsync) supported.
* Snippet fixed to Markdown.
* No caching or image optimization yet.
* Initially tested only on Linux.

---

## 🚀 Future Work

* Add more backends (S3/Imgur).
* Support HTML and custom templates.
* Project-level and environment variable configuration.
* Image optimization (resize, webp, recompression).
* Diagnostic command `:ClimageDoctor`.

---

Would you like me to also draft a **lighter `README.md`** (with badges, “WIP” disclaimer, short description, quick-start goals) so the repo already feels “alive” for outsiders?
