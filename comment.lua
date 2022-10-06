local comment = {}

local test_comment = {
  action = "comment",
  author = {
    first_name = "Zack",
    last_name = "Stickles",
    username = "zstix",
  },
  date = "date_goes_here", -- TODO
  text = "Why are we using snake_case here?",
}

function comment.render(buf, opts)
  local a = opts.author
  local full_name = a.first_name .. " " .. a.last_name
  local initials = string.sub(a.first_name, 1, 1) .. string.sub(a.last_name, 1, 1)

  local result = {" ╭──╮"}
  table.insert(result, " │" .. initials .. "│ " .. full_name .. " (" .. a.username .. ")")
  table.insert(result, " ╰──╯")

  -- TODO: wrap at certain character length?
  table.insert(result, "  " .. opts.text)
  table.insert(result, " ")

  -- TODO: offset position
  table.insert(result, "          " .. opts.date)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)

  -- print(table.concat(result, "\n"))
end

-- for testing
-- comment.render(test_comment)

return comment
