local util = require("util")

InclusiveRange = {}

function InclusiveRange.new(min, max)
    local range = { min = min, max = max }
    return range
end

function InclusiveRange.fromString(s)
    local limits = util.listFromString(s, "-", tonumber)
    return InclusiveRange.new(limits[1], limits[2])
end

function InclusiveRange.iterator(range)
    local i = range.min - 1
    return function()
        i = i + 1
        if i <= range.max then
            return i
        end
    end
end

local function rangesFromInput(input)
    return util.listFromString(input, ",", InclusiveRange.fromString)
end

local function isTwiceRepeatingNumber(n)
    local s = tostring(n)
    if #s % 2 ~= 0 then return false end
    local patternLength = #s // 2
    local pattern = string.sub(s, 1, patternLength)
    local match = string.sub(s, patternLength + 1)
    return pattern == match
end

local function isRepeatingNumber(n)
    local s = tostring(n)
    for patternLength = 1, (#s) // 2 do
        if #s % patternLength ~= 0 then goto continue end
        local pattern = string.sub(s, 1, patternLength)
        local matchStart = 1 + patternLength
        local allMatch = true
        while matchStart + patternLength - 1 <= #s and allMatch do
            local potentialMatch = string.sub(s, matchStart, matchStart + patternLength - 1)
            allMatch = allMatch and potentialMatch == pattern
            matchStart = matchStart + patternLength
        end
        if allMatch then return true end
        ::continue::
    end
    return false
end

local function sumRanges(ranges, predicate)
    local sum = 0
    for _, range in ipairs(ranges) do
        for i in InclusiveRange.iterator(range) do
            if predicate(i) then
                sum = sum + i
            end
        end
    end
    return sum
end

local input = util.lines_from(arg[1])[1]
local ranges = rangesFromInput(input)

util.aocTask(2, 1, sumRanges, ranges, isTwiceRepeatingNumber)
util.aocTask(2, 2, sumRanges, ranges, isRepeatingNumber)