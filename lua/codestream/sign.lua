local Sign = {}

-- TODO: caching?
function Sign.create(state, lnum)
  vim.fn.sign_define(sign_name, {
    text = "<>",
    texthl = "Comment",
  })

  vim.fn.sign_place(
    lnum,
    state.sign_group,
    state.sign_group .. "_" .. lnum,
    state.bufnr,
    { lnum = lnum }
  )
end

return Sign
