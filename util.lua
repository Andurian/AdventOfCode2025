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

function util.executeTimed(f, ...)
  local start, ret, finish = os.clock(), f(...), os.clock()
  return ret, finish - start
end

function util.aocTask(day, task, f, ...)
  local result, duration = util.executeTimed(f, ...)
  print(string.format("[%7.2fms] Solution Day %02d Task %02d: %s", duration * 1000, day, task, tostring(result)))
end

function util.dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. util.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function util.printable_enum(repr)
  return setmetatable(
    { repr = repr },
    {
      __tostring = function(self)
        return self.repr
      end
    }
  )
end

function util.replace_char(str, pos, r)
  return str:sub(1, pos - 1) .. r .. str:sub(pos + 1)
end

function util.replace_chars(str, positions, r)
  local s = str
  for _, pos in ipairs(positions) do
    s = util.replace_char(s, pos, r)
  end
  return s
end

function util.replace_chars_individually(str, positions, r)
  local s = str
  for i, pos in ipairs(positions) do
    s = util.replace_char(s, pos, r[i])
  end
  return s
end

function util.table_equal(t1, t2)
    if t1 == t2 then return true end
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return false
    end

    -- compare keys/values in t1 against t2
    for k, v in pairs(t1) do
        if not util.table_equal(v, t2[k]) then
            return false
        end
    end

    -- ensure t2 doesn't have extra keys
    for k in pairs(t2) do
        if t1[k] == nil then
            return false
        end
    end

    return true
end

-- from http://lua-users.org/wiki/CopyTable
function util.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
        end
        setmetatable(copy, util.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return util
