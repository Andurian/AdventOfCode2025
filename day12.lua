local util = require("util")
local list = require("list")
local grid = require("grid2d")

local function parse_input(lines)
    local splits = list.find_all(lines, function(l) return #l == 0 end)
    table.insert(splits, 1, 0)
    local presents = {}
    for i = 1, #splits-1 do
        local present = grid.Grid.from_lines({table.unpack(lines, splits[i]+2, splits[i+1]-1)}, function(c) return c end)
        presents[i] = {
            present = present, actual_size = present:count('#'), max_size = present.rows * present.cols
        }
    end
    local problems = {}
    for i, line in ipairs({table.unpack(lines, splits[#splits]+1)}) do
        local chars = list.from_chars(line, function(c) return c end)
        local i_x = list.find_first(chars, "x")
        local i_e = list.find_first(chars, ":")
        local w = tonumber(string.sub(line, 1, i_x - 1))
        local h = tonumber(string.sub(line, i_x + 1, i_e - 1))
        local numbers = list.from_string(string.sub(line, i_e + 2), " ", tonumber)
        problems[i] = {
            width = w, height = h, required = numbers
        }
    end

    return presents, problems
end

local ProblemClass = {
    Solvable = 1,
    Unsolvable = 2,
    Uncertain = 3
}

local function determine_problem_class(presents, problem)
    local available_space = problem.width * problem.height
    local min_needed_space = 0
    local max_needed_space = 0
    for i, n in ipairs(problem.required) do
        min_needed_space = min_needed_space + presents[i].actual_size * n
        max_needed_space = max_needed_space + presents[i].max_size * n
    end
    if max_needed_space <= available_space then return ProblemClass.Solvable end
    if min_needed_space > available_space then return ProblemClass.Unsolvable end
    return ProblemClass.Uncertain
end


local function task01(presents, problems)
    local nums = list.from_const(3, 0)
    for _, p in ipairs(problems) do
        local problem_class = determine_problem_class(presents, p)
        nums[problem_class] = nums[problem_class] + 1
    end
    return nums[ProblemClass.Solvable]
end

local lines = util.lines_from(arg[1])
local presents, problems = parse_input(lines)

util.aocTask(12, 1, task01, presents, problems)