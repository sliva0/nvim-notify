local base = require("notify.render.base")

return function(bufnr, notif, highlights)
  local namespace = base.namespace()
  local icon = notif.icon
  local title = notif.title[1]
  local message = notif.message[1]

  local title_present = type(title) == "string" and #title > 0

  vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
    virt_text = {
      { icon .. " ", highlights.icon },
      { "|", highlights.border },
      {
        (title_present and " " or "") .. title,
        highlights.title,
      },
      {
        (title_present and ":" or "") .. " " .. message,
        highlights.body,
      },
    },
    priority = 50,
  })
end
