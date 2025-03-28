local M = {}

M.defaults = {
    enabled = true,
    filetypes = { "*.S", "*.s", "*.asm" },
    ft_list = { "asm" },
    max_lines = 3,
    winhighlight = "Normal:AsmContext",
}

-- Will be populated in setup
M.options = {}

return M