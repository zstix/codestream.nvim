local Utils = require('./utils')
local Comment = {}

local function apply_color(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    -- TODO: move colors to settings
    vim.cmd("hi CodeStreamGreen guifg=#1CE783")

    vim.fn.execute("syntax match CodeStreamGreen /╭.\\{3\\}/")
    vim.fn.execute("syntax match CodeStreamGreen /│..│/")
    vim.fn.execute("syntax match CodeStreamGreen /╰.\\{3\\}/")

    -- TODO: better match
    vim.fn.execute("syntax match Comment /\\s[0-9].*/")
  end)
end

local function render_comment(buf, opts, index)
  local a = opts.author
  local date = Utils.parse_date(opts.date)

  local result = {"╭──╮"}
  table.insert(result, "│@" .. string.sub(a.username, 1, 1) .. "│ " .. a.username .. " " .. date)
  table.insert(result, "╰──╯")
  table.insert(result, opts.text)
  table.insert(result, " ")

  if index == 1 then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
  else
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, result)
  end
end

function Comment.render(buf, comments)
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { " " })
  for i, comment in pairs(comments) do
    render_comment(buf, comment, i)
  end

  apply_color(buf)
end

function Comment.add_form(state)
  local Window = require('./window')
  local Help = require('./help')

  local comment_height = 8
  local activity_height = vim.api.nvim_win_get_height(state.wins["activity"])
  -- local width = vim.api.nvim_win_get_config(state.wins["activity"]).height - 6
  local width = vim.api.nvim_win_get_config(state.wins["activity"]).width
  local row = vim.api.nvim_win_get_config(state.wins["activity"]).row[false]
  local col = vim.api.nvim_win_get_config(state.wins["activity"]).col[false]
  local bufnr = vim.api.nvim_win_get_buf(state.wins["input"])

  vim.api.nvim_win_set_height(state.wins["activity"], activity_height - comment_height - 1)

  local config = Utils.merge_tables(vim.api.nvim_win_get_config(state.wins["input"]), {
    height = comment_height + 2,
    row =  row + activity_height - comment_height - 1,
  })

  vim.api.nvim_win_set_config(state.wins["input"], config)

  -- update help
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, Help.get_text(state))

  -- draw frame
  local lines = Utils.get_frame(width, comment_height + 1, "New comment")
  vim.api.nvim_buf_set_lines(bufnr, 1, -1, false, lines)

  -- add input bufnr & window
  local text_buf = vim.api.nvim_create_buf(false, true)
  local text_win = Window.create_subwindow(state, text_buf, "text", {
    width = width - 2,
    height = comment_height - 1,
    col = col + 1,
    row = row + activity_height - comment_height + 1,
  })

  -- window settings
  vim.api.nvim_win_set_option(text_win, "spell", true)
  -- TODO: get this working
  vim.api.nvim_buf_call(text_buf, function()
    vim.cmd('set ft=markdown')
  end)

  -- new commands
  vim.api.nvim_create_user_command("CodeStreamCommentDiscard", function()
    Window.close_all(state)
  end, {})

  vim.api.nvim_create_user_command("CodeStreamCommentSubmit", function()
    Comment.add(state)
  end, {})


  vim.api.nvim_buf_call(text_buf, function()
    local opts = { noremap = true }
    vim.api.nvim_buf_set_keymap(text_buf, 'n', '<Leader>cc', ':CodeStreamCommentSubmit<CR>', opts)
    vim.api.nvim_buf_set_keymap(text_buf, 'n', '<Leader>cd', ':CodeStreamCommentDiscard<CR>', opts)
  end)
end

function Comment.add(state)
  local Help = require('./help')

  -- NOTE: do this more often rather than passing in bufnr args
  local text_buf = vim.api.nvim_win_get_buf(state.wins["text"])
  local activity_buf = vim.api.nvim_win_get_buf(state.wins["activity"])

  local text = ""
  vim.api.nvim_buf_call(text_buf, function()
    -- TODO: comments with multiple lines
    -- text = vim.join(vim.fn.getline(1, '$'), "\n")
    text = vim.fn.getline(1)
  end)

  local comment = {
    action = "comment",
    author = {
      username = "zstix" -- TODO: determine user
    },
    date = "2022.10.07:13.20", -- TODO: determine
    text = text,
  }

  table.insert(state.cmarks[state.active_cmark].activity, comment)

  -- NOTE: non-1 value: feels hacky, bro
  render_comment(activity_buf, comment, 2)

  -- TODO: add comment to state

  local comment_height = 8
  local activity_height = vim.api.nvim_win_get_height(state.wins["activity"]) + comment_height

  vim.api.nvim_win_set_height(state.wins["activity"], activity_height + 1)

  local row = vim.api.nvim_win_get_config(state.wins["activity"]).row[false]
  local config = Utils.merge_tables(vim.api.nvim_win_get_config(state.wins["input"]), {
    height = 1,
    row =  row + activity_height + 1,
  })
  vim.api.nvim_win_set_config(state.wins["input"], config)

  local text_win = state.wins["text"]
  state.wins["text"] = nil
  vim.api.nvim_win_close(text_win, false)

  state.help_state = "init"
  -- update help
  -- TODO: DRY this up
  local input_buf = vim.api.nvim_win_get_buf(state.wins["input"])
  vim.api.nvim_buf_set_lines(input_buf, 0, 0, false, Help.get_text(state))
  -- TODO: fix colors (should be Comment highlight group)
end

return Comment
