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
        date = "date_goes_here", -- TODO
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

local create_window = function(title)
  local ui = vim.api.nvim_list_uis()[1]
  local width = 60
  local height = math.floor(ui.height * 0.9)

  -- code
  local code_buf = vim.api.nvim_create_buf(false, true)
  local code_height = 10 -- TODO: code size or max

  vim.api.nvim_open_win(code_buf, true, {
    relative = 'editor',
    width = width,
    height = code_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2),
    anchor = 'NW',
    style = 'minimal',
  })
  -- TODO: abstract?
  local lines = { '╭─ ' .. title .. ' ' .. string.rep('─', width - 5 - string.len(title)) .. '╮' }
  local empty_line = '│' .. string.rep(' ', width - 2) .. '│'
  for i=1,(code_height - 2) do
    table.insert(lines, empty_line)
  end
  table.insert(lines, '╰' .. string.rep('─', width - 2) .. '╯')

  vim.api.nvim_buf_set_lines(code_buf, 0, -1, false, lines)

  -- activity
  local activity_buf = vim.api.nvim_create_buf(false, true)
  local activity_height = height - code_height

  vim.api.nvim_open_win(activity_buf, true, {
    relative = 'editor',
    width = width,
    height = activity_height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2) + code_height,
    anchor = 'NW',
    style = 'minimal',
  })

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

  local buf = create_window(m.file .. ':' .. m.start)
  local comment = comment.render(buf, m.activity[1])

  -- comment.render(cmarks["codestream.lua:6"].activity[1])

  -- print(vim.inspect(m))

  -- TODO: open a floating buffer?
end, { range = true })

for _, m in pairs(cmarks) do
  create_sign(bufnr, m.start)
end
