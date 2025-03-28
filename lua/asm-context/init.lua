local M = {}

local config = require('asm-context.config')
local default_config = config.defaults

M.setup = function(opts)
    -- Merge user config with defaults
    config.options = vim.tbl_deep_extend('force', default_config, opts or {})
    
    -- Setup autocmd group
    vim.api.nvim_create_augroup("AsmContext", { clear = true })
    
    -- Register autocmds for context display
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter", "WinEnter", "WinScrolled" }, {
        pattern = config.options.filetypes,
        group = "AsmContext",
        callback = M.update_context
    })
    
    -- Add command to toggle plugin
    vim.api.nvim_create_user_command("AsmContextToggle", function()
        config.options.enabled = not config.options.enabled
        if config.options.enabled then
            M.update_context()
        else
            M.clear_context()
        end
    end, {})
end

-- Update the context display
M.update_context = function()
    -- Skip if disabled
    if not config.options.enabled then
        M.clear_context()
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    
    -- Check if current buffer is an assembly file
    local ft = vim.bo[bufnr].filetype
    if not vim.tbl_contains(config.options.ft_list, ft) then
        M.clear_context()
        return
    end
    
    -- Get treesitter parser
    local parser = vim.treesitter.get_parser(bufnr, ft)
    if not parser then return end
    
    local tree = parser:parse()[1]
    if not tree then return end
    
    local root = tree:root()
    
    -- Get the query from our context.scm file
    local query = vim.treesitter.query.get(ft, "context")
    if not query then
        -- Fallback to simple label query if context.scm is missing
        query = vim.treesitter.query.parse(ft, "(label) @context")
    end
    
    -- Get cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor_pos[1] - 1
    
    -- Clear existing context first
    M.clear_context()
    
    -- Find context nodes above cursor
    local context_nodes = {}
    for id, node, metadata in query:iter_captures(root, bufnr, 0, cursor_row) do
        local name = query.captures[id]
        if name == "context" then
            local start_row, _, _, _ = node:range()
            if start_row < cursor_row then
                table.insert(context_nodes, {node = node, row = start_row})
            end
        end
    end
    
    -- Sort by row so closest context comes last
    table.sort(context_nodes, function(a, b) return a.row < b.row end)
    
    -- Limit to max contexts
    local to_show = {}
    for i = math.max(1, #context_nodes - config.options.max_lines + 1), #context_nodes do
        table.insert(to_show, context_nodes[i])
    end
    
    -- Display the contexts
    if #to_show > 0 then
        local win_width = vim.api.nvim_get_option("columns")
        local context_buf = vim.api.nvim_create_buf(false, true)
        
        local context_lines = {}
        for _, item in ipairs(to_show) do
            local start_row, start_col, end_row, end_col = item.node:range()
            local text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
            table.insert(context_lines, table.concat(text, ""))
        end
        
        vim.api.nvim_buf_set_lines(context_buf, 0, -1, false, context_lines)
        vim.api.nvim_buf_set_option(context_buf, "modified", false)
        vim.api.nvim_buf_set_option(context_buf, "modifiable", false)
        
        local win_opts = {
            relative = "editor",
            row = 0,
            col = 0,
            width = win_width,
            height = #context_lines,
            focusable = false,
            style = "minimal",
            border = "none"
        }
        
        vim.b.asm_ctx_win = vim.api.nvim_open_win(context_buf, false, win_opts)
        
        -- Apply highlight
        vim.api.nvim_win_set_option(vim.b.asm_ctx_win, "winhighlight", config.options.winhighlight)
    end
end

-- Clear any existing context windows
M.clear_context = function()
    if vim.b.asm_ctx_win and vim.api.nvim_win_is_valid(vim.b.asm_ctx_win) then
        vim.api.nvim_win_close(vim.b.asm_ctx_win, true)
        vim.b.asm_ctx_win = nil
    end
end

return M