local M = {}

---@type table
local remembuf = {}

--- This function filters out invalid windows for this plugin's context
--- Invalid windows include non-focusable windows created by plugins like `nvim-treesitter-context`
---@param windows integer[]
---@return integer[]
local function get_valid_windows(windows)
  ---@type integer[]
  local valid_windows = {}

  for _, id in ipairs(windows) do
    ---@type vim.api.keyset.win_config
    local config = vim.api.nvim_win_get_config(id)
    if config.focusable == true then
      table.insert(valid_windows, id)
    end
  end

  return valid_windows
end

---@param windows integer[]
local function save_sizes(windows)
  ---@type table, table
  local keys, values = {}, {}

  for _, id in ipairs(windows) do
    table.insert(keys, id)
    table.insert(values, vim.fn.winwidth(id))
    table.insert(values, vim.fn.winheight(id))
  end

  ---@type string
  local key = table.concat(keys, "|")

  remembuf[key] = values
end

local function restore_sizes(windows)
  ---@type table
  local keys = {}

  for _, id in ipairs(windows) do
    table.insert(keys, id)
  end

  ---@type string
  local key = table.concat(keys, "|")

  ---@type table
  local vals = remembuf[key]
  if vals ~= nil then
    for i = 1, #vals / 2 do
      vim.api.nvim_win_set_width(keys[i], vals[i * 2 - 1])
      vim.api.nvim_win_set_height(keys[i], vals[i * 2])
    end
  end
end

---@class RemembufIntegrations
--- Enable integrations with `nvim-tree` plugin.
--- If enabled, the plugin will auto save the sizes before the nvim-tree window opens;
--- and will restore the sizes after it closes. [default = false]
---@field nvim_tree boolean

---@class RemembufOpts
--- Silence messages; except errors [default = true]
---@field silent boolean
---@field integrations RemembufIntegrations

--- @param opts RemembufOpts
function M.setup(opts)
  opts = {
    silent = opts.silent == nil and true or opts.silent,
    integrations = opts.integrations or {
      nvim_tree = false,
    },
  }

  local save_sizes_wrap = function()
    save_sizes(get_valid_windows(vim.api.nvim_tabpage_list_wins(0)))
    if not opts.silent then
      print("Saved sizes!")
    end
  end

  local restore_sizes_wrap = function()
    restore_sizes(get_valid_windows(vim.api.nvim_tabpage_list_wins(0)))
    if not opts.silent then
      print("Restored sizes!")
    end
  end

  vim.api.nvim_create_user_command("SaveSizes", save_sizes_wrap, {})
  vim.api.nvim_create_user_command("RestoreSizes", restore_sizes_wrap, {})

  if opts.integrations.nvim_tree == true then
    local ok, api = pcall(require, "nvim-tree.api")
    if not ok then
      print("Failed to require `nvim-tree.api`. `nvim-tree` plugin is likely not installed.")
    else
      local Event = api.events.Event

      api.events.subscribe(Event.TreePreOpen, save_sizes_wrap)
      api.events.subscribe(Event.TreeClose, restore_sizes_wrap)
    end
  end
end

return M
