local lanes = require("lanes").configure()
local linda = lanes.linda

local util = require("util")
local list = require("list")

local INF = 1e18

local solve_util = {}

---Converts a lights list ['.', '#', '#', "."] to a binary number 0b0110 = 6
---@param lights list[char]
---@return number
function solve_util.lights_as_binary(lights)
    local ret = 0
    for i = 0, #lights - 1 do
        if lights[#lights - i] == "#" then
            ret = ret + 2 ^ i
        end
    end
    return ret
end

---Converts a button (0, 2) into a binary number 0x0101
---@param button any
---@param num_lights any
---@return unknown
function solve_util.button_as_binary(button, num_lights)
    local ret = 0
    for _, s in ipairs(button) do
        ret = ret + 2 ^ (num_lights - 1 - s)
    end
    return ret
end

---Debug functionality, prints a binary number as string with '#' as ones
---@param bin any
---@param n any
---@return string
function solve_util.binary_as_string(bin, n)
    local ret = {}
    for i = 1, n do
        ret[i] = "."
    end
    local i = 1
    while bin > 0 do
        if bin % 2 == 1 then
            ret[i] = "#"
        else
            ret[i] = "."
        end
        bin = bin // 2
        i = i + 1
    end
    return table.concat(ret):reverse()
end

function solve_util.binary_as_list(bin, n)
    local ret = {}
    for i = 1, n do
        ret[i] = 0
    end
    local i = 1
    while bin > 0 do
        if bin % 2 == 1 then
            ret[i] = 1
        else
            ret[i] = 0
        end
        bin = bin // 2
        i = i + 1
    end
    return list.reverse(ret)
end

---Converts a joltage {3, 5, 4, 7} into an even-odd parity list ['#', '#', '.', '#']
---@param joltage any
function solve_util.joltage_parity(joltage)
    local ret = {}
    for i, j in ipairs(joltage) do
        if j % 2 == 0 then
            ret[i] = "."
        else
            ret[i] = "#"
        end
    end
    return ret
end

local Machine = {}
Machine.__index = Machine

function Machine.from_line(line)
    local tokens = list.from_string(line, " ", function(s) return s end)
    local target_lights = list.from_chars(string.sub(tokens[1], 2, #tokens[1] - 1))

    local buttons = {}
    for i = 2, #tokens - 1 do
        buttons[#buttons + 1] = list.from_string(string.sub(tokens[i], 2, #tokens[i] - 1), ",", tonumber)
    end
    local target_joltage = list.from_string(string.sub(tokens[#tokens], 2, #tokens[#tokens] - 1), ",", tonumber)

    return setmetatable({
        target_lights = target_lights,
        target_joltage = target_joltage,
        buttons = buttons,
    }, Machine)
end

local Solver = {}
Solver.__index = Solver

--- Creates a solver for both problems from a machine
---@param machine Machine
---@return Solver
function Solver.new(machine)
    return setmetatable({
        machine = machine,
        binary_buttons = list.transform(machine.buttons,
            function(b) return solve_util.button_as_binary(b, #machine.target_lights) end)
    }, Solver)
end

---comment
---@param parity table | nil
---@return integer|unknown
function Solver:num_presses_for_parity(parity)
    local visited = {}
    local target
    if parity == nil then
        target = solve_util.lights_as_binary(self.machine.target_lights)
    else
        target = solve_util.lights_as_binary(parity)
    end
    local calc_recursive
    calc_recursive = function(level, states)
        local next_states = {}
        for _, state in ipairs(states) do
            for _, button in ipairs(self.binary_buttons) do
                local next = state ~ button
                if next == target then
                    return level + 1
                end

                if visited[next] == nil then
                    next_states[#next_states + 1] = next
                    visited[next] = true
                end
            end
        end
        if #next_states == 0 then
            return -1
        end
        return calc_recursive(level + 1, next_states)
    end
    return calc_recursive(0, { 0 })
end

function Solver:all_presses_for_parity(parity)
    local ret = {}
    local target
    if parity == nil then
        target = solve_util.lights_as_binary(self.machine.target_lights)
    else
        target = solve_util.lights_as_binary(parity)
    end

    for i = 0, 2 ^ (#self.machine.buttons) - 1 do
        local current = 0
        local num_presses = solve_util.binary_as_list(i, #self.machine.buttons)
        for idx_button, pressed in ipairs(num_presses) do
            if pressed == 1 then current = current ~ self.binary_buttons[idx_button] end
        end
        if current == target then
            ret[#ret + 1] = num_presses
        end
    end

    return ret
end

---This was my first implementation for task 01. I thought task 02 would be way different and dijkstra
---would help me there. Instead it makes task 01 way slower since I build the entire graph before solving
---including nodes that are unreachable.
---But since it does work, I leave it here.
---@param parity any
---@return unknown
function Solver:num_presses_for_parity_dijkstra(parity)
    local target
    if parity == nil then
        target = solve_util.lights_as_binary(self.machine.target_lights)
    else
        target = solve_util.lights_as_binary(parity)
    end

    local transitions = {}
    for i = 0, 2 ^ (#self.machine.target_lights + 1) - 1 do
        local next = {}
        for j, button in ipairs(self.binary_buttons) do
            local val = i ~ button
            next[j] = { button = button, state = val, cost = 1 } --I hoped for a very different task 2 then...
        end
        transitions[i] = next
    end

    local distances = {}
    local to_visit = {}

    distances[0] = 0
    to_visit[1] = 0
    for i = 1, #transitions do
        distances[i] = INF
        to_visit[i + 1] = i
    end

    while #to_visit > 0 do
        -- find current min element
        local min_dist = INF
        local min_element = nil
        local to_remove = 0
        for i, k in ipairs(to_visit) do
            if distances[k] < min_dist then
                min_dist = distances[k]
                min_element = k
                to_remove = i
            end
        end

        if min_element == nil then
            return distances[target]
        end

        table.remove(to_visit, to_remove)

        for _, transition in ipairs(transitions[min_element]) do
            if list.find_first(to_visit, transition.state) ~= nil then
                local current_dist_to_state = distances[transition.state]
                local new_dist_to_state = min_dist + transition.cost
                if current_dist_to_state == -1 or new_dist_to_state < current_dist_to_state then
                    distances[transition.state] = new_dist_to_state
                end
            end
        end
    end

    return distances[target]
end

---comment
---@param joltage table | nil
function Solver:presses_for_joltage(joltage)
    local target
    if joltage == nil then
        target = util.deepcopy(self.machine.target_joltage)
    else
        target = util.deepcopy(joltage)
    end

    local calc_recursive
    calc_recursive = function(_target)
        local all_zero = true
        for _, remaining_joltage in ipairs(_target) do
            if remaining_joltage < 0 then return {} end -- invalid branch
            if remaining_joltage > 0 then all_zero = false end
        end

        if all_zero then return { 0 } end

        local parity = solve_util.joltage_parity(_target)
        local all_possible_presses = self:all_presses_for_parity(parity)

        local ret = {}
        for idx_presses, presses in ipairs(all_possible_presses) do
            local next_target = util.deepcopy(_target)
            for idx_button, num_presses in ipairs(presses) do
                local button = self.machine.buttons[idx_button]
                for _, i in ipairs(button) do
                    next_target[i + 1] = next_target[i + 1] - num_presses
                end
            end
            for i = 1, #next_target do
                assert(next_target[i] % 2 == 0, "Next target should have even parity")
                next_target[i] = next_target[i] / 2
            end

            local num_presses = list.accumulate(presses)
            ret = list.concat(ret,
                list.transform(calc_recursive(next_target), function(x) return num_presses + 2 * x end))
        end
        return ret
    end

    local ret = calc_recursive(target)
    local min = ret[1]
    for i = 2, #ret do
        min = math.min(min, ret[i])
    end
    return min
end

local function task02_parallel(lines, num_workers)
    local task_linda = linda()
    local result_linda = linda()

    local solve_worker = lanes.gen("*", function(i, task_linda, result_linda)
        while true do
            local _, task = task_linda:receive("task")
            if task == nil then return end
            local solver = Solver.new(Machine.from_line(task))
            local res = solver:presses_for_joltage()
            result_linda:send("result", {num_presses = res})
        end
    end)

    local workers = {}
    for i = 1, num_workers do
        workers[i] = solve_worker(i, task_linda, result_linda)
    end

    for _, line in ipairs(lines) do
        task_linda:send("task", line)
    end

    for i = 1, num_workers do
        task_linda:send("task", nil)
    end

    local sum = 0
    local barWidth = 40
    for i = 1,#lines do
        local _,res = result_linda:receive("result")
        sum = sum + res.num_presses

        local progress = i / #lines
        local filled = math.floor(progress * barWidth)
        local empty = barWidth - filled

        local bar = string.rep("#", filled) .. string.rep("-", empty)

        io.write(string.format("\r[%s] %3d/%3d", bar, i, #lines))
        io.flush()
    end

    io.write(string.format("\r%60s\r", " "))

    for _, worker in ipairs(workers) do
        worker:join()
    end

    return sum
end

-- The vast number of problems finishes more or less instantly
-- However, there are about ~10 problems which take about 2-4 minutes each. 
-- I don't know how to optimize those yet. But it also means increasing the number
-- of workers above the number of these hard problems would not yield any speedup
local num_workers = 8
if arg[2] ~= nil then num_workers = tonumber(arg[2]) end

local lines = util.lines_from(arg[1])
local solvers = list.transform(lines, function(line) return Solver.new(Machine.from_line(line)) end)

util.aocTask(10, 1, list.accumulate, list.transform(solvers, Solver.num_presses_for_parity))
util.aocTask(10, 2, task02_parallel, lines, num_workers)

-- Produces the same result as Solver.num_presses_for_parity but takes more time. So don't run it.
--util.aocTask(10, 1, list.accumulate, list.transform(solvers, Solver.num_presses_for_parity_dijkstra))
