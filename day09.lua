local util = require("util")
local list = require("list")
local grid = require("grid2d")

local AAPolygon = {}
AAPolygon.__index = AAPolygon

local AALine = {}
AALine.__index = AALine

function AALine.new(a, b)
    assert(a.row == b.row or a.col == b.col, "Line must be axis aligned")
    return setmetatable({ a = a, b = b }, AALine)
end

function AALine.__tostring(l)
    return tostring(l.a) .. " - " .. tostring(l.b)
end

function AALine:is_horizontal()
    return self.a.row == self.b.row
end

function AALine:is_vertical()
    return self.a.col == self.b.col
end

function AALine:row_min()
    return math.min(self.a.row, self.b.row)
end

function AALine:row_max()
    return math.max(self.a.row, self.b.row)
end

function AALine:col_min()
    return math.min(self.a.col, self.b.col)
end

function AALine:col_max()
    return math.max(self.a.col, self.b.col)
end

function AALine:intersects(other)
    if self:is_horizontal() then
        if other:is_horizontal() then
            return false
        else
            -- self is horizontal (same row), other is vertical (same col)
            return self:col_min() < other.a.col and other.a.col < self:col_max() and other:row_min() < self.a.row and self.a.row < other:row_max()
        end
    else
        if other:is_vertical() then
            return false
        else
            -- self is vertical (same col), other is horizontal (same row)
            return self:row_min() < other.a.row and other.a.row < self:row_max() and other:col_min() < self.a.col and
            self.a.col < other:col_max()
        end
    end
end

function AAPolygon.new(points)
    local line_segments = {}
    local bb_min = points[#points]:copy()
    local bb_max = points[#points]:copy()
    for i = 1, #points - 1 do
        local p = points[i]
        bb_min.row = math.min(p.row, bb_min.row)
        bb_min.col = math.min(p.col, bb_min.col)
        bb_max.row = math.max(p.row, bb_max.row)
        bb_max.col = math.max(p.col, bb_max.col)
        line_segments[#line_segments + 1] = AALine.new(points[i], points[i + 1])
    end
    line_segments[#line_segments + 1] = AALine.new(points[#points], points[1])
    return setmetatable({ bb_min = bb_min, bb_max = bb_max, line_segments = line_segments, points = points }, AAPolygon)
end

function AAPolygon:num_intersections(line)
    local num_intersections = 0
    --print("Testing: " .. tostring(line))
    for _, test_line in ipairs(self.line_segments) do
        local s = "\t" .. tostring(test_line)
        if test_line:intersects(line) then
            s = s .. " -> YES"
            num_intersections = num_intersections + 1
        else
            s = s .. " -> NO"
        end
        --print(s)
    end
    return num_intersections
end

local function area_between(a, b)
    local d_row = math.abs(b.row - a.row) + 1
    local d_col = math.abs(b.col - a.col) + 1
    return d_row * d_col
end

local function corrected_rect(a, b)
    local min = grid.Index.new(
        math.min(a.row, b.row) + 0.5,
        math.min(a.col, b.col) + 0.5
    )
    local max = grid.Index.new(
        math.max(a.row, b.row) - 0.5,
        math.max(a.col, b.col) - 0.5
    )
    return { min = min, max = max }
end

-- TODO: Integrate into better structure
local cache = {}

local function get_intersection_numbers(point, poly)
    local value = cache[tostring(point)]
    if value == nil then
        local right = grid.Index.new(point.row, poly.bb_max.col + 1)
        local bottom = grid.Index.new(poly.bb_max.row + 1, point.col)
        local horizontal_intersections = poly:num_intersections(AALine.new(point, right))
        local vertical_intersections = poly:num_intersections(AALine.new(point, bottom))
        value = {horizontal = horizontal_intersections, vertical = vertical_intersections}
        cache[tostring(point)] = value
    end
    return value
end

local function is_valid(corrected_rect, polygon)
    local top_left = corrected_rect.min
    local top_right = grid.Index.new(corrected_rect.min.row, corrected_rect.max.col)
    local bottom_left = grid.Index.new(corrected_rect.max.row, corrected_rect.min.col)
    local bottom_right = corrected_rect.max

    local num_top_left = get_intersection_numbers(top_left, polygon)
    local num_top_right = get_intersection_numbers(top_right, polygon)
    local num_bottom_left = get_intersection_numbers(bottom_left, polygon)
    local num_bottom_right = get_intersection_numbers(bottom_right, polygon)

    local top_ok = (num_top_left.horizontal == num_top_right.horizontal) and num_top_left.horizontal % 2 == 1
    local bot_ok = (num_bottom_left.horizontal == num_bottom_right.horizontal) and num_bottom_left.horizontal % 2 == 1
    local left_ok = (num_top_left.vertical == num_bottom_left.vertical) and num_top_left.vertical % 2 == 1
    local right_ok = (num_top_right.vertical == num_bottom_right.vertical) and num_top_right.vertical % 2 == 1

    return top_ok and bot_ok and left_ok and right_ok
end

local function task01(points)
    local max_area = 0
    for i = 1, #points - 1 do
        for j = i + 1, #points do
            local area = area_between(points[i], points[j])
            if area > max_area then
                max_area = area
            end
        end
    end
    return max_area
end

local function task02(points)
    local poly = AAPolygon.new(points)
    local max_area = 0
    for i = 1, #points - 1 do
        for j = i + 1, #points do
            local a = points[i]
            local b = points[j]
            local area = area_between(points[i], points[j])
            if a.row ~= b.row and a.col ~= b.col and area > max_area then 
                local rect = corrected_rect(a, b)
                if is_valid(rect, poly) then
                    max_area = area
                end
            end
        end
    end
    return max_area
end

local lines = util.lines_from(arg[1])
local points = list.transform(lines, grid.Index.from_line)

util.aocTask(9, 1, task01, points)
util.aocTask(9, 2, task02, points)
