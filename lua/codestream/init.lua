local state = require("./state")
local window = require("./window")
local comment = require("./comment")

-- TODO: add new comment buffer
-- TODO: add comment to codemark

local setup_autocmds = function(state)
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
        window.close_all(state)
      end
    end,
  })
end

-- TODO: make this configurable
local setup_keymaps = function(bufnr)
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>cc', ':CodeStreamComment<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>cs', ':CodeStreamCommentWithSlack<CR>', opts)
end

vim.api.nvim_create_user_command("CodeStream", function(args)
  setup_autocmds(state)

  -- print("args", vim.inspect(args))
  -- TODO: check if theres a mark on this line first
  -- if args.range ~= 0 then
  --   create_sign(bufnr, args.line1)
  -- end

  -- local m = state.get_cmark()
  local m = state.get_cmark('init.lua', 9)

  if m == nil then return end

  -- create_window(state, m)
  local bufnr = window.create(state, m)
  setup_keymaps(bufnr)
end, { range = true })

vim.api.nvim_create_user_command("CodeStreamComment", function(args)
  state.help_state = "comment"
  comment.add_form(state)
end, {})

-- TODO
vim.api.nvim_create_user_command("CodeStreamCommentWithSlack", function(args)
  print("Comment! Now with Slack!")
end, {})

-- for _, m in pairs(cmarks) do
--   create_sign(bufnr, m.start)
-- end
