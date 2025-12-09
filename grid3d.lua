local grid3d = {}

local Index = {}
Index.__index = {}

function Index.new(x, y, z)
    return setmetatable({x = x, y = y, z = z}, Index)
end

function Index:copy()
    return setmetatable({x = self.x, y = self.y, z = self.z}, Index)
end

function Index.__eq(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z
end

function Index.__tostring(self)
    return string.format("[%d, %d, %d]", self.x, self.y, self.z)
end

function Index:to_key()
    return string.format("%d,%d,%d", self.x, self.y, self.z)
end

function Index:dist_euclidean(other)
    return math.sqrt((other.x - self.x)^2 + (other.y - self.y)^2 + (other.z - self.z)^2)
end

grid3d.Index = Index

return grid3d