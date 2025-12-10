local range = {}

local list = require("list")

local Inclusive = {}
Inclusive.__index = Inclusive

function Inclusive.new(min, max)
    return setmetatable({ min = min, max = max }, Inclusive)
end

function Inclusive:copy()
    return setmetatable({min = self.min, max = self.max}, Inclusive)
end

function Inclusive.from_string(s)
    local limits = list.from_string(s, "-", tonumber)
    return Inclusive.new(limits[1], limits[2])
end

function Inclusive:iterator()
    local i = range.min - 1
    return function()
        i = i + 1
        if i <= range.max then
            return i
        end
    end
end

function Inclusive:contains(value)
    return value >= self.min and value <= self.max
end

function Inclusive:count()
    return self.max - self.min + 1
end

function Inclusive:unite(other)
    -- case 1: other > self
    if other.min <= self.min and other.max >= self.max then return other:copy() end
    -- case 2: self > other
    if self.min <= other.min and self.max >= other.max then return self:copy() end
    -- case 3: overlap with self starting earlier than other
    if self.min <= other.min and self.max >= other.min and self.max <= other.max then return Inclusive.new(self.min, other.max) end
    -- case 4: overlap with other starting earlier than other
    if other.min <= self.min and other.max >= self.min and other.max <= self.max then return Inclusive.new(other.min, self.max) end
    -- case 5: no overlap
    return nil
end

function Inclusive.__tostring(r)
    return string.format("[%d, %d]", r.min, r.max)
end

range.Inclusive = Inclusive

return range