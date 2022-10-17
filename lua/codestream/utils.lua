local M = {}

-- TODO: fix logic
function M.time_since(datetime)
  local seconds = math.floor((os.time() - datetime) / 1000)
  local interval = seconds / 31536000
  
  if interval > 1 then
    return math.floor(interval) .. " years ago"
  end

  interval = seconds / 2592000;
  if interval > 1 then
    return math.floor(interval) .. " months ago"
  end

  interval = seconds / 86400;
  if interval > 1 then
    return math.floor(interval) .. " days ago"
  end

  interval = seconds / 3600;
  if interval > 1 then
    return math.floor(interval) .. " hours ago"
  end

  interval = seconds / 60;
  if interval > 1 then
    return math.floor(interval) .. " minutes ago"
  end

  return math.floor(seconds) .. " seconds ago"
end

function M.merge_tables(t1, t2)
  local result = {}
  for k, v in pairs(t1) do result[k] = v end
  for k, v in pairs(t2) do result[k] = v end
  return result
end

function M.get_frame(width, height, title)
  local lines = {}

  if title == nil then
    table.insert(lines, '╭' .. string.rep('─', width - 2) .. '╮')
  else
    table.insert(lines, '╭─ ' .. title .. ' ' .. string.rep('─', width - 5 - string.len(title)) .. '╮')
  end

  for i=1,(height - 2) do
    table.insert(lines, '│' .. string.rep(' ', width - 2) .. '│')
  end

  table.insert(lines, '╰' .. string.rep('─', width - 2) .. '╯')

  return lines
end

return M
