local help = {}

local get_help_text = function()
  local help = { " <Leader>c_" }

  table.insert(help, "c: comment")
  table.insert(help, "s: comment w/slack")

  return { vim.fn.join(help, " ") }
end

local get_comment_text = function()
  local help = { " <Leader>c_" }

  table.insert(help, "c: comment")
  table.insert(help, "d: discard")

  return { vim.fn.join(help, " ") }
end

function help.get_text(state)
  if state.help_state == "init" then
    return get_help_text()
  elseif state.help_state == "comment" then
    return get_comment_text()
  else
    return {}
  end
end

return help
