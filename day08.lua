local util = require("util")
local list = require("list")
local grid3d = require("grid3d")

local function build_distances(boxes)
    local distances = {}
    for i = 1, #boxes - 1 do
        for j = i + 1, #boxes do
            distances[#distances + 1] = {
                a = boxes[i],
                b = boxes[j],
                dist = grid3d.Index.dist_euclidean(boxes[i],
                    boxes[j])
            }
        end
    end
    table.sort(distances, function(a, b) return a.dist < b.dist end)
    return distances
end

local function build_circuits(boxes, distances, num_connections)
    local circuits_by_index = {}
    local circuits_by_box = {}
    local num_circuits = 0
    for i = 1, num_connections do
        local dist = distances[i]
        local key_a = tostring(dist.a)
        local key_b = tostring(dist.b)
        local circuit_a = circuits_by_box[key_a]
        local circuit_b = circuits_by_box[key_b]
        if circuit_a == nil and circuit_b == nil then
            num_circuits = num_circuits + 1
            circuits_by_box[key_a] = num_circuits
            circuits_by_box[key_b] = num_circuits
            circuits_by_index[num_circuits] = { dist.a, dist.b }
        end
        if circuit_a == nil and circuit_b ~= nil then
            circuits_by_box[key_a] = circuit_b
            table.insert(circuits_by_index[circuit_b], dist.a)
        end
        if circuit_a ~= nil and circuit_b == nil then
            circuits_by_box[key_b] = circuit_a
            table.insert(circuits_by_index[circuit_a], dist.b)
        end
        if circuit_a ~= nil and circuit_b ~= nil and circuit_a ~= circuit_b then
            -- merge b into a
            for _, box in ipairs(circuits_by_index[circuit_b]) do
                circuits_by_box[tostring(box)] = circuit_a
                table.insert(circuits_by_index[circuit_a], box)
            end
            circuits_by_index[circuit_b] = {}
        end
    end
    table.sort(circuits_by_index, function(a, b) return #a > #b end)
    return circuits_by_index
end

local function build_circuits2(boxes, distances)
    local circuits_by_index = {}
    local circuits_by_box = {}
    local num_circuits = 0
    for i = 1, #distances do
        local dist = distances[i]
        local key_a = tostring(dist.a)
        local key_b = tostring(dist.b)
        local circuit_a = circuits_by_box[key_a]
        local circuit_b = circuits_by_box[key_b]
        if circuit_a == nil and circuit_b == nil then
            num_circuits = num_circuits + 1
            circuits_by_box[key_a] = num_circuits
            circuits_by_box[key_b] = num_circuits
            circuits_by_index[num_circuits] = { dist.a, dist.b }
        end
        if circuit_a == nil and circuit_b ~= nil then
            circuits_by_box[key_a] = circuit_b
            table.insert(circuits_by_index[circuit_b], dist.a)
            if (#circuits_by_index[circuit_b] == #boxes) then
                return dist.a, dist.b
            end
        end
        if circuit_a ~= nil and circuit_b == nil then
            circuits_by_box[key_b] = circuit_a
            table.insert(circuits_by_index[circuit_a], dist.b)
            if (#circuits_by_index[circuit_a] == #boxes) then
                return dist.a, dist.b
            end
        end
        if circuit_a ~= nil and circuit_b ~= nil and circuit_a ~= circuit_b then
            -- merge b into a
            for _, box in ipairs(circuits_by_index[circuit_b]) do
                circuits_by_box[tostring(box)] = circuit_a
                table.insert(circuits_by_index[circuit_a], box)
            end
            circuits_by_index[circuit_b] = {}
            if (#circuits_by_index[circuit_a] == #boxes) then
                return dist.a, dist.b
            end
        end
    end
    table.sort(circuits_by_index, function(a, b) return #a > #b end)
    return circuits_by_index
end

local function task01(boxes, distances, test)
    local num = 1000
    if test then
        num = 10
    end
    local circuits = build_circuits(boxes, distances, 10)
    return #circuits[1] * #circuits[2] * #circuits[3]
end

local function task02(boxes, distances)
    local a, b = build_circuits2(boxes, distances)
    return a.x * b.x
end


local input = util.lines_from(arg[1])
local boxes = list.transform(input, function(line)
    return grid3d.Index.new(table.unpack(list.from_string(line, ",", tonumber)))
end)
local distances = build_distances(boxes)

util.aocTask(8, 1, task01, boxes, distances, false)
util.aocTask(8, 2, task02, boxes, distances)

-- TODO: Remove duplicate for termination function
-- TODO: Check if we are having test input and automatically choose correct number for task 1
