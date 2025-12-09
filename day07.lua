local util = require("util")
local list = require("list")

local TachyonField = {}
TachyonField.__index = TachyonField

function TachyonField.from_input(input)
    local s, _ = list.find_first(list.from_chars(input[1]), function(c) return c == "S" end)
    local splitters = {}
    for i = 3, #input, 2 do
        splitters[#splitters + 1] = list.find_all(list.from_chars(input[i]), function(c) return c == "^" end)
    end
    return setmetatable({
        rows = #input,
        cols = #input[1],
        start = s,
        splitters = splitters
    }, TachyonField)
end

function TachyonField.__tostring(self)
    local empty_line = string.rep(".", self.cols)
    local ret = util.replace_char(empty_line, self.start, "S")
    if self.beams ~= nil then
        ret = ret ..
        "\n" ..
        util.replace_chars_individually(empty_line, list.from_set(self.beams[1]),
            list.from_set_values(self.beams[1]))
    else
        ret = ret .. "\n" .. empty_line
    end
    for i = 2, (self.rows / 2) do
        local line = util.replace_chars(empty_line, self.splitters[i - 1], "^")
        local filler = empty_line
        if self.beams ~= nil then
            local beam_indices = list.from_set(self.beams[i])
            local beam_values = list.from_set_values(self.beams[i])
            line = util.replace_chars_individually(line, beam_indices, beam_values)
            filler = util.replace_chars_individually(filler, beam_indices, beam_values)
        end
        ret = ret .. "\n" .. line .. "\n" .. filler
    end
    return ret
end

function TachyonField:send_beam()
    local beams = { { [self.start] = 1 } }
    local splits_taken = {}
    for i, splitters in ipairs(self.splitters) do
        local current_beams = {}
        local current_splits_taken = {}
        for _, splitter in ipairs(splitters) do
            if beams[#beams][splitter] ~= nil then
                local incoming_beams = beams[#beams][splitter]
                current_splits_taken[#current_splits_taken + 1] = splitter

                local left = current_beams[splitter - 1]
                if left ~= nil then
                    left = left + incoming_beams
                else
                    left = incoming_beams
                end

                local right = current_beams[splitter + 1]
                if right ~= nil then
                    right = right + incoming_beams
                else
                    right = incoming_beams
                end
                current_beams[splitter - 1] = left
                current_beams[splitter + 1] = right
            end
        end
        for beam, val in pairs(beams[#beams]) do
            if list.find_first(splitters, function(splitter) return splitter == beam end) == nil then
                if current_beams[beam] == nil then
                    current_beams[beam] = val
                else
                    current_beams[beam] = current_beams[beam] + val
                end
            end
        end
        beams[#beams + 1] = current_beams
        splits_taken[#splits_taken + 1] = current_splits_taken
    end
    return beams, splits_taken
end

local function task01(splits_taken)
    return list.accumulate(splits_taken, 0, function(a, b) return a + #b end)
end

local function task02(beams)
    local ret = 0
    for _, v in pairs(beams[#beams]) do
        ret = ret + v
    end
    return ret
end

local input = util.lines_from(arg[1])

local field = TachyonField.from_input(input)
local beams, splits_taken = field:send_beam()

util.aocTask(7, 1, task01, splits_taken)
util.aocTask(7, 2, task02, beams)

field.beams = beams
field.splitts_taken = splits_taken
-- now the field is printable with split numbers
