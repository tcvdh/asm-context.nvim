# asm-context.nvim

A lightweight Neovim plugin that shows assembly context (labels, sections, functions) at the top of your editor window as you scroll through assembly files.

## Features

- Shows assembly labels and sections as context when they scroll off screen
- Lightweight implementation using Treesitter queries
- Works with common assembly filetypes
- Minimal configuration needed

## Requirements

- Neovim >= 0.8.0
- Treesitter with assembly parser installed

## Installation

Using packer.nvim:

```lua
use {
    'username/asm-context.nvim',
    requires = {
        'nvim-treesitter/nvim-treesitter',
    },
    config = function()
        require('asm-context').setup()
    end
}
```

Using lazy.vim:

```lua
{
    'username/asm-context.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
    },
    config = function()
        require('asm-context').setup()
    end
}
```

## Configuration

```lua
require('asm-context').setup({
    -- Default configuration
    enabled = true,
    filetypes = { "*.S", "*.s", "*.asm" },
    ft_list = { "asm" },
    max_lines = 3,
    winhighlight = "Normal:AsmContext",
})
```

## Commands

- `:AsmContextToggle` - Toggle the context display on or off

## highlight groups

this plugin uses the `AsmContext` highlight group. You can customize it in your colorscheme

```lua
vim.api.nvim_set_hl(0, "AsmContext", { bg = "#333333", fg = "#ffffff" })
```

## Usage

After creating these files, you can:

1. Install the plugin with your package manager
2. Make sure you have Treesitter with the asm parser installed
3. Setup the plugin in your Neovim config:

```lua
require('asm-context').setup({
    -- Customize settings if needed
})
```
