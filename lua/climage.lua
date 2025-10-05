-- lua/climage/climage.lua

-- Importing RingBuffer
local RingBuffer = require("climage.logs")

rb = RingBuffer.new(20)

-- Utility: default title for notifications
local function log(msg, level)
    rb:push(msg)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Climage" })
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
log("Python executable" .. tostring(python_exec))

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
    log("Starting worker" .. worker_rel)

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

            -- Retrieve extmark position
            local pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, mark_id, {})
            local pos_row, pos_col = unpack(pos)
            log("Extmark position: " .. "row=" .. tostring(pos_row) .. "/" .. "col=" .. tostring(pos_col))

            -- Delete the extmark and insert the URL
            vim.api.nvim_buf_del_extmark(0, ns, mark_id)
            if status then
                vim.api.nvim_buf_set_text(bufnr, pos_row, pos_col, pos_row, pos_col, { result["url"] })
            end
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
    local lines = rb:items()
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
