local M = {}

local config = require('asm-context.config')
local window = require('asm-context.window')
local context = require('asm-context.context')

-- Store args and handle them properly in throttled function
local function throttle(fn, ms)
    local timer = nil
    local scheduled = false
    local stored_args = nil
    
    return function(...)
        stored_args = {...}
        
        if timer then
            scheduled = true
            return
        end
        
        fn(unpack(stored_args))
        timer = vim.loop.new_timer()
        timer:start(ms, 0, function()
            timer:close()
            timer = nil
            if scheduled then
                scheduled = false
                vim.schedule(function() 
                    fn(unpack(stored_args)) 
                end)
            end
        end)
    end
end

M.setup = function(opts)
    config.options = vim.tbl_deep_extend('force', config.defaults, opts or {})
    
    vim.api.nvim_create_augroup("AsmContext", { clear = true })
    
    -- Throttle update_context to run at most every 100ms
    local throttled_update = throttle(context.update, 100)
    
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter", "WinEnter", "WinScrolled" }, {
        pattern = config.options.filetypes,
        group = "AsmContext",
        callback = throttled_update
    })
    
    vim.api.nvim_create_user_command("AsmContextToggle", function()
        config.options.enabled = not config.options.enabled
        if config.options.enabled then
            context.update()
        else
            window.clear()
        end
    end, {})
end

return M