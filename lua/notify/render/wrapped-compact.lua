-- alternative compact renderer for nvim-notify.
-- Wraps text and adds some padding (only really to the left, since padding to
-- the right is somehow not display correctly).
-- Modified version of https://github.com/rcarriga/nvim-notify/blob/master/lua/notify/render/compact.lua
--------------------------------------------------------------------------------

---@param line string
---@param width number
---@return string[]
local function split_length(line, width)
  local text = {}
  local next_line
  while true do
    if #line == 0 then
      return text
    end
    next_line, line = line:sub(1, width), line:sub(width + 1)
    text[#text + 1] = next_line
  end
end

---@param lines string[]
---@param max_width number
---@return string[]
local function custom_wrap(lines, max_width)
  local wrapped_lines = {}
  for _, line in pairs(lines) do
    local new_lines = split_length(line, max_width)
    for _, nl in ipairs(new_lines) do
      nl = nl:gsub("^%s*", " "):gsub("%s*$", " ") -- ensure padding
      table.insert(wrapped_lines, nl)
    end
  end
  return wrapped_lines
end

---@param bufnr number
---@param notif object
---@param highlights object
---@param config object plugin config_obj
return function(bufnr, notif, highlights, config)
  local namespace = require("notify.render.base").namespace()
  local icon = notif.icon
  local title = notif.title[1]
  local message = notif.message

  local default_titles = { "Error", "Warning", "Notify" }
  local has_title = type(title) == "string"
    and #title > 0
    and not vim.tbl_contains(default_titles, title)

  if not has_title then
    -- no title = inline the icon
    message[1] = string.format("%s %s", icon, message[1])
  end
  -- has title = icon + title as header row

  message = custom_wrap(notif.message, config.max_width() or 80)

  vim.api.nvim_buf_set_lines(bufnr, has_title and 1 or 0, -1, false, message)

  vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
    hl_group = highlights.body,
    end_line = #message,
  })
  vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
    virt_text = {
      { " " },
      { icon, highlights.icon },
      { " " },
      { title, highlights.title },
    },
    virt_text_pos = "overlay",
  })
end
