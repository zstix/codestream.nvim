local utils = require('./utils')

local comment = {}

local parseDate = function(timestr)
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

local applyColor = function(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    -- TODO: move colors to settings
    vim.cmd("hi CodeStreamGreen guifg=#1CE783")

    vim.fn.execute("syntax match CodeStreamGreen /\\%>0l\\%<4l\\%1c.\\{4\\}/")
    vim.fn.execute("syntax match Comment /\\%2l\\s[0-9].*/")
  end)
end

function comment.render(buf, opts, width)
  local a = opts.author

  local date = parseDate(opts.date)

  local result = {"╭──╮"}
  table.insert(result, "│@" .. string.sub(a.username, 1, 1) .. "│ " .. a.username .. " " .. date)
  table.insert(result, "╰──╯")

  table.insert(result, opts.text)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)

  applyColor(buf)
end

return comment
