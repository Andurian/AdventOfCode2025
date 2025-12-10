local util = require("util")
local list = require("list")

local function binary_from_lights_string(lights)
    local ret = 0
    for i = 0,#lights-1 do
        if lights[#lights - i] == "#" then
            ret = ret + 2^i
        end
    end
    return ret
end

local function binary_from_steps_list(steps, n)
    local ret = 0
    for _, s in ipairs(steps) do
        ret = ret + 2^(n-1 - s)
    end
    return ret
end

local function lights_string_from_binary(bin, n)
    local ret = {}
    for i = 1,n do
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

--local Graph = {}
--Graph.__index = Graph

local function graph_from_line_01(line)
    local tokens = list.from_string(line, " ", function(s) return s end)
    local target_lights = list.from_chars(string.sub(tokens[1],2, #tokens[1]-1))
    local steps = {}
    for i = 2,#tokens-1 do
        steps[#steps+1] = list.from_string(string.sub(tokens[i], 2, #tokens[i]-1), ",", tonumber)
    end
    --print(table.concat(target_lights) .. " -> " .. binary_from_lights_string(target_lights) .. " -> " .. lights_string_from_binary(binary_from_lights_string(target_lights), #target_lights))
    --list.print(steps)

    local transitions = {}
    for i = 0,2^(#target_lights + 1) - 1 do
        local next = {}
        for j, step in ipairs(steps) do
            local val = i ~ binary_from_steps_list(step, #target_lights)
            next[j] = { step = step, state = val, state_str = lights_string_from_binary(val, #target_lights), cost = 1}
        end
        transitions[i] = next
    end

    return {target = target_lights, transitions = transitions}
end

local function find_button_presses(target_lights, transitions)
    local distances = {}
    local previous = {}
    local to_visit = {}

    distances[0] = 0
    to_visit[1] = 0
    for i=1,#transitions do
        distances[i] = 99999999999999
        to_visit[i+1] = i
    end

    while #to_visit > 0 do
        -- find current min element
        local min_dist = 99999999999999
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
            return distances[binary_from_lights_string(target_lights)]
        end

        -- remove from to_visit
        table.remove(to_visit, to_remove)

        for _, transition in ipairs(transitions[min_element]) do
            if list.find_first(to_visit, transition.state) ~= nil then
                local current_dist_to_state = distances[transition.state]
                local new_dist_to_state = min_dist + transition.cost
                if  current_dist_to_state == -1 or new_dist_to_state < current_dist_to_state then
                    distances[transition.state] = new_dist_to_state
                    previous[transition.state] = min_element
                end
            end
        end
    end

    print("DONE")
    return distances[binary_from_lights_string(target_lights)]


end

local function task01(graphs)
    local sum = 0
    for _, g in ipairs(graphs) do
        local n =  find_button_presses(g.target, g.transitions)
        sum = sum +n
        print(n)
    end
    return sum
end

local lines = util.lines_from(arg[1])
local graphs = list.transform(lines, graph_from_line_01)

util.aocTask(10, 1, task01, graphs)


