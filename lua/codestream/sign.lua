local Sign = {}

-- TODO: caching?
function Sign.create(state, lnum)
  local sign_name = state.sign_group .. "_" .. lnum

  vim.fn.sign_define(sign_name, {
    text = "<>",
    texthl = "Comment",
  })

  vim.fn.sign_place(
    state.sign_num,
    state.sign_group,
    sign_name,
    state.bufnr,
    { lnum = lnum }
  )

  state.sign_num = state.sign_num + 1
end

return Sign
