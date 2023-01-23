local state = require("./state")
local Window = require("./window")
local Comment = require("./comment")
local Sign = require("./sign")

local function setup_autocmds(state)
  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.augroup,
    pattern = "*", -- TODO: current buffer?
    callback = function(data)
      local is_cs_win = false
      for key, _ in pairs(state.wins) do
        if tonumber(data.file) == state.wins[key] then
          is_cs_win = true
          break
        end
      end
      if is_cs_win then
        Window.close_all(state)
      end
    end,
  })
end

-- TODO: make this configurable
local function setup_keymaps(bufnr)
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>cc', ':CodeStreamComment<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>cs', ':CodeStreamCommentWithSlack<CR>', opts)
end

vim.api.nvim_create_user_command("CodeStream", function(args)
  setup_autocmds(state)

  -- TODO: what was I trying to do here?
  -- I _think_ it's about loading the current codemark
  -- print("args", vim.inspect(args))
  -- TODO: check if theres a mark on this line first
  -- if args.range ~= 0 then
  --   create_sign(bufnr, args.line1)
  -- end

  -- local m = state.get_cmark()
  local m = state.get_cmark('init.lua', 6)

  if m == nil then return end

  -- create_window(state, m)
  local bufnr = Window.create(state, m)
  setup_keymaps(bufnr)
end, { range = true })

vim.api.nvim_create_user_command("CodeStreamComment", function(args)
  -- TODO: dynamic
  state.active_cmark = 'init.lua:6'

  state.help_state = "comment"
  Comment.add_form(state)
end, {})

-- TODO
-- vim.api.nvim_create_user_command("CodeStreamCommentWithSlack", function(args)
--   print("Comment! Now with Slack!")
-- end, {})

for k, m in pairs(state.cmarks) do
  -- TODO: only for current buffer? Autogroups?
  Sign.create(state, m.start, k)
end
