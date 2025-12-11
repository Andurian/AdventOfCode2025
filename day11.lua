local util = require("util")
local list = require("list")

local function build_graph(lines)
    local ret = {}
    for _, line in ipairs(lines) do
        local tokens = list.from_string(line, " ", function(s) return s end)
        --print(table.concat(tokens, ", "))
        local label = string.sub(tokens[1], 1, #tokens[1] - 1)
        local conns = { table.unpack(tokens, 2, #tokens) }
        ret[label] = conns
    end
    return ret
end

local function paths_between(graph, a, b)
    local num_found = 0
    local dfs

    dfs = function(current)
        if current == b then
            num_found = num_found + 1
            return
        end
        if graph[current] == nil then return end
        for _, next in ipairs(graph[current]) do
            dfs(next)
        end
    end
    dfs(a)
    return num_found
end

local function reachable_nodes(graph, start)
    local ret = {}
    local to_visit = { start }
    while #to_visit > 0 do
        local current = to_visit[1]
        table.remove(to_visit, 1)
        if list.find_first(ret, current) == nil then
            ret[#ret + 1] = current
            if graph[current] ~= nil then
                for _, next in ipairs(graph[current]) do
                    if list.find_first(ret, next) == nil then
                        to_visit[#to_visit + 1] = next
                    end
                end
            end
        end
    end
    return ret
end

local function sorted_nodes(graph, start)
    -- build a subgraph of only reachable nodes
    local reachable = reachable_nodes(graph, start)
    local _graph = {}
    for _, node in ipairs(reachable) do
        _graph[node] = util.deepcopy(graph[node])
    end

    local ret = {}
    local to_visit = { start }
    while #to_visit > 0 do
        local current = to_visit[1]
        table.remove(to_visit, 1)
        ret[#ret + 1] = current
        local candidates = _graph[current]
        if candidates ~= nil then
            _graph[current] = nil
            for _, candidate in ipairs(candidates) do
                for k, v in pairs(_graph) do
                    if list.find_first(v, candidate) then
                        goto continue
                    end
                end
                to_visit[#to_visit + 1] = candidate
                ::continue::
            end
        end
    end
    return ret
end

local function paths_between_dynamic(graph, a, b)
    local to_visit = sorted_nodes(graph, a)
    local num_paths = { }
    num_paths[a] = 1
    for _, node in ipairs(to_visit) do
        if node == b then
            return num_paths[node]
        end
        for _, next in ipairs(graph[node]) do
            if num_paths[next] == nil then
                num_paths[next] = 0
            end
            num_paths[next] = num_paths[next] + num_paths[node]
        end
    end
end

local function task01(graph)
    return paths_between(graph, "you", "out")
end

local function task01_dynamic(graph)
    return paths_between_dynamic(graph, "you", "out")
end

local function task02(graph)
    local num_found = 0
    local dfs
    local visited = {}

    dfs = function(current)
        if current == "out" then
            if visited["dac"] == true and visited["fft"] == true then
                num_found = num_found + 1
            end
            return
        end
        if graph[current] == nil then return end
        for _, next in ipairs(graph[current]) do
            visited[next] = true
            dfs(next)
            visited[next] = false
        end
    end
    dfs("svr")
    return num_found
end

local function task02_dynamic(graph) 
    local a = paths_between_dynamic(graph, "svr", "fft")
    local b = paths_between_dynamic(graph, "fft", "dac")
    local c = paths_between_dynamic(graph, "dac", "out")

    return a * b * c
end

local lines = util.lines_from(arg[1])
local graph = build_graph(lines)

util.aocTask(11, 1, task01, graph)
util.aocTask(11, 1, task01_dynamic, graph)
util.aocTask(11, 1, task02_dynamic, graph)
