local util = require("util")

local function joltage(batteries, n)
    if n <= 0 then return 0 end
    local maxIndex = 1
    for i = 2,#batteries - n + 1 do
        if batteries[i] > batteries[maxIndex] then
            maxIndex = i
        end
    end
    return math.tointeger(10^(n-1)) * batteries[maxIndex] + joltage({table.unpack(batteries, maxIndex + 1, #batteries)}, n-1)
end

local function totalJoltage(lines, n) 
    local sum = 0
    for _,line in ipairs(lines) do
        local batteries = util.listFromStringByChars(line, tonumber)
        sum = sum + joltage(batteries, n)
    end
    return sum
end

local lines = util.lines_from(arg[1])

util.aocTask(3, 1, totalJoltage, lines, 2)
util.aocTask(3, 2, totalJoltage, lines, 12)
