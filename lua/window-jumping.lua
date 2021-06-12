local api = vim.api
local M = {}

function M.clear_prompt()
  api.nvim_command('normal :esc<CR>')
end

function M.get_user_input_char()
  local c = vim.fn.getchar()
  while type(c) ~= "number" do
    c = vim.fn.getchar()
  end
  return vim.fn.nr2char(c)
end

function M.pick_window()
  local tabpage = api.nvim_get_current_tabpage()
  local win_ids = api.nvim_tabpage_list_wins(tabpage)

  local selectable = vim.tbl_filter(function (id)
    local current_win = vim.api.nvim_get_current_win()
    if current_win == id then
      return false
    end
    local win_config = api.nvim_win_get_config(id)
    return win_config.focusable
  end, win_ids)

  -- If there are no selectable windows: return. If there's only 1, return it without picking.
  if #selectable == 0 then return -1 end
  if #selectable == 1 then return selectable[1] end

  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

  local i = 1
  local win_opts = {}
  local win_map = {}
  local laststatus = vim.o.laststatus
  vim.o.laststatus = 2

  -- Setup UI
  for _, id in ipairs(selectable) do
    local char = chars:sub(i, i)
    local ok_status, statusline = pcall(api.nvim_win_get_option, id, "statusline")
    local ok_hl, winhl = pcall(api.nvim_win_get_option, id, "winhl")

    win_opts[id] = {
      statusline = ok_status and statusline or "",
      winhl = ok_hl and winhl or ""
    }
    win_map[char] = id

    api.nvim_win_set_option(id, "statusline", "%=" .. char .. "%=")
    api.nvim_win_set_option(
      id, "winhl", "StatusLine:WindowJumping,StatusLineNC:WindowJumping"
    )

    i = i + 1
    if i > #chars then break end
  end

  vim.cmd("redraw")
  print("Jump to : ")
  local _, resp = pcall(M.get_user_input_char)
  resp = (resp or ""):upper()
  M.clear_prompt()

  -- Restore window options
  for _, id in ipairs(selectable) do
    for opt, value in pairs(win_opts[id]) do
      api.nvim_win_set_option(id, opt, value)
    end
  end

  vim.o.laststatus = laststatus

  return win_map[resp]
end

function M.window_jumping()
  local tabpage = api.nvim_get_current_tabpage()
  local win_ids = api.nvim_tabpage_list_wins(tabpage)

  local target_winid = M.pick_window()

  if target_winid == -1 or target_winid == nil then
    return
  end

  api.nvim_set_current_win(target_winid)
end

return M
