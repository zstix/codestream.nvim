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

-- Entrypoint keybinds
vim.api.nvim_buf_set_keymap(state.bufnr, 'n', '<Leader>cc', ':CodeStream<CR>', { noremap = true })
vim.api.nvim_buf_set_keymap(state.bufnr, 'n', '<Leader>cn', ':CodeStreamNext<CR>', { noremap = true })
vim.api.nvim_buf_set_keymap(state.bufnr, 'n', '<Leader>cp', ':CodeStreamPrev<CR>', { noremap = true })

vim.api.nvim_create_user_command("CodeStreamComment", function(args)
  state.help_state = "comment"
  Comment.add_form(state)
end, {})

vim.api.nvim_create_user_command("CodeStreamNext", function(args)
  local curr_line, _ = unpack(vim.api.nvim_win_get_cursor(0))

  local lines = {}
  for k, _ in pairs(state.cmarks) do
    -- TODO: filter out marks in other files
    local parts = vim.fn.split(k, ':')
    table.insert(lines, tonumber(parts[2]))
  end
  table.sort(lines)

  -- TODO: show a warning when hitting the "bottom" of the file
  -- find the next mark from this point, if none exist do nothing
  local target_line = curr_line
  for _, line in ipairs(lines) do
    if line > curr_line then
      target_line = line
      break
    end
  end

  if target_line ~= curr_line then
    vim .api.nvim_win_set_cursor(0, { target_line, 1 })
  else
    print("No more codemarks found in this file")
  end
end, {})

-- TODO: DRY
vim.api.nvim_create_user_command("CodeStreamPrev", function(args)
  local curr_line, _ = unpack(vim.api.nvim_win_get_cursor(0))

  local lines = {}
  for k, _ in pairs(state.cmarks) do
    -- TODO: filter out marks in other files
    local parts = vim.fn.split(k, ':')
    table.insert(lines, tonumber(parts[2]))
  end
  table.sort(lines)

  -- TODO: show a warning when hitting the "bottom" of the file
  -- find the next mark from this point, if none exist do nothing
  local target_line = curr_line
  for _, line in ipairs(lines) do
    if line < curr_line then
      target_line = line
      break
    end
  end

  if target_line ~= curr_line then
    vim .api.nvim_win_set_cursor(0, { target_line, 1 })
  else
    print("No more codemarks found in this file")
  end
end, {})

-- TODO
-- vim.api.nvim_create_user_command("CodeStreamCommentWithSlack", function(args)
--   print("Comment! Now with Slack!")
-- end, {})

vim.api.nvim_create_user_command("CodeStream", function(args)
  setup_autocmds(state)

  -- TODO: check if theres a mark on this line first
  -- TODO: handle new marks
  -- if args.range ~= 0 then
  --   create_sign(bufnr, args.line1)
  -- end

  local m = state.get_cmark(vim.fn.bufname('%'), args.line1)

  local m_id = vim.fn.bufname('%') .. ':' .. args.line1
  state.active_cmark = m_id

  -- If we can't find a mark, make one
  if m == nil then
    state.new_cmark(m_id, args.line1)
    m = state.get_cmark(vim.fn.bufname('%'), args.line1)
    local bufnr = Window.create(state, m)
    setup_keymaps(bufnr)
    state.help_state = "comment"
    Comment.add_form(state)
    Sign.create(state, m.start, m_id)
  -- otherwise, show what we have saved in state
  else
    local bufnr = Window.create(state, m)
    setup_keymaps(bufnr)
  end
end, { range = true })

for k, m in pairs(state.cmarks) do
  -- TODO: only for current buffer? Autogroups?
  Sign.create(state, m.start, k)
end
