local util = require("util")

local function to_numeric(instruction)
    local dir = string.sub(instruction, 1, 1)
    local amount_str = string.sub(instruction, 2)
    local amount = tonumber(amount_str)
    if (dir == "L") then
        amount = -amount
    end
    return amount
end

local function task01(lines)
    local zero_counter = 0
    local current = 50
    for _, instruction in ipairs(lines) do
        current = (current + to_numeric(instruction)) % 100
        if (current == 0) then
            zero_counter = zero_counter + 1
        end
    end
    return zero_counter
end

local function task02(lines)
    local zero_counter = 0
    local current = 50
    for _, instruction in ipairs(lines) do
        local numeric_instruction = to_numeric(instruction)
        for i = 1, math.abs(numeric_instruction) do
            if numeric_instruction > 0 then
                current = (current + 1) % 100
            else
                current = (current - 1) % 100
            end
            if (current == 0) then
                zero_counter = zero_counter + 1
            end
        end
    end
    return zero_counter
end

local input_dir = "andurian"
local input_file = "input/" .. input_dir .. "/day01.txt"
local lines = util.lines_from(input_file)
print(task01(lines))
print(task02(lines))
