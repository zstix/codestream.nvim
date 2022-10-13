local comment = require("./comment")
local utils = require("./utils")

local window = {}

local base_window = {
  relative = 'editor',
  anchor = 'NW',
  style = 'minimal',
  zindex = 60,
}

local create_subwindow = function(state, bufnr, opts)
  local win = vim.api.nvim_open_win(bufnr, true, utils.merge_tables(base_window, opts))
  vim.api.nvim_win_set_option(win, "winhl", "NormalFloat:Pmenu")
  table.insert(state.wins, win)
  return win
end

local create_frame_window = function(state, opts)
  local buf = vim.api.nvim_create_buf(false, true)

  local win = create_subwindow(state, buf, {
    width = opts.width,
    height = opts.height,
    col = opts.col,
    row = opts.row,
    zindex = 50,
  })

  local lines = {}

  if opts.title == nil then
    table.insert(lines, '╭' .. string.rep('─', opts.width - 2) .. '╮')
  else
    table.insert(lines, '╭─ ' .. opts.title .. ' ' .. string.rep('─', opts.width - 5 - string.len(opts.title)) .. '╮')
  end

  for i=1,(opts.height - 2) do
    table.insert(lines, '│' .. string.rep(' ', opts.width - 2) .. '│')
  end

  table.insert(lines, '╰' .. string.rep('─', opts.width - 2) .. '╯')

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- TODO: move to own file?
local add_help = function(state, bufnr)
  local help = { "<Leader>g_  c: comment s: comment w/slack", "Comment" }

  vim.api.nvim_buf_set_extmark(bufnr, state.ns, 0, 0, {
    virt_text = { help }
  })
end

function window.create(state, m)
  local ui = vim.api.nvim_list_uis()[1]
  local width = 60
  local height = math.floor(ui.height * 0.9)

  -- frame
  local frame_height = 10 -- TODO: code size or max
  create_frame_window(state, {
    width = width,
    height = frame_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2),
    title = m.file .. ':' .. m.start,
  })

  -- code
  local code_buf = vim.api.nvim_create_buf(false, true)
  local code_height = 8 -- TODO: code size or max

  local code_win = create_subwindow(state, code_buf, {
    width = width - 2,
    height = code_height,
    col = ui.width - width + 1,
    row = (ui.height / 2) - (height / 2) + 1,
  })

  vim.api.nvim_win_set_option(code_win, "winhl", "NormalFloat:Normal")

  local snippet = vim.api.nvim_buf_call(state.bufnr, function()
    return vim.fn.getline(m.start, m.start + 6)
  end)

  vim.api.nvim_buf_set_lines(code_buf, 0, -1, false, snippet)

  -- TODO: better way?
  vim.api.nvim_buf_call(code_buf, function()
    vim.cmd('set ft=lua')
  end)

  -- activity
  local activity_buf = vim.api.nvim_create_buf(false, true)
  local activity_height = height - frame_height

  local activity_win = create_subwindow(state, activity_buf, {
    width = width,
    height = activity_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2) + frame_height,
  })

  vim.api.nvim_win_set_option(activity_win, "scl", "yes:1")
  vim.api.nvim_win_set_option(activity_win, "wrap", true)

  local comment = comment.render(activity_buf, m.activity, width)

  add_help(state, activity_buf)

  return activity_buf
end

return window
