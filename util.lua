local util = {}


local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end


function util.lines_from(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

function util.listFromString(s, separator, factory) 
    local ret = {}
    for match in string.gmatch(s, "[^".. separator .. "]+") do
        ret[#ret+1] = factory(match)
    end
    return ret
end

function util.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. util.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


return util