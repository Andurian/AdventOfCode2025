local list = {}

---Splits str at each separator and feeds each token into factory
---@param str string
---@param separator string
---@param factory function(string)
---@return table
function list.from_string(str, separator, factory)
    local ret = {}
    local f = factory
    if f == nil then
        f = function(s) return s end
    end
    for match in string.gmatch(str, "[^" .. separator .. "]+") do
        ret[#ret + 1] = f(match)
    end
    return ret
end

---comment
---@param str string
---@param factory function|nil
---@return table
function list.from_chars(str, factory)
    local ret = {}
    for i = 1, #str do
        if factory ~= nil then
            ret[#ret + 1] = factory(string.sub(str, i, i))
        else
            ret[#ret + 1] = string.sub(str, i, i)
        end
    end
    return ret
end

---comment
---@param set table
---@return table
function list.from_set(set)
    local ret = {}
    for i, _ in pairs(set) do
        ret[#ret + 1] = i
    end
    return ret
end

---comment
---@param set table
---@return table
function list.from_set_values(set)
    local ret = {}
    for i, v in pairs(set) do
        ret[#ret + 1] = v
    end
    return ret
end

---Creates a list from values between a and b (inclusive) with steps between
---@param a any
---@param b any
---@param step any
---@return table
function list.from_range(a, b, step)
    local ret = {}
    step = step or 1
    for i = a, b, step do
        ret[#ret + 1] = i
    end
    return ret
end

local function create_matcher(predicate)
     if type(predicate) == "function" then
        return predicate
    elseif type(predicate) == "table" then
        return function(value)
            if type(value) ~= "table" then return false end
            for k, v in pairs(predicate) do
                if value[k] ~= v then
                    return false
                end
            end
            return true
        end
    else
        return function(value)
            return value == predicate
        end
    end

end

---comment
---@param arr table (list)
---@param predicate number|string|table|function
function list.find_first(arr, predicate)
    local matches = create_matcher(predicate)
   
    for i, value in ipairs(arr) do
        if matches(value) == true then
            return i, value
        end
    end

    return nil
end

function list.find_all(arr, predicate)
    local matches = create_matcher(predicate)
      local ret_idx = {}
  local ret_vals = {}
  for i, value in ipairs(arr) do
    if matches(value) == true then
      ret_idx[#ret_idx + 1] = i
      ret_vals[#ret_vals + 1] = value
    end
  end
  return ret_idx, ret_vals
end

function list.transform(arr, factory)
      local ret = {}
  for _, elem in ipairs(arr) do
    ret[#ret + 1] = factory(elem)
  end
  return ret
end

function list.reverse(tab)
    for i = 1, #tab//2, 1 do
        tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
    end
    return tab
end

function list.concat(l1, l2)
    for _, elem in ipairs(l2) do
        l1[#l1+1] = elem
    end
    return l1
end

function list.copy(arr)
  return list.transform(arr, function(elem) return elem:copy() end)
end

function list.print(arr)
    for _, v in ipairs(arr) do
        print(v)
    end
end

function list.accumulate(arr, init, op)
    local ret = init
    if ret == nil then 
        ret = 0
    end
    local _op = op
    if _op == nil then
        _op = function(a, b) return a + b end
    end
    for _, value in ipairs(arr) do
        ret = _op(ret, value)
    end
    return ret
end



return list
