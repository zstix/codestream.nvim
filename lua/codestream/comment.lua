local utils = require('./utils')

local comment = {}

local parse_date = function(timestr)
  local parts = vim.fn.split(timestr, "\\:")
  local date = vim.fn.split(parts[1], "\\.")
  local time = vim.fn.split(parts[2], "\\.")

  local year = tonumber(date[1])
  local month = tonumber(date[2])
  local day = tonumber(date[3])
  local hour = tonumber(time[1])
  local minute = tonumber(time[2])

  local datetime = os.time({year=year, month=month, day=day, hour=hour, minute=minute})

  return utils.time_since(datetime)
end

local apply_color = function(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    -- TODO: move colors to settings
    vim.cmd("hi CodeStreamGreen guifg=#1CE783")

    vim.fn.execute("syntax match CodeStreamGreen /╭.\\{3\\}/")
    vim.fn.execute("syntax match CodeStreamGreen /│..│/")
    vim.fn.execute("syntax match CodeStreamGreen /╰.\\{3\\}/")

    -- TODO: better match
    vim.fn.execute("syntax match Comment /\\s[0-9].*/")
  end)
end

local render_comment = function(buf, opts, index)
  local a = opts.author
  local date = parse_date(opts.date)

  local result = {"╭──╮"}
  table.insert(result, "│@" .. string.sub(a.username, 1, 1) .. "│ " .. a.username .. " " .. date)
  table.insert(result, "╰──╯")
  table.insert(result, opts.text)
  table.insert(result, " ")

  if index == 1 then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
  else
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, result)
  end
end

function comment.render(buf, comments)
  for i, comment in pairs(comments) do
    render_comment(buf, comment, i)
  end

  apply_color(buf)
end

return comment
