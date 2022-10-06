local comment = require("comment")

local plugin_key = "codestream"

local bufnr = 1

-- TODO: function for getting key
local cmarks = {
  ["codestream.lua:8"] = {
    id = 123,
    start = 8,
    finish = 29,
    file = "sample.ts",
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

local create_window = function()
  local buf = vim.api.nvim_create_buf(false, true)

  local ui = vim.api.nvim_list_uis()[1]
  local width = 60
  local height = math.floor(ui.height * 0.9)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = ui.width - width,
    row = (ui.height / 2) - (height / 2),
    anchor = 'NW',
    style = 'minimal',
  })

  return buf
end

vim.api.nvim_create_user_command("CodeStream", function(args)
  -- print("args", vim.inspect(args))

  -- TODO: check if theres a mark on this line first
  -- if args.range ~= 0 then
  --   create_sign(bufnr, args.line1)
  -- end


  local key = vim.fn.expand('%') .. ':' .. args.line1
  local m = cmarks[key]

  if m == nil then return end

  local buf = create_window()
  local comment = comment.render(buf, m.activity[1])

  -- comment.render(cmarks["codestream.lua:6"].activity[1])

  -- print(vim.inspect(m))

  -- TODO: open a floating buffer?
end, { range = true })

for _, m in pairs(cmarks) do
  create_sign(bufnr, m.start)
end
