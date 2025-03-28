local M = {}

local config = require('asm-context.config')

M.clear = function()
    if vim.b.asm_ctx_win and vim.api.nvim_win_is_valid(vim.b.asm_ctx_win) then
        vim.api.nvim_win_close(vim.b.asm_ctx_win, true)
        vim.b.asm_ctx_win = nil
    end
end

M.show = function(bufnr, context_nodes, cursor_row)
    local win_width = vim.api.nvim_get_option("columns")
    local context_buf = vim.api.nvim_create_buf(false, true)
    
    local context_lines = {}
    for _, item in ipairs(context_nodes) do
        local text = vim.api.nvim_buf_get_lines(bufnr, item.row, item.row + 1, false)
        if text and text[1] then
            table.insert(context_lines, text[1])
        end
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
    vim.api.nvim_win_set_option(vim.b.asm_ctx_win, "winhighlight", config.options.winhighlight)
end

return M
