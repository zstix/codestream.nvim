local state = require("./state")
local window = require("./window")

local setup_autocmds = function(state)
  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.augroup,
    pattern = "*", -- TODO: current buffer?
    callback = function(data)
      local is_cs_win = false
      for _, win in ipairs(state.wins) do
        if tonumber(data.file) == win then
          is_cs_win = true
          break
        end
      end
      if is_cs_win then
        for _, win in ipairs(state.wins) do
          vim.api.nvim_win_close(win, false)
        end
        state.wins = {}
      end
    end,
  })
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
  window.create(state, m)
end, { range = true })

-- for _, m in pairs(cmarks) do
--   create_sign(bufnr, m.start)
-- end
