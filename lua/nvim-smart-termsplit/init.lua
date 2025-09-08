local M = {}

-- Configuration defaults
local config = {
    shell = nil, -- Auto-detect if nil
    enable_cleanup = true,
    fallback_to_home = true,
    debug = false,
}

-- Utility function for debug logging
local function debug_log(msg)
    if config.debug then
        print("[TermSplit] " .. msg)
    end
end

-- Get shell command based on platform
local function get_shell_cmd()
    if config.shell then
        return config.shell
    end
    
    if vim.fn.has('win32') == 1 then
        return vim.env.COMSPEC or 'cmd'
    else
        return vim.env.SHELL or '/bin/sh'
    end
end

-- Get working directory of terminal process
local function get_terminal_pwd(pid)
    local pwd = nil
    
    if vim.fn.has('win32') == 1 then
        -- Windows implementation could be added here
        debug_log("Windows pwd detection not implemented")
        return nil
    end
    
    -- Try different methods to get working directory
    local methods = {
        function() 
            return vim.fn.systemlist('readlink /proc/' .. pid .. '/cwd')[1] 
        end,
        function()
            local result = vim.fn.systemlist('lsof -p ' .. pid .. ' +D . 2>/dev/null | awk \'NR==2 {print $9}\'')[1]
            return result and vim.fn.fnamemodify(result, ':h') or nil
        end,
        function()
            return vim.fn.systemlist('pwdx ' .. pid .. ' 2>/dev/null | cut -d: -f2- | sed "s/^ //"')[1]
        end
    }
    
    for i, method in ipairs(methods) do
        local success, result = pcall(method)
        if success and result and result ~= "" and vim.fn.isdirectory(result) == 1 then
            debug_log("Got pwd using method " .. i .. ": " .. result)
            return result
        end
    end
    
    debug_log("Failed to get terminal pwd for pid " .. pid)
    return nil
end

-- Create terminal command with proper directory
local function create_terminal_cmd(pwd)
    local shell = get_shell_cmd()
    
    if not pwd then
        return 'term ' .. shell
    end
    
    -- Escape the path properly
    local escaped_pwd = vim.fn.shellescape(pwd)
    
    if vim.fn.has('win32') == 1 then
        return string.format('term cmd /c "cd /d %s && %s"', escaped_pwd, shell)
    else
        return string.format('term %s -c \'cd %s && exec %s\'', shell, escaped_pwd, shell)
    end
end

-- Enhanced autocmd for terminal cleanup
local function terminal_close_autocmd()
    if not config.enable_cleanup then
        return
    end
    
    local current_buf = vim.api.nvim_get_current_buf()
    local job_id = vim.b.terminal_job_id
    
    if not job_id then
        debug_log("No terminal job_id found for buffer " .. current_buf)
        return
    end
    
    local augroup_name = string.format("terminal_cleanup_%d_%d_%x", 
        current_buf, job_id, os.time() + math.random(10000))
    
    local function close_term_buffer(ev)
        local buf = ev.buf
        debug_log("Closing terminal buffer " .. buf)
        
        -- Use vim.schedule to avoid issues with autocmd context
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end)
        return true
    end
    
    vim.api.nvim_create_augroup(augroup_name, { clear = true })
    vim.api.nvim_create_autocmd("TermClose", {
        group = augroup_name,
        buffer = current_buf,
        callback = close_term_buffer,
        once = true,
        desc = "Auto-close terminal buffer on process exit"
    })
    
    debug_log("Created cleanup autocmd for buffer " .. current_buf)
end

-- Core split functionality
local function terminal_split(split_cmd)
    local is_terminal = vim.bo.buftype == 'terminal'
    local pwd = nil
    
    if is_terminal then
        local job_id = vim.b.terminal_job_id
        if job_id then
            local pid = vim.fn.jobpid(job_id)
            if pid > 0 then
                pwd = get_terminal_pwd(pid)
            else
                debug_log("Invalid pid: " .. tostring(pid))
            end
        else
            debug_log("No terminal job_id in current buffer")
        end
        
        -- Fallback to home directory if enabled and pwd detection failed
        if not pwd and config.fallback_to_home then
            pwd = vim.fn.expand('~')
            debug_log("Using home directory as fallback: " .. pwd)
        end
    end
    
    -- Create the split
    local success, err = pcall(vim.cmd, split_cmd)
    if not success then
        vim.notify("Failed to create split: " .. err, vim.log.levels.ERROR)
        return
    end
    
    -- If we were in a terminal or want to create a new terminal
    if is_terminal or split_cmd:match('term') then
        terminal_close_autocmd()
        
        local term_cmd = create_terminal_cmd(pwd)
        success, err = pcall(vim.cmd, term_cmd)
        
        if not success then
            vim.notify("Failed to create terminal: " .. err, vim.log.levels.ERROR)
            -- Create basic terminal as fallback
            pcall(vim.cmd, 'term')
        end
    end
end

-- Public functions
function M.term_vsplit()
    debug_log("Creating vertical terminal split")
    terminal_split('vsplit')
end

function M.term_hsplit()
    debug_log("Creating horizontal terminal split")
    terminal_split('split')
end



-- Setup function with configuration
function M.setup(opts)
    config = vim.tbl_extend('force', config, opts or {})
    
    -- Create user commands
    vim.api.nvim_create_user_command('Tsplit', M.term_hsplit, { 
        desc = "Create horizontal split with terminal pwd preservation" 
    })
    vim.api.nvim_create_user_command('Tvsplit', M.term_vsplit, { 
        desc = "Create vertical split with terminal pwd preservation" 
    })
end

return M
