local plugin_key = "codestream"

-- NOTE: lowercase since this is a singleton
local state = {
  bufnr = 1,
  ns = vim.api.nvim_create_namespace(plugin_key .. "_ns"),
  augroup = vim.api.nvim_create_augroup(plugin_key .. "_augroup", { clear = true }),
  sign_num = 1,
  sign_group = plugin_key .. "_signs",
  help_state = "init",
  wins = {},
  cmarks = {},
  active_cmark = nil,
}

-- NOTE: for testing
state.cmarks["init.lua:6"] = {
  start = 6,
  finish = 29,
  file = "codestream.lua",
  branch = "develop",
  sha = "bb507c7",
  activity = {
    {
      action = "comment",
      author = {
        username = "zstix",
      },
      date = "2022.10.07:13.20",
      text = "Why are we using snake_case here?",
    },
    {
      action = "comment",
      author = {
        username = "marcelo",
      },
      date = "2022.10.07:14.25",
      text = "I've copied the properties from our legacy Perl implementation. This should be fixed automatically once we format the entire codebase with Prettier.",
    },
  },
};

function state.get_cmark(filename, lnum)
  if filename == nil or lnum == nil then
    filename = vim.fn.expand('%')
    lnum = vim.fn.line('.')
  end

  return state.cmarks[filename .. ':' .. lnum]
end

function state.new_cmark(cmark_id, lnum)
  state.cmarks[cmark_id] = {
    start = lnum,
    finish = lnum + 5, -- TODO: be better than this
    file = vim.fn.bufname('%'),
    branch = "develop", -- TODO
    sha = "12345", -- TODO
    activity = {},
  }
end

return state
