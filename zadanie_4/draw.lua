-- kod rysowania: plansza, klocki, cień, panel boczny
local Pieces = require("pieces")
local Board = require("board")
local Save = require("save")

local Draw = {}

-- układ ekranu
local CELL = 30
-- odległość planszy od krawędzi okna
local BOARD_X = 20
local BOARD_Y = 20
local COLS = Board.COLS
local ROWS = Board.ROWS

-- panel boczny
local PANEL_X = BOARD_X + COLS * CELL + 20

-- wymiary okna
Draw.WIN_W = PANEL_X + 220
Draw.WIN_H = BOARD_Y + ROWS * CELL + 20

-- koloru UI
local C = {
    bg = {0.07, 0.07, 0.11},
    grid = {0.14, 0.14, 0.20},
    border = {0.45, 0.45, 0.58},
    panel_bg = {0.10, 0.10, 0.16},
    label = {0.50, 0.50, 0.62},
    value = {0.95, 0.95, 1.00},
    -- alpha wypełnenia cienia i obramowania cienia
    ghost_a = 0.18,
    ghost_ol = 0.45,
    -- przyciemnienie klocka w hold'zie
    hold_dim = 0.40,
}



local function setc(col, a)
    love.graphics.setColor(col[1], col[2], col[3], a or 1)
end

local function setrgb(r, g, b, a)
    love.graphics.setColor(r/255, g/255, b/255, a or 1)
end

local function draw_cell_at(px, py, color, alpha)
    alpha = alpha or 1.0
    local r, g, b = color[1]/255, color[2]/255, color[3]/255

    love.graphics.setColor(r, g, b, alpha)
    love.graphics.rectangle("fill", px+1, py+1, CELL-2, CELL-2)
end

-- rysuje klocek na planszy z offsetu planszy
local function draw_board_cell(col, row, color, alpha)
    local px = BOARD_X + (col-1) * CELL
    local py = BOARD_Y + (row-1) * CELL
    draw_cell_at(px, py, color, alpha)
end

-- rysuje klocek w dowolnym miejscu ekranu (pixel-coords + piece offset)
local function draw_piece_preview(piece, ox, oy, cell_size, alpha, dimmed)
    if not piece then 
        return 
    end

    alpha = alpha or 1.0
    cell_size = cell_size or CELL
    local mat = Pieces.get_matrix(piece)
    local color = Pieces.get_color(piece)
    local a = dimmed and (alpha * C.hold_dim) or alpha

    for r = 1, 4 do
        for c = 1, 4 do
            if mat[r][c] == 1 then
                local px = ox + (c-1) * cell_size
                local py = oy + (r-1) * cell_size
                local r2, g2, b2 = color[1]/255, color[2]/255, color[3]/255

                love.graphics.setColor(r2, g2, b2, a)
                love.graphics.rectangle("fill", px+1, py+1, cell_size-2, cell_size-2)
            end
        end
    end
end

-- wyśrodkowuje i rysuje miniaturę klocka w ramce (ox,oy) o rozmiarze boxW x boxH
local function draw_centered_piece(type_idx, rot, ox, oy, box_w, box_h, cell_size, alpha, dimmed)
    if not type_idx then 
        return 
    end

    local piece = {type=type_idx, rot=rot or 1}
    local mat = Pieces.get_matrix(piece)

    -- policz bounding box klocka
    local min_c, max_c, min_r, max_r = 5, 0, 5, 0
    for r = 1, 4 do
        for c = 1, 4 do
            if mat[r][c] == 1 then
                if c < min_c then 
                    min_c = c 
                end
                if c > max_c then 
                    max_c = c 
                end
                if r < min_r then 
                    min_r = r 
                end
                if r > max_r then 
                    max_r = r 
                end
            end
        end
    end

    local pw = (max_c - min_c + 1) * cell_size
    local ph = (max_r - min_r + 1) * cell_size
    local draw_x = ox + math.floor((box_w - pw) / 2) - (min_c-1) * cell_size
    local draw_y = oy + math.floor((box_h - ph) / 2) - (min_r-1) * cell_size

    draw_piece_preview(piece, draw_x, draw_y, cell_size, alpha, dimmed)
end

-- ramka z tytułem
local function panel_box(x, y, w, h, title)
    setc(C.panel_bg)
    love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    setc(C.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 3, 3)

    if title then
        setc(C.label)
        love.graphics.printf(title, x, y - 18, w, "center")
    end
end

-- metoda do wywołania z love.draw
function Draw.draw(game)
    local board = game.board
    local current = game.current

    local highscore = Save.load_highscore()

    -- background
    setc(C.bg)
    love.graphics.rectangle("fill", 0, 0, Draw.WIN_W, Draw.WIN_H)

    -- siatka planszy
    setc(C.grid)
    love.graphics.setLineWidth(1)
    for r = 0, ROWS do
        love.graphics.line(BOARD_X, BOARD_Y + r*CELL, BOARD_X + COLS*CELL, BOARD_Y + r*CELL)
    end
    for c = 0, COLS do
        love.graphics.line(BOARD_X + c*CELL, BOARD_Y, BOARD_X + c*CELL, BOARD_Y + ROWS*CELL)
    end

    -- zawartość planszy
    local anim_frac = game.anim_timer > 0 and (1 - game.anim_timer / 0.6) or nil
    local clearing_set = {}
    for _, r in ipairs(game.clearing_rows or {}) do
        clearing_set[r] = true
    end

    for r = 1, ROWS do
        for c = 1, COLS do
            if board.grid[r][c] then
                if clearing_set[r] and anim_frac then
                    local white = anim_frac
                    draw_board_cell(c, r, {255*white, 255*white, 255})
                else
                    draw_board_cell(c, r, board.grid[r][c])
                end
            end
        end
    end

    -- cień
    if not game.game_over and not game.paused then
        local gy = board:ghost_y(current)
        local mat = Pieces.get_matrix(current)
        local col = Pieces.get_color(current)
        for r = 1, 4 do
            for c = 1, 4 do
                if mat[r][c] == 1 then
                    local px = BOARD_X + (current.x + c - 1) * CELL
                    local py = BOARD_Y + (gy + r - 1) * CELL
                    setrgb(col[1], col[2], col[3], C.ghost_a)
                    love.graphics.rectangle("fill", px+1, py+1, CELL-2, CELL-2)
                    setrgb(col[1], col[2], col[3], C.ghost_ol)
                    love.graphics.rectangle("line", px+1, py+1, CELL-2, CELL-2)
                end
            end
        end
    end

    -- obecny klocek
    if not game.game_over then
        local mat = Pieces.get_matrix(current)
        local col = Pieces.get_color(current)
        for r = 1, 4 do
            for c = 1, 4 do
                if mat[r][c] == 1 then
                    local br = current.y + r
                    local bc = current.x + c
                    if br >= 1 then
                        draw_board_cell(bc, br, col)
                    end
                end
            end
        end
    end

    -- obramowanie planszy
    setc(C.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", BOARD_X, BOARD_Y, COLS*CELL, ROWS*CELL)
    love.graphics.setLineWidth(1)

    -- boczny panel
    local px = PANEL_X
    local box_w = 90
    local box_h = 70
    local cs_mini = 18
    local gap = 24

    setc(C.label)
    love.graphics.printf("NEXT", px, BOARD_Y - 18, box_w, "center")
    panel_box(px, BOARD_Y, box_w, box_h)
    draw_centered_piece(game.next_pieces[1], 1, px, BOARD_Y, box_w, box_h, cs_mini)

    local hold_y = BOARD_Y + box_h + gap
    setc(C.label)
    love.graphics.printf("HOLD", px, hold_y - 18, box_w, "center")
    panel_box(px, hold_y, box_w, box_h)
    if game.hold_piece then
        draw_centered_piece(
            game.hold_piece, 1,
            px, hold_y, box_w, box_h,
            cs_mini, 1.0,
            game.hold_used
        )
    end

    -- wynik, poziom, linie, highscore
    local info_y = hold_y + box_h + gap + 10
    local iw = box_w

    local function info_row(label, value, y)
        panel_box(px, y, iw, 40)
        setc(C.label)
        love.graphics.printf(label, px, y + 4, iw, "center")
        setc(C.value)
        love.graphics.printf(tostring(value), px, y + 20, iw, "center")
    end

    info_row("SCORE", game.score, info_y)
    info_row("LEVEL", game.level, info_y + 48)
    info_row("LINES", game.lines, info_y + 96)
    info_row("BEST SCORE", highscore, info_y + 144)

    -- instrukcje sterowania
    local col2_px = PANEL_X + box_w + 16
    local ctrl_y = BOARD_Y
    setc(C.label)
    love.graphics.print("CONTROLS", col2_px, ctrl_y)

    love.graphics.setLineWidth(1)
    setc(C.border)
    love.graphics.line(col2_px, ctrl_y + 18, col2_px + 100, ctrl_y + 18)

    local ctrls = {
        {"move", "LEFT RIGHT / A D"},
        {"rotate cw", "UP / W / X"},
        {"rotate ccw", "Z"},
        {"soft drop", "DOWN / S"},
        {"hard drop", "SPACE"},
        {"hold", "C / SHIFT"},
        {"pause", "P / ESC"},
        {"restart", "R"},
        {"save", "1"},
        {"load", "2"},
    }
    for i, row in ipairs(ctrls) do
        setc(C.value)
        love.graphics.print(row[1], col2_px, ctrl_y + 38*(i-1) + 24)
        setc(C.label)
        love.graphics.print(row[2], col2_px, ctrl_y + 38*(i-1) + 40)
    end

    -- komunikaty o pauzie i końcu gry
    if game.game_over then
        love.graphics.setColor(0, 0, 0, 0.72)
        love.graphics.rectangle("fill", BOARD_X, BOARD_Y + ROWS/2*CELL - 55, COLS*CELL, 110)
        love.graphics.setColor(1, 0.18, 0.18)
        love.graphics.printf("GAME OVER", BOARD_X, BOARD_Y + ROWS/2*CELL - 38, COLS*CELL, "center")
        love.graphics.setColor(0.85, 0.85, 0.85)
        love.graphics.printf(string.format("SCORE: %d", game.score), BOARD_X, BOARD_Y + ROWS/2*CELL - 10, COLS*CELL, "center")
        love.graphics.printf("PRESS R TO RESTART", BOARD_X, BOARD_Y + ROWS/2*CELL + 16, COLS*CELL, "center")

    elseif game.paused then
        love.graphics.setColor(0, 0, 0, 0.65)
        love.graphics.rectangle("fill", BOARD_X, BOARD_Y + ROWS/2*CELL - 30, COLS*CELL, 60)
        love.graphics.setColor(1, 1, 0.15)
        love.graphics.printf("PAUSE", BOARD_X, BOARD_Y + ROWS/2*CELL - 10, COLS*CELL, "center")
    end
end

return Draw