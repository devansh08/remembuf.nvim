# remembuf.nvim

Simple plugin to remember the sizes splits/windows layouts in a tab page and restore them.
This should help avoid resetting of split sizes when new/existing splits are opened/closed (e.g.: Opening nvim-tree etc.).

## Installation

Install using your favorite package manager, like any other plugin.

For example, with `lazy.nvim`:
```lua
{
  "devansh08/remembuf.nvim",
  branch = "main",
  opts = {
    silent = true, -- Silences messages; except errors [default = true]
    integrations = {
      nvim_tree = true, -- Enable nvim-tree integrations. If enabled, the plugin will auto save the sizes before the nvim-tree window opens; and will restore the sizes after it closes. [default = false]
    },
  },
}
```

## Usage

The plugin provides two commands `:SaveSizes` & `:RestoreSizes` to save & restore the sizes of the splits/windows in the current tab page, respectively.

## Integration
### [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)

Enabling this integration sets up auto saving *before* the nvim-tree window opens and auto restoring the previous layout *after* it closes.

*Note*: This requires the `TreePreOpen` event of `nvim-tree`, added in this PR: [#3105](https://github.com/nvim-tree/nvim-tree.lua/pull/3105)
