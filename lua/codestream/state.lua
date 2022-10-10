local plugin_key = "codestream"

local state = {
  bufnr = 1,
  ns = vim.api.nvim_create_namespace(plugin_key .. "_ns"),
  augroup = vim.api.nvim_create_augroup(plugin_key .. "_augroup", { clear = true }),
  sign_group = plugin_key .. "_signs",
  wins = {},
  cmarks = {},
}

function state.get_cmark(filename, lnum)
  if filename == nil or lnum == nil then
    filename = vim.fn.expand('%')
    lnum = vim.fn.line('.')
  end

  return state.cmarks[filename .. ':' .. lnum]
end

-- NOTE: for testing
state.cmarks["init.lua:9"] = {
  start = 9,
  finish = 29,
  file = "codestream.lua",
  branch = "develop",
  sha = "bb507c7",
  activity = {
    {
      action = "comment",
      author = {
        -- first_name = "Zack",
        -- last_name = "Stickles",
        username = "zstix",
      },
      date = "2022.10.07:13.20",
      text = "Why are we using snake_case here?",
    },
  },
};

return state
