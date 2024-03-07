# Neovim Smart Terminal Tplit

## Features

-   **Automatic Terminal Buffer Closure**: Automatically closes terminal
    buffers upon exit, keeping the workspace clean. Will become unnecessary in future releases of Neovim.
-   **Context Preservation**: For Unix/Linux users, terminals opened
    through splits will automatically navigate to the working directory
    of the current buffer, ensuring a seamless workflow.

## Installation

To install this plugin using
[lazy.nvim](https://github.com/kdheepak/lazy.nvim), add the following
configuration to your Neovim setup:

```lua
require("lazy").setup({
    {
        'jam1015/neovim-smart-terminal',
        config = function()
            require('neovim-smart-terminal').setup()
        end
    }
})
```

## Usage

After installation, the plugin provides two new commands within Neovim
to manage terminal splits:

-   `:Tsplit` - Opens a new terminal in a horizontal split.
-   `:Tvsplit` - Opens a new terminal in a vertical split.

Additionally, you can bind keyboard shortcuts to these actions for even
quicker access:


## Configuration

```lua
local opts = { remap = false, silent = true }
local keymap = vim.keymap.set
keymap("n", "<C-a>s", require('neovim-smart-terminal').term_hsplit, opts)
keymap("t", "<C-a>s", require('neovim-smart-terminal').term_hsplit, opts)
keymap("n", "<C-a>v", require('neovim-smart-terminal').term_vsplit, opts)
keymap("t", "<C-a>v", require('neovim-smart-terminal').term_vsplit, opts)
```


### Other helpful Configuration

```lua
local keymap = vim.keymap.set

-- generally easier prefix for window related commands
keymap("n", "<C-a>", "<C-w>", { remap = true, silent = true })

-- switches windows from terminal mode. <C-\><C-n> goes to normal mode from terminal mode
keymap("t", "<C-a>", "<C-\\><C-n><C-a>", { remap = true, silent = true })

-- to do splits from terminal mode without using this plugin
keymap("t", "<C-w>", "<C-\\><C-n><C-w>", { remap = true, silent = true })
```

## License

This project is licensed under the GNU General Public License v3.0. For
more information, see the LICENSE file in the repository.
