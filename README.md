# Neovim Smart Terminal Split

A Neovim plugin that enhances terminal splitting functionality with intelligent working directory preservation and automatic buffer management. Streamline your terminal workflow with context-aware splits that maintain your current working environment.

## Features

- **Smart Directory Preservation**: When splitting from a terminal buffer, automatically preserves the current working directory in the new terminal session
- **Cross-Platform Compatibility**: Works on Unix/Linux systems with multiple fallback methods for directory detection
- **Automatic Buffer Cleanup**: Automatically closes terminal buffers when processes exit, keeping your workspace organized (will become unnecessary in future Neovim releases)
- **Multiple Split Options**: Support for horizontal splits, vertical splits, and new tab creation
- **Robust Error Handling**: Graceful fallback behavior when directory detection fails
- **Configurable Behavior**: Customizable options for shell, cleanup behavior, and debugging

## Installation

### Using lazy.nvim

Add the following configuration to your Neovim setup:

```lua
require("lazy").setup({
    {
        'jam1015/nvim_smart_termsplit',
        config = function()
            require('nvim_smart_termsplit').setup()
        end
    }
})
```

### Using packer.nvim

```lua
use {
    'jam1015/nvim_smart_termsplit',
    config = function()
        require('nvim_smart_termsplit').setup()
    end
}
```

### Using vim-plug

```vim
Plug 'jam1015/nvim_smart_termsplit'

lua require('nvim_smart_termsplit').setup()
```

## Usage

The plugin provides three commands for creating terminal splits:

| Command | Description | Behavior |
|---------|-------------|----------|
| `:Tsplit` | Horizontal terminal split | Creates a horizontal split with a new terminal |
| `:Tvsplit` | Vertical terminal split | Creates a vertical split with a new terminal |
| `:Ttabnew` | Terminal in new tab | Opens a new tab with a terminal |

> **Smart Context Detection:** When executed from within a terminal buffer, these commands automatically detect and preserve the current working directory in the new terminal session.

## Configuration

### Basic Setup

```lua
require('nvim_smart_termsplit').setup()
```

### Advanced Configuration

```lua
require('nvim_smart_termsplit').setup({
    shell = '/bin/zsh',           -- Custom shell (auto-detected if nil)
    enable_cleanup = true,        -- Auto-close terminal buffers on exit
    fallback_to_home = true,      -- Use home directory if pwd detection fails
    debug = false,                -- Enable debug logging
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `shell` | string\|nil | `nil` | Custom shell command (auto-detected from `$SHELL` if nil) |
| `enable_cleanup` | boolean | `true` | Automatically close terminal buffers when processes exit |
| `fallback_to_home` | boolean | `true` | Use home directory if working directory detection fails |
| `debug` | boolean | `false` | Enable debug logging for troubleshooting |

### Recommended Keymaps

For quick access to terminal splitting functionality:

```lua
local opts = { remap = false, silent = true }
local keymap = vim.keymap.set

-- Normal and terminal mode bindings
keymap("n", "<C-a>s", require('nvim_smart_termsplit').term_hsplit, opts)
keymap("t", "<C-a>s", require('nvim_smart_termsplit').term_hsplit, opts)
keymap("n", "<C-a>v", require('nvim_smart_termsplit').term_vsplit, opts)
keymap("t", "<C-a>v", require('nvim_smart_termsplit').term_vsplit, opts)
keymap("n", "<C-a>t", require('nvim_smart_termsplit').term_tabnew, opts)
keymap("t", "<C-a>t", require('nvim_smart_termsplit').term_tabnew, opts)

-- Fallback to built-in window commands if needed
keymap("n", "<C-w><C-v>", "<C-w>v", opts)
keymap("t", "<C-w><C-v>", "<C-\\><C-n><C-w>v", opts)
keymap("n", "<C-w><C-t>", "<C-w>T", opts)
keymap("t", "<C-w><C-t>", "<C-\\><C-n><C-w>T", opts)
```

### Additional Helpful Configuration

These mappings can enhance your overall terminal workflow:

```lua
local keymap = vim.keymap.set

-- Use Ctrl-a as a window command prefix (easier than Ctrl-w)
keymap("n", "<C-a>", "<C-w>", { remap = true, silent = true })

-- Switch windows from terminal mode
keymap("t", "<C-a>", "<C-\\><C-n><C-a>", { remap = true, silent = true })

-- Access window commands from terminal mode
keymap("t", "<C-w>", "<C-\\><C-n><C-w>", { remap = true, silent = true })
```

> **Note:** Using `remap = true` allows these mappings to act as prefixes for other window-related commands.

## How It Works

The plugin uses multiple methods to detect the working directory of terminal processes:

1. **procfs**: Reads from `/proc/[pid]/cwd` (primary method)
2. **lsof**: Uses `lsof` to find current working directory
3. **pwdx**: Falls back to `pwdx` command

When any of these methods successfully detects the working directory, the new terminal session automatically starts in that location, maintaining your workflow context.

## Troubleshooting

### Enable Debug Mode

If you encounter issues, enable debug logging:

```lua
require('nvim_smart_termsplit').setup({
    debug = true
})
```

### Common Issues

- **Directory detection fails**: The plugin will fall back to your home directory if `fallback_to_home` is enabled
- **Windows compatibility**: Currently optimized for Unix/Linux systems; Windows support is limited
- **Permission issues**: Some systems may restrict access to `/proc` filesystem

## Requirements

- Neovim 0.7+
- Unix/Linux system (for full functionality)
- Standard Unix utilities (`readlink`, `lsof`, or `pwdx`)

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests to improve the plugin.

## License

This project is licensed under the GNU General Public License v3.0. For more information, see the LICENSE file in the repository.
