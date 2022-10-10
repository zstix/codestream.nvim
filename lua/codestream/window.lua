local comment = require("./comment")

local window = {}

function window.create(state, m)
  local ui = vim.api.nvim_list_uis()[1]
  local width = 60
  local height = math.floor(ui.height * 0.9)
  local title = m.file .. ':' .. m.start

  -- frame
  local frame_buf = vim.api.nvim_create_buf(false, true)
  local frame_height = 10 -- TODO: code size or max

  local frame_win = vim.api.nvim_open_win(frame_buf, true, {
    relative = 'editor',
    width = width,
    height = frame_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2),
    anchor = 'NW',
    style = 'minimal',
    zindex = 50,
  })

  table.insert(state.wins, frame_win)

  -- TODO: abstract?
  local lines = { '╭─ ' .. title .. ' ' .. string.rep('─', width - 5 - string.len(title)) .. '╮' }
  local empty_line = '│' .. string.rep(' ', width - 2) .. '│'
  for i=1,(frame_height - 2) do
    table.insert(lines, empty_line)
  end
  table.insert(lines, '╰' .. string.rep('─', width - 2) .. '╯')

  vim.api.nvim_buf_set_lines(frame_buf, 0, -1, false, lines)
  vim.api.nvim_win_set_option(frame_win, "winhl", "NormalFloat:Pmenu")

  -- code
  local code_buf = vim.api.nvim_create_buf(false, true)
  local code_height = 8 -- TODO: code size or max
  local code_win = vim.api.nvim_open_win(code_buf, true, {
    relative = 'editor',
    width = width - 2,
    height = code_height,
    col = ui.width - width + 1,
    row = (ui.height / 2) - (height / 2) + 1,
    anchor = 'NW',
    style = 'minimal',
    zindex = 60,
  })
  table.insert(state.wins, code_win)

  -- TODO: actual file buffer, not this other stuff?
  local snippet = vim.api.nvim_buf_call(state.bufnr, function()
    return vim.fn.getline(m.start, m.start + 6)
  end)

  vim.api.nvim_buf_set_lines(code_buf, 0, -1, false, snippet)
  vim.api.nvim_win_set_option(code_win, "winhl", "NormalFloat:Normal")

  -- TODO: better way?
  vim.api.nvim_buf_call(code_buf, function()
    vim.cmd('set ft=lua')
  end)

  -- activity
  local activity_buf = vim.api.nvim_create_buf(false, true)
  local activity_height = height - frame_height

  local activity_win = vim.api.nvim_open_win(activity_buf, true, {
    relative = 'editor',
    width = width,
    height = activity_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2) + frame_height,
    anchor = 'NW',
    style = 'minimal',
  })

  table.insert(state.wins, activity_win)

  vim.api.nvim_win_set_option(activity_win, "winhl", "NormalFloat:Pmenu")
  vim.api.nvim_win_set_option(activity_win, "scl", "yes:1")

  local comment = comment.render(activity_buf, m.activity[1], width)

  return activity_buf
end

local setup_autocmds = function(state)
  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.augroup,
    pattern = "*", -- TODO: current buffer?
    callback = function(data)
      local is_cs_win = false
      for _, win in ipairs(state.wins) do
        if tonumber(data.file) == win then
          is_cs_win = true
          break
        end
      end
      if is_cs_win then
        for _, win in ipairs(state.wins) do
          vim.api.nvim_win_close(win, false)
        end
        state.wins = {}
      end
    end,
  })
end

return window
