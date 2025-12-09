local grid2d = {}

local list = require("list")

local Neighbors = {
    North = {},
    NorthEast = {},
    East = {},
    SouthEast = {},
    South = {},
    SouthWest = {},
    West = {},
    NorthWest = {},
}

function Neighbors.list_4()
    return { Neighbors.North, Neighbors.East, Neighbors.South, Neighbors.West }
end

function Neighbors.list_8()
    return {
        Neighbors.North,
        Neighbors.NorthEast,
        Neighbors.East,
        Neighbors.SouthEast,
        Neighbors.South,
        Neighbors.SouthWest,
        Neighbors.West,
        Neighbors.NorthWest
    }
end

local Index = {}
Index.__index = Index

function Index.new(row, col)
    return setmetatable({ row = row, col = col }, Index)
end

function Index.from_line(line)
    return Index.new(table.unpack(list.from_string(line, ",", tonumber)))
end

function Index:copy()
    return setmetatable({ row = self.row, col = self.col }, Index)
end

function Index.__eq(a, b)
    return a.row == b.row and a.col == b.col
end

function Index.__tostring(i)
    return string.format("[%.2f, %.2f]", i.row, i.col)
end

function Index:neighbor(neighbor)
    if neighbor == Neighbors.North then
        return Index.new(self.row - 1, self.col)
    elseif neighbor == Neighbors.NorthEast then
        return Index.new(self.row - 1, self.col + 1)
    elseif neighbor == Neighbors.East then
        return Index.new(self.row, self.col + 1)
    elseif neighbor == Neighbors.SouthEast then
        return Index.new(self.row + 1, self.col + 1)
    elseif neighbor == Neighbors.South then
        return Index.new(self.row + 1, self.col)
    elseif neighbor == Neighbors.SouthWest then
        return Index.new(self.row + 1, self.col - 1)
    elseif neighbor == Neighbors.West then
        return Index.new(self.row, self.col - 1)
    elseif neighbor == Neighbors.NorthWest then
        return Index.new(self.row - 1, self.col - 1)
    else
        assert(false, "Invalid Neighbor")
    end
end

local Grid = {}
Grid.__index = Grid

local function to_linear_index(grid, index)
    return index.row * grid.cols + index.col + 1
end

function Grid.from_lines(lines, entry_from_char)
    local self = {
        rows = #lines,
        cols = #lines[1]
    }
    for row = 1, #lines do
        local line = lines[row]
        assert(#line == self.cols, "Input Grid has lines of unequal length")
        for col = 1, #line do
            local c = string.sub(line, col, col)
            self[to_linear_index(self, Index.new(row - 1, col - 1))] = entry_from_char(c)
        end
    end
    return setmetatable(self, Grid)
end

function Grid:contains(index)
    return index.row >= 0 and index.col >= 0 and index.row < self.rows and index.col < self.cols
end

function Grid:at(index)
    return self[to_linear_index(self, index)]
end

function Grid:set(index, value)
    self[to_linear_index(self, index)] = value
end

function Grid:iterator()
    local current = Index.new(0, 0)
    return function()
        if (not self:contains(current)) then return nil end
        local idx, ret = current:copy(), self:at(current)
        current.col = current.col + 1
        if (current.col == self.cols) then
            current.row = current.row + 1
            current.col = 0
        end
        return idx, ret
    end
end

function Grid.__tostring(g)
    local ret = ""
    for row = 0, g.rows - 1 do
        local line = ""
        for col = 0, g.cols - 1 do
            line = line .. tostring(g:at(Index.new(row, col)))
        end
        ret = ret .. line .. "\n"
    end
    return ret
end

local SparseGrid = {}
SparseGrid.__index = SparseGrid

function SparseGrid.from_points(points)
    local min = points[1]:copy()
    local max = points[1]:copy()
    local set = {}
    for _, point in ipairs(points) do
        min.row = math.min(min.row, point.row)
        min.col = math.min(min.col, point.col)
        max.row = math.max(max.row, point.row)
        max.col = math.max(max.col, point.col)
        set[tostring(point)] = true
    end

    return setmetatable({ min = min, max = max, points = set }, SparseGrid)
end

function SparseGrid.empty()
    return setmetatable({points = {}}, SparseGrid)
end

function SparseGrid:add(point)
    if self.min == nil then
        self.min = point:copy()
        self.max = point:copy()
    else 
    self.min.row = math.min(self.min.row, point.row)
    self.min.col = math.min(self.min.col, point.col)
    self.max.row = math.max(self.max.row, point.row)
    self.max.col = math.max(self.max.col, point.col)
    end
    self.points[tostring(point)] = true
end

function SparseGrid:contains(point)
    return self.points[tostring(point)] == true
end

function SparseGrid.__tostring(self)
    local ret = ""
    for row = self.min.row,self.max.row do
        for col = self.min.col,self.max.col do
            local idx = Index.new(row, col)
            if(self.points[tostring(idx)] == true) then
                ret = ret .. "#"
            else
                ret = ret .. "."
            end
        end
        ret = ret .. "\n"
    end
    return ret
end

grid2d.Neighbors = Neighbors
grid2d.Index = Index
grid2d.Grid = Grid
grid2d.SparseGrid = SparseGrid

return grid2d
