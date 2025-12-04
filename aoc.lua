local util = require("util")

local function solveDay(n, input_dir)
    local input_filename = string.format("%s/day%02d.txt", input_dir, n)
    local script_filename = string.format("day%02d.lua", n)
    arg = { input_filename }
    dofile(script_filename)
end

local input_dir = arg[1]
local days = util.list_from_range(1, 3)

arg = {} -- used to pass arguments to individual days

for i, day in ipairs(days) do
    solveDay(day, input_dir)
    if i < #days then print() end
end


