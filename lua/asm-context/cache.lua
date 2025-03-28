local M = {}

local config = require('asm-context.config')

-- Cache for context nodes
local node_cache = {}
local cache_key = function(bufnr, row)
    return string.format("%d:%d", bufnr, row)
end

M.get_context_nodes = function(bufnr, root, cursor_row)
    local key = cache_key(bufnr, cursor_row)
    
    if node_cache[key] then
        return node_cache[key]
    end
    
    local query = vim.treesitter.query.get(vim.bo[bufnr].filetype, "context")
    if not query then
        query = vim.treesitter.query.parse(vim.bo[bufnr].filetype, "(label) @context")
    end
    
    local context_nodes = {}
    for id, node in query:iter_captures(root, bufnr, 0, cursor_row) do
        local name = query.captures[id]
        if name == "context" then
            local start_row = node:range()
            if start_row < cursor_row then
                table.insert(context_nodes, {node = node, row = start_row})
            end
        end
    end
    
    table.sort(context_nodes, function(a, b) return a.row < b.row end)
    
    -- Limit to max contexts
    if #context_nodes > config.options.max_lines then
        local start_idx = #context_nodes - config.options.max_lines + 1
        context_nodes = vim.list_slice(context_nodes, start_idx)
    end
    
    node_cache[key] = context_nodes
    
    -- Clear cache after a short delay
    vim.defer_fn(function()
        node_cache[key] = nil
    end, 1000)
    
    return context_nodes
end

return M
