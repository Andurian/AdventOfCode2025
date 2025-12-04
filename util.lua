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

function util.listFromStringByChars(s, factory) 
    local ret = {}
    for i = 1,#s do
        ret[#ret+1] = factory(string.sub(s, i, i))
    end
    return ret
end

function util.executeTimed(f, ...)
   local start, ret, finish = os.clock(), f(...), os.clock()
   return ret, finish - start
end

function util.aocTask(day, task, f, ...)
   local result, duration = util.executeTimed(f, ...)
   print(string.format("[%7.2fms] Solution Day %02d Task %02d: %s", duration* 1000, day, task, tostring(result)))
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

function util.list_from_range(a, b, step)
    local ret = {}
    step = step or 1
    for i = a, b, step do
        ret[#ret+1] = i
    end
    return ret
end


return util