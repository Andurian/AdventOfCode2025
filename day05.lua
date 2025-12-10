local util = require("util")
local list = require("list")
local range = require("range")

local function preprocess(lines)
    local split_idx = list.find_first(lines, function(s) return string.len(s) == 0 end)
    local range_lines = { table.unpack(lines, 1, split_idx - 1) }
    local id_lines = { table.unpack(lines, split_idx + 1) }

    local valid_ranges = list.transform(range_lines, range.Inclusive.from_string)
    local ids = list.transform(id_lines, tonumber)
    return valid_ranges, ids
end

local function task01(valid_ranges, ids)
    local ret = 0
    for _, id in ipairs(ids) do
        for _, range in ipairs(valid_ranges) do
            if range:contains(id) then
                ret = ret + 1
                break
            end
        end
    end
    return ret
end

local function substitute(list, elem, idx1, idx2)
    local ret = {}
    for i, val in ipairs(list) do
        if i ~= idx1 and i ~= idx2 then
            ret[#ret+1] = val:copy()
        end
    end
    ret[#ret+1] = elem:copy()
    return ret
end

local function try_merge(list)
    for idx_to_merge = 1, #list - 1 do
        for idx_candidate = idx_to_merge + 1, #list do
            local merged = list[idx_to_merge]:unite(list[idx_candidate])
            if merged ~= nil then 
                return substitute(list, merged, idx_to_merge, idx_candidate), true
            end
        end  
    end
    return list, false
end

local function task02(valid_ranges)
    local current = list.copy(valid_ranges)
    local continue = true
    while continue do
        current, continue = try_merge(current)
    end
    return list.accumulate(current, 0, function(a, b) return a + range.Inclusive.count(b) end)
end

local lines = util.lines_from(arg[1])
local valid_ranges, ids = preprocess(lines)

util.aocTask(5, 1, task01, valid_ranges, ids)
util.aocTask(5, 2, task02, valid_ranges)
