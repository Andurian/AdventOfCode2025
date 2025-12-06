local util = require("util")

local function operation(op)
    if op == "+" then
        return
            function(a, b) return a + b end
    end
    if op == "*" then
        return
            function(a, b) return a * b end
    end
end


local function rot_left(matrix)
    local ret = {}

    for col = #matrix[1], 1, -1 do
        local row_ret = #matrix[1] - col + 1
        ret[row_ret] = {}
        for row = 1, #matrix do
            ret[row_ret][row] = matrix[row][col]
        end
    end
    return ret
end

local function build_inputs(numbers)
    local inputs = {}
    local current_problem = {}
    for _, line in ipairs(numbers) do
        local number = tonumber(util.list_to_string(line))
        if number == nil then
            inputs[#inputs + 1] = current_problem
            current_problem = {}
        else
            current_problem[#current_problem + 1] = number
        end
    end
    if #current_problem > 0 then
        inputs[#inputs + 1] = current_problem
    end
    return inputs
end

local function task01(numbers_strings, ops)
    local numbers = util.transform_list(numbers_strings, function(line)
        return util.listFromString(line, " ", tonumber)
    end)

    local ret = 0
    for id_problem = 1, #ops do
        local current_result = numbers[1][id_problem]
        for id_number = 2, #numbers do
            current_result = ops[id_problem](current_result, numbers[id_number][id_problem])
        end
        ret = ret + current_result
    end
    return ret
end

local function task02(numbers_strings, ops)
    local number_matrix = util.transform_list(numbers_strings,
        function(line) return util.listFromStringByChars(line, function(x) return x end) end)
    local friendly_number_matrix = rot_left(number_matrix)
    local problem_inputs = build_inputs(friendly_number_matrix)

    local ret = 0
    for id_problem = 1,#problem_inputs do
        local current_result = problem_inputs[id_problem][1]
        for id_number = 2, #problem_inputs[id_problem] do
            current_result = ops[#problem_inputs - id_problem + 1](current_result, problem_inputs[id_problem][id_number])
        end
        ret = ret + current_result
    end
    return ret
end

local input = util.lines_from(arg[1])

local numbers_strings = { table.unpack(input, 1, #input - 1) }
local ops = util.transform_list(util.listFromString(input[#input], " ", function(x) return x end), operation)


util.aocTask(6, 1, task01, numbers_strings, ops)
util.aocTask(6, 1, task02, numbers_strings, ops)
