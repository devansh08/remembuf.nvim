local M = {}

---@type table
M.remembuf = {}

---@param windows integer[]
function M.save_sizes(windows)
  ---@type table, table
  local keys, values = {}, {}

  for _, id in ipairs(windows) do
    table.insert(keys, id)
    table.insert(values, vim.fn.winwidth(id))
    table.insert(values, vim.fn.winheight(id))
  end

  ---@type string
  local key = table.concat(keys, "|")

  M.remembuf[key] = values
end

function M.restore_sizes(windows)
  ---@type table
  local keys = {}

  for _, id in ipairs(windows) do
    table.insert(keys, id)
  end

  ---@type string
  local key = table.concat(keys, "|")

  ---@type table
  local vals = M.remembuf[key]
  if vals ~= nil then
    for i = 1, #vals / 2 do
      vim.api.nvim_win_set_width(keys[i], vals[i * 2 - 1])
      vim.api.nvim_win_set_height(keys[i], vals[i * 2])
    end
  end
end

---@class RemembufIntegrations
---@field nvim_tree boolean Enable nvim-tree integrations. If enabled, the plugin will auto save the sizes before the nvim-tree window opens; and will restore the sizes after it closes. [default = false]

---@class RemembufOpts
---@field silent boolean Silence messages; except errors [default = true]
---@field integrations RemembufIntegrations

--- @param opts RemembufOpts
function M.setup(opts)
  opts = {
    silent = opts.silent == nil and true or opts.silent,
    integrations = opts.integrations or {
      nvim_tree = false,
    },
  }

  local save_sizes = function()
    M.save_sizes(vim.api.nvim_tabpage_list_wins(0))
    if not opts.silent then
      print("Saved sizes!")
    end
  end

  local restore_sizes = function()
    M.restore_sizes(vim.api.nvim_tabpage_list_wins(0))
    if not opts.silent then
      print("Restored sizes!")
    end
  end

  vim.api.nvim_create_user_command("SaveSizes", save_sizes, {})
  vim.api.nvim_create_user_command("RestoreSizes", restore_sizes, {})

  if opts.integrations.nvim_tree == true then
    local ok, api = pcall(require, "nvim-tree.api")
    if not ok then
      print("Failed to require `nvim-tree.api`. `nvim-tree` plugin is likely not installed.")
    else
      local Event = api.events.Event

      api.events.subscribe(Event.TreePreOpen, save_sizes)
      api.events.subscribe(Event.TreeClose, restore_sizes)
    end
  end
end

return M
