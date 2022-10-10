local comment = {}

local function parseDate(timestr)
  local date = vim.fn.split(timestr, "\\.")
  local y = tonumber(date[1])
  local m = tonumber(date[2])
  local d = tonumber(date[3])
  local time = os.time({year=y, month=m, day=d})

  -- Friday Oct. 7
  return os.date("%A %b. %d", time)
end

local function applyColor(bufnr, num_lines)
  vim.api.nvim_buf_call(bufnr, function()
    -- TODO: move colors to settings
    vim.cmd("hi CodeStreamGreen guifg=#1CE783")

    vim.fn.execute("syntax match CodeStreamGreen /\\%>0l\\%<4l\\%1c.\\{4\\}/")
    vim.fn.execute("syntax match Comment /\\%" .. num_lines .. "l.*/")
  end)
end

function comment.render(buf, opts, width)
  local a = opts.author
  local full_name = a.first_name .. " " .. a.last_name
  local initials = string.sub(a.first_name, 1, 1) .. string.sub(a.last_name, 1, 1)

  local result = {"╭──╮"}
  table.insert(result, "│" .. initials .. "│ " .. full_name .. " (" .. a.username .. ")")
  table.insert(result, "╰──╯")

  table.insert(result, opts.text)
  table.insert(result, " ")

  -- TODO: offset position
  local date = parseDate(opts.date)
  table.insert(result, string.rep(' ', width - 4 - string.len(date)) .. date)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)

  applyColor(buf, #result)

  -- for testing
  -- print(table.concat(result, "\n"))
end

-- for testing
-- local test_comment = {
--   action = "comment",
--   author = {
--     first_name = "Zack",
--     last_name = "Stickles",
--     username = "zstix",
--   },
--   date = "2022.10.07", -- TODO: time
--   text = "Why are we using snake_case here?",
-- }
-- comment.render(0, test_comment, 40)

return comment
