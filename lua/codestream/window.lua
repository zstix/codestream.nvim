local comment = require("./comment")
local utils = require("./utils")
local help = require("./help")

local window = {}

local base_window = {
  relative = 'editor',
  anchor = 'NW',
  style = 'minimal',
  zindex = 60,
}

function window.create_subwindow(state, bufnr, label, opts)
-- local create_subwindow = function(state, bufnr, label, opts)
  local win = vim.api.nvim_open_win(bufnr, true, utils.merge_tables(base_window, opts))
  vim.api.nvim_win_set_option(win, "winhl", "NormalFloat:Pmenu")
  state.wins[label] = win
  return win
end

local create_frame_window = function(state, opts)
  local buf = vim.api.nvim_create_buf(false, true)

  local win = window.create_subwindow(state, buf, "frame", {
    width = opts.width,
    height = opts.height,
    col = opts.col,
    row = opts.row,
    zindex = 50,
  })

  local lines = utils.get_frame(opts.width, opts.height, opts.title)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

function window.create(state, m)
  local ui = vim.api.nvim_list_uis()[1]
  local width = 60
  local height = math.floor(ui.height * 0.9)
  local input_height = 1
  local frame_height = 10 -- TODO: code size or max
  local code_height = 8 -- TODO: code size or max
  local activity_height = height - frame_height - input_height

  -- frame
  create_frame_window(state, {
    width = width,
    height = frame_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2),
    title = m.file .. ':' .. m.start,
  })

  -- code
  local code_buf = vim.api.nvim_create_buf(false, true)

  local code_win = window.create_subwindow(state, code_buf, "code", {
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

  -- help
  local input_buf = vim.api.nvim_create_buf(false, true)

  local input_win = window.create_subwindow(state, input_buf, "input", {
    width = width,
    height =input_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2) + frame_height + activity_height,
  })

  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, help.get_text(state))
  vim.api.nvim_buf_call(input_buf, function()
    vim.fn.execute("syntax match Comment /\\%1l.*/")
  end)

  -- activity
  local activity_buf = vim.api.nvim_create_buf(false, true)

  local activity_win = window.create_subwindow(state, activity_buf, "activity", {
    width = width,
    height = activity_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2) + frame_height,
  })

  vim.api.nvim_win_set_option(activity_win, "scl", "yes:1")
  vim.api.nvim_win_set_option(activity_win, "wrap", true)

  local comment = comment.render(activity_buf, m.activity, width)

  return activity_buf
end

function window.close_all(state)
  for key, _ in pairs(state.wins) do
    vim.api.nvim_win_close(state.wins[key], false)
  end
  state.wins = {}
end

return window
