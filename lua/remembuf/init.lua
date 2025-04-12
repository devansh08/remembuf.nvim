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

---@class RemembufOpts
---@field silent boolean Silence messages; except errors [default = true]

--- @param opts RemembufOpts
function M.setup(opts)
  opts = {
    silent = opts.silent or true,
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
  end
end

return M
