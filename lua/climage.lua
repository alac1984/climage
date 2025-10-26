-- lua/climage/climage.lua

-- Importing RingBuffer
local RingBuffer = require("climage.logs")

rb = RingBuffer.new(50)

-- Utility: default title for notifications
local function log(msg, level)
    -- Se a mensagem tiver múltiplas linhas, separa
    if type(msg) == "string" and msg:find("\n") then
        for line in msg:gmatch("[^\n]+") do
            rb:push(line)
        end
    else
        rb:push(msg)
    end
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Climage" })
end

-- Sanitizing html alt
local function sanitize_html_alt(raw)
    local s = tostring(raw or "")

    -- 1) Percent-decode: "file%20name.png" -> "file name.png"
    s = s:gsub("%%([0-9A-Fa-f][0-9A-Fa-f])", function(h)
        return string.char(tonumber(h, 16))
    end)

    -- 2) Removing controls (including \n, \r, \t) and NUL
    s = s:gsub("[%c%z]", " ")

    -- 3) Normalize: changing _ and - for space
    s = s:gsub("[_%-]+", " ")

    -- 4) Collapsing spaces and trim
    s = (s:gsub("%s+", " "):match("^%s*(.-)%s*$")) or ""

    -- 5) Limiting size
    if #s > 200 then
        s = s:sub(1, 200)
    end

    -- 6) Scaping essential HTML
    s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&#39;")

    log("s after scaping: " .. s, vim.log.levels.INFO)
    -- 7) Fallback
    if s == "" then
        s = "image"
    end

    return s
end

-- Utility: extract img name from url
local function extract_name(text)
    local url = text
    local path = url:match("^[^%?#]+") or url -- remove ?query and #hash
    local base = path:match("([^/]+)$") -- everything after the last /
    local img_name = base:match("^(.*)%.([^%.]+)$") -- before the last .
    if not img_name then
        img_name = "image"
    end
    return img_name, url
end

-- Utility: convert image url to Markdown
local function to_markdown(text)
    local img_name, url = extract_name(text)
    return "![" .. img_name .. "](" .. url .. ")"
end

-- Utility: convert image url to img tag
local function to_html(text)
    local img_name, url = extract_name(text)
    local alt = sanitize_html_alt(img_name)
    return '<img src="' .. url .. '" alt="' .. alt .. '" />'
end

-- Discover paths based on this file:
-- this file is located at: <repo>/lua/climage/climage.lua
local this_file = debug.getinfo(1, "S").source:sub(2) -- absolute path of the current file
local this_dir = vim.fs.dirname(this_file) -- .../lua/climage
local repo_root = vim.fs.dirname(vim.fs.dirname(this_dir)) -- go up 2 levels -> repo root
local worker_rel = "python/worker.py"
local worker_path = repo_root .. "/" .. worker_rel
log("Worker repository path: " .. worker_rel)

-- Allow the user to override the Python executable if desired:
-- :let g:climage_python = 'python3'
local python_exec = vim.g.climage_python or "python"
log("Python executable: " .. tostring(python_exec))

-- Simple filter to remove empty lines
local function nonempty_lines(lines)
    return vim.tbl_filter(function(s)
        return s and s ~= ""
    end, lines or {})
end

vim.api.nvim_create_user_command("ClimageUpload", function()
    local ns = vim.api.nvim_create_namespace("climage") -- Create namespace
    local bufnr = vim.api.nvim_get_current_buf() -- Current buffer
    -- Coordinates where the extmark will be created (cursor adjustment included)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    log("Extmark coordinates: " .. "row=" .. tostring(row) .. "/" .. "col=" .. tostring(col))
    row = row - 1

    -- Create the extmark
    local mark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
        virt_text = { { "Climage: uploading...", "Comment" } },
        right_gravity = true,
        end_row = row,
        end_col = col,
        hl_group = "Visual",
    })

    -- Immediate feedback
    log("Starting worker: " .. worker_rel)

    local job_id = vim.fn.jobstart({ python_exec, worker_path }, {
        cwd = repo_root, -- ensure "python/worker.py" exists in this CWD
        stdout_buffered = true, -- deliver whole lines
        on_stdout = function(_, data, _)
            local lines = nonempty_lines(data)
            if #lines == 0 then
                return
            end
            local jsonstr = ""
            for i = 1, #lines do
                jsonstr = jsonstr .. lines[i]
            end

            -- Parse JSON into a Lua table
            local status, result = pcall(vim.json.decode, jsonstr)
            log("JSON status: " .. tostring(status))
            if status then
                log("JSON result: " .. vim.inspect(result))
            end

            -- Result sanity
            if not status or type(result) ~= "table" then
                log("Worker JSON invalid.", vim.log.levels.ERROR)
                vim.api.nvim_buf_del_extmark(bufnr, ns, mark_id)
                return
            end
            if result.ok == false then
                log("Worker failed: " .. tostring(result.error or "no details"), vim.log.levels.ERROR)
                vim.api.nvim_buf_del_extmark(bufnr, ns, mark_id)
                return
            end
            local url = result.url
            if type(url) ~= "string" or url == "" then
                log("No URL output on Worker result", vim.log.levels.ERROR)
                vim.api.nvim_buf_del_extmark(bufnr, ns, mark_id)
                return
            end

            -- Retrieve extmark position
            local pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, mark_id, {})
            local pos_row, pos_col = unpack(pos)
            log("Extmark position: " .. "row=" .. tostring(pos_row) .. "/" .. "col=" .. tostring(pos_col))

            -- Normalize output choice
            local out = tostring(result.output or "plain"):lower()
            local formatted = url
            if out == "markdown" then
                formatted = to_markdown(url)

                -- Markdown Validation
                local ok_md = formatted:match("^%!%[[^%]]+%]%(%S+%)$")
                local scheme_ok = url:match("^https?://") or url:match("^data:")
                if not (ok_md and scheme_ok) then
                    log("Markdown snippet invalid; fallback for plain.", vim.log.levels.WARN)
                    formatted = url
                end
            end

            if out == "html" then
                formatted = to_html(url)

                -- HTML Validation
                local ok_md = formatted:match('^<img%s+src%s*=%s*"[^"\n]+"[^>]*/>%s*$')
                local scheme_ok = url:match("^https?://") or url:match("^data:")
                if not (ok_md and scheme_ok) then
                    log("HTML snippet invalid; fallback for plain.", vim.log.levels.WARN)
                    formatted = url
                end
            end

            -- Insertion after validation and normalization
            vim.api.nvim_buf_del_extmark(bufnr, ns, mark_id)
            vim.api.nvim_buf_set_text(bufnr, pos_row, pos_col, pos_row, pos_col, { formatted })
        end,
        on_stderr = function(_, data, _)
            local lines = nonempty_lines(data)
            if #lines == 0 then
                return
            end
            log("Worker stderr: " .. table.concat(lines, "\n"), vim.log.levels.ERROR)
        end,
        on_exit = function(_, code, _)
            if code == 0 then
                log("Worker finished successfully (exit=0).")
            else
                log("Worker failed (exit=" .. tostring(code) .. ").", vim.log.levels.ERROR)
            end
        end,
    })

    if job_id <= 0 then
        log("Failed to start worker process.", vim.log.levels.ERROR)
    end
end, { nargs = 0 })

vim.api.nvim_create_user_command("ClimageConfig", function(opts)
    log("Opening config… arg: " .. (opts.args or ""))
    -- future: open UI/config file
end, { nargs = "?" })

vim.api.nvim_create_user_command("ClimageLogs", function(opts)
    log("Opening logs… arg: " .. (opts.args or ""))
    local lines = {}
    for _, item in ipairs(rb:items()) do
        if type(item) == "string" and item:find("\n") then
            for line in item:gmatch("[^\n]+") do
                table.insert(lines, line)
            end
        else
            table.insert(lines, tostring(item))
        end
    end
    local buf = vim.api.nvim_create_buf(false, true) -- listed=false, scratch=true
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "climage.log"

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    vim.cmd("botright 12split")
    vim.api.nvim_win_set_buf(0, buf)

    vim.keymap.set("n", "q", "<cmd>bd!<cr>", { buffer = buf, nowait = true, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>bd!<cr>", { buffer = buf, nowait = true, silent = true })
end, { nargs = "?" })
