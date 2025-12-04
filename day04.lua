local util = require("util")
local grid2d = require("grid2d")

local Tile = {
    Empty = util.printable_enum("."),
    Roll = util.printable_enum("@"),
    Accessible = util.printable_enum("x")
}

local function tile_from_char(c)
    if c == Tile.Empty.repr then
        return Tile.Empty
    elseif c == Tile.Roll.repr then
        return Tile.Roll
    else
        assert(false, "Not representable enum value: " .. c)
    end
end

local function find_accessible_rolls(grid)
    local neighbors = grid2d.Neighbors.list_8()
    local accessible_rows = {}
    for idx, tile in grid:iterator() do
        if tile == Tile.Roll then
            local surroundingRolls = 0
            for _, n in ipairs(neighbors) do
                local n_idx = idx:neighbor(n)
                local n_tile = grid:at(n_idx)
                if grid:contains(n_idx) and n_tile == Tile.Roll then
                    surroundingRolls = surroundingRolls + 1
                end
            end
            if surroundingRolls < 4 then
                accessible_rows[#accessible_rows + 1] = idx:copy()
            end
        end
    end
    return accessible_rows
end

local function task01(grid)
    return #find_accessible_rolls(grid)
end

local function task02(grid)
    local accessible_rolls = find_accessible_rolls(grid)
    local removed_rolls = 0
    while #accessible_rolls > 0 do
        removed_rolls = removed_rolls + #accessible_rolls
        for _, idx in ipairs(accessible_rolls) do
            grid:set(idx, Tile.Empty)
        end
        accessible_rolls = find_accessible_rolls(grid)
    end
    return removed_rolls
end


local input = util.lines_from(arg[1])
local grid = grid2d.Grid.from_lines(input, tile_from_char)

util.aocTask(4, 1, task01, grid)
util.aocTask(4, 2, task02, grid)
