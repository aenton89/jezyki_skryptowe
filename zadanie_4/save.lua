-- zapis i odczyt stanu gry przez love.filesystem (w %APPDATA%/LOVE/zadanie_4/)
local Pieces = require("pieces")

local Save = {}

local SAVE_FILE = "savegame.lua"
local HIGHSCORE_FILE = "highscore.lua"



-- zamienia tabelę na stringa z kodem Lua który można wczytać przez load()
local function serialize(v)
    if type(v) == "table" then
        local s = "{"
        for i, val in ipairs(v) do
            s = s .. serialize(val) .. ","
        end
        for k, val in pairs(v) do
            if type(k) == "string" then
                s = s .. k .. "=" .. serialize(val) .. ","
            end
        end
        return s .. "}"
    elseif type(v) == "boolean" then
        return tostring(v)
    else
        return tostring(v)
    end
end

local function write_file(filename, data_str)
    love.filesystem.write(filename, "return " .. data_str .. "\n")
end

local function read_file(filename)
    if not love.filesystem.getInfo(filename) then
        return nil
    end

    local content, err = love.filesystem.read(filename)
    if not content then
        return nil
    end

    local fn, err2 = load(content)
    if not fn then
        return nil
    end

    -- wywołuje funkcje w trybie chronionym i sprawdza czy rzuca błąd
    local ok, result = pcall(fn)
    if not ok then
        return nil
    end

    return result
end



function Save.load_highscore()
    local data = read_file(HIGHSCORE_FILE)
    if data and type(data) == "number" then
        return data
    end
    return 0
end

function Save.save_highscore(score)
    write_file(HIGHSCORE_FILE, tostring(score))
end

function Save.save_state(game)
    local grid_data = {}
    for r = 1, #game.board.grid do
        grid_data[r] = {}
        for c = 1, 10 do
            local cell = game.board.grid[r][c]
            if cell then
                grid_data[r][c] = {cell[1], cell[2], cell[3]}
            else
                grid_data[r][c] = false
            end
        end
    end

    local data = {
        score = game.score,
        lines = game.lines,
        level = game.level,
        grid = grid_data,
        current = {
            type = game.current.type,
            rot = game.current.rot,
            x = game.current.x,
            y = game.current.y,
        },
        next_type = game.next_pieces[1],
        hold_piece = game.hold_piece,
        hold_used = game.hold_used,
        bag = game.bag,
    }

    local ok, err = pcall(function() write_file(SAVE_FILE, serialize(data)) end)

    return ok, err
end

function Save.load_state(game)
    local data = read_file(SAVE_FILE)
    if not data then
        return false, "no save file"
    end

    -- przywróć planszę
    for r = 1, #data.grid do
        game.board.grid[r] = {}
        for c = 1, 10 do
            local cell = data.grid[r][c]
            if cell and cell ~= false then
                game.board.grid[r][c] = {cell[1], cell[2], cell[3]}
            else
                game.board.grid[r][c] = nil
            end
        end
    end

    -- i stan gry
    game.score = data.score
    game.lines = data.lines
    game.level = data.level
    game.current = {
        type = data.current.type,
        rot = data.current.rot,
        x = data.current.x,
        y = data.current.y,
    }
    game.next_pieces = {data.next_type}
    game.hold_piece = data.hold_piece
    game.hold_used = data.hold_used
    game.bag = data.bag

    -- i reset 
    game.fall_timer = 0
    game.lock_timer = 0
    game.on_ground = false
    game.last_soft = false
    game.game_over = false
    game.paused = false

    return true
end

function Save.delete_save()
    if love.filesystem.getInfo(SAVE_FILE) then
        love.filesystem.remove(SAVE_FILE)
    end
end

function Save.exists()
    return love.filesystem.getInfo(SAVE_FILE) ~= nil
end



return Save