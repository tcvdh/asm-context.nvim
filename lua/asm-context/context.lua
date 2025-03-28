local M = {}

local config = require('asm-context.config')
local window = require('asm-context.window')
local cache = require('asm-context.cache')

M.update = function()
    if not config.options.enabled then
        window.clear()
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    
    if not vim.tbl_contains(config.options.ft_list, ft) then
        window.clear()
        return
    end

    local parser = vim.treesitter.get_parser(bufnr, ft)
    if not parser then return end
    
    local tree = parser:parse()[1]
    if not tree then return end
    
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor_pos[1] - 1

    window.clear()
    
    local context_nodes = cache.get_context_nodes(bufnr, tree:root(), cursor_row)
    
    if #context_nodes > 0 then
        window.show(bufnr, context_nodes, cursor_row)
    end
end

return M
