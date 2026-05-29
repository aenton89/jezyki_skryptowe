-- plansza: siatka, kolizje, blokowanie klocków, usuwanie linii
local Pieces = require("pieces")

local Board = {}
Board.__index = Board

local COLS = 10
local ROWS = 20

Board.COLS = COLS
Board.ROWS = ROWS



function Board.new()
    -- dzięki temu jeśli nie znajdzie w self, szuka w Board (?)
    local self = setmetatable({}, Board)
    self.grid = {}
    self:clear()
    return self
end

function Board:clear()
    for r = 1, ROWS do
        self.grid[r] = {}
    end
end

-- sprawdza czy klocek (z opcjonalnymi przesunięciami dx, dy i zmianą rotacji drot), koliduje z planszą lub wychodzi poza nią
function Board:collides(piece, dx, dy, drot)
    dx = dx or 0
    dy = dy or 0
    drot = drot or 0

    local rot_count = Pieces.rot_count(piece)
    local new_rot = (piece.rot - 1 + drot) % rot_count + 1
    local mat = Pieces.DEFS[piece.type].rots[new_rot]
    local nx = piece.x + dx
    local ny = piece.y + dy

    for r = 1, 4 do
        for c = 1, 4 do
            if mat[r][c] == 1 then
                local bc = nx + c
                local br = ny + r

                if bc < 1 or bc > COLS then 
                    return true 
                end
                if br > ROWS then 
                    return true 
                end
                if br >= 1 and self.grid[br][bc] then 
                    return true 
                end
            end
        end
    end
    return false
end

-- zapisuje klocek po wylądowaniu
function Board:lock(piece)
    local mat = Pieces.get_matrix(piece)
    local color = Pieces.get_color(piece)
    
    for r = 1, 4 do
        for c = 1, 4 do
            if mat[r][c] == 1 then
                local br = piece.y + r
                local bc = piece.x + c
                if br >= 1 and br <= ROWS and bc >= 1 and bc <= COLS then
                    self.grid[br][bc] = {color[1], color[2], color[3]}
                end
            end
        end
    end
end

-- usuwa pełne linie; zwraca liczbę usuniętych
function Board:clear_lines()
    local count = 0
    local r = ROWS

    while r >= 1 do
        local full = true
        for c = 1, COLS do
            if not self.grid[r][c] then 
                full = false
                break 
            end
        end

        if full then
            table.remove(self.grid, r)
            table.insert(self.grid, 1, {})
            
            for c = 1, COLS do 
                self.grid[1][c] = nil 
            end
            count = count + 1
            -- bez dekrementacji r - sprawdza tą samą pozycję po przesunięciu
        else
            r = r - 1
        end
    end

    return count
end

-- oblicza wiersz docelowy cienia
function Board:ghost_y(piece)
    local gy = piece.y
    while not self:collides(piece, 0, gy - piece.y + 1) do
        gy = gy + 1
    end

    return gy
end

-- próbuje obrócić klocek (+1 = zgodnie z zegarem, -1 = przeciwnie)
function Board:try_rotate(piece, drot)
    -- do sprawdzenia: [dx, dy]
    local kicks = {{0,0}, {-1,0}, {1,0}, {-2,0}, {2,0}, {0,-1}}

    for _, k in ipairs(kicks) do
        if not self:collides(piece, k[1], k[2], drot) then
            piece.x = piece.x + k[1]
            piece.y = piece.y + k[2]
            local n = Pieces.rot_count(piece)
            piece.rot = (piece.rot - 1 + drot) % n + 1
            
            return true
        end
    end
    
    return false
end

return Board