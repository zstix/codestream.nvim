local plugin_key = "codestream"

local bufnr = 1

-- TODO: function for getting key
local cmarks = {
  ["sample.ts:3"] = {
    id = 123,
    start = 3,
    finish = 8,
    file = "sample.ts",
    branch = "develop",
    sha = "bb507c7", -- taken from vi
    activity = {
      {
        action = "comment",
        author = "zstix",
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

local get_cmark = function(lnum)
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

  print(vim.inspect(m))
  -- TODO: open a floating buffer?
end, { range = true })

for _, m in pairs(cmarks) do
  create_sign(bufnr, m.start)
end
