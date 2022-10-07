local comment = require("comment")

local plugin_key = "codestream"
local ns = vim.api.nvim_create_namespace(plugin_key .. "_ns")
local bufnr = 1

-- TODO: function for getting key
local cmarks = {
  ["codestream.lua:8"] = {
    id = 123,
    start = 8,
    finish = 29,
    file = "codestream.lua",
    branch = "develop",
    sha = "bb507c7", -- taken from vi
    activity = {
      {
        action = "comment",
        author = {
          first_name = "Zack",
          last_name = "Stickles",
          username = "zstix",
        },
        date = "2022.10.07", -- TODO: time
        text = "Why are we using snake_case here?",
      },
    },
  },
}

-- add cmark identifier in gutter
-- TODO: better abstract / cache
local create_sign = function(bufnr, lnum)
  local group_name = plugin_key .. "_signs"
  local sign_name = plugin_key .. "_sign_" .. lnum

  vim.fn.sign_define(sign_name, {
    text = "<>",
    texthl = "Comment",
  })

  vim.fn.sign_place(
    lnum,
    group_name,
    sign_name,
    bufnr,
    { lnum = lnum }
  )
end

local create_window = function(m)
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

  -- TODO: actual file buffer, not this other stuff?
  local snippet = vim.api.nvim_buf_call(bufnr, function()
    return vim.fn.getline(8, 15)
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
  vim.api.nvim_win_set_option(activity_win, "winhl", "NormalFloat:Pmenu")
  vim.api.nvim_win_set_option(activity_win, "scl", "yes:1")

  local comment = comment.render(activity_buf, m.activity[1], width)

  return activity_buf
end

vim.api.nvim_create_user_command("CodeStream", function(args)
  -- print("args", vim.inspect(args))

  -- TODO: check if theres a mark on this line first
  -- if args.range ~= 0 then
  --   create_sign(bufnr, args.line1)
  -- end


  local key = vim.fn.expand('%') .. ':8'
  -- local key = vim.fn.expand('%') .. ':' .. args.line1
  local m = cmarks[key]

  if m == nil then return end

  create_window(m) --m.file .. ':' .. m.start)

  -- comment.render(cmarks["codestream.lua:6"].activity[1])

  -- print(vim.inspect(m))

  -- TODO: open a floating buffer?
end, { range = true })

for _, m in pairs(cmarks) do
  create_sign(bufnr, m.start)
end
