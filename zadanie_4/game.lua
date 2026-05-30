-- logika gry: stan, punktacja, hold, spawnowanie klocków
local Pieces = require("pieces")
local Board = require("board")
local Input = require("input")
local Save = require("save")
local Audio = require("audio")

local Game = {}
Game.__index = Game

-- punkty za zbicie n linii naraz (mnożone przez poziom)
local LINE_POINTS = {100, 300, 500, 800}

-- prędkość opadania (sek/krok) dla poziomów 1-15
local SPEEDS = {
    0.85, 0.72, 0.60, 0.50, 0.40,
    0.32, 0.25, 0.19, 0.14, 0.10,
    0.08, 0.06, 0.05, 0.04, 0.03,
}

-- klocek opada tyle razy szybciej przy przytrzymaniu soft-drop'a
local SOFT_DROP_FACTOR = 20

function Game.new()
    local self = setmetatable({}, Game)
    self.board = Board.new()
    self.input = Input.new()
    self:reset()

    -- autowczyt zapisu przy starcie gry
    -- if Save.exists() then
    --     Save.load_state(self)
    -- end

    Audio.load()

    return self
end

-- 7-bag randomizer
function Game:refill_bag()
    self.bag = {}
    -- # zwraca liczbę elementów
    for i = 1, #Pieces.DEFS do 
        self.bag[i] = i 
    end
    
    for i = #self.bag, 2, -1 do
        local j = love.math.random(i)
        self.bag[i], self.bag[j] = self.bag[j], self.bag[i]
    end
end

function Game:pop_bag()
    if #self.bag == 0 then 
        self:refill_bag() 
    end
    
    return table.remove(self.bag, 1)
end

function Game:reset()
    self.board:clear()
    self.bag = {}
    self:refill_bag()

    self.score = 0
    self.lines = 0
    self.level = 1
    self.game_over = false
    self.paused = false

    self.hold_piece = nil
    self.hold_used = false

    self.next_pieces = {}
    self.next_pieces[1] = self:pop_bag()
    self.current = self:spawn()

    self.last_soft = false

    self.fall_timer = 0
    -- czas stania na podłodze przed zablokowaniem
    self.lock_timer = 0
    self.lock_delay = 0.5
    self.on_ground = false

    -- usuwanie zapisu gry przy restarcie
    -- Save.delete_save()
end

function Game:spawn()
    local t = table.remove(self.next_pieces, 1)
    table.insert(self.next_pieces, self:pop_bag())
    local p = Pieces.new(t)
    if self.board:collides(p, 0, 0) then
        self.game_over = true
        Audio.gameover()
    end

    return p
end

function Game:get_speed()
    return SPEEDS[math.min(self.level, #SPEEDS)]
end

function Game:do_hold()
    -- tylko raz na klocek
    if self.hold_used then 
        return 
    end
    self.hold_used = true
    Audio.hold()

    -- pierwszy hold: odłóż bieżący, pobierz nowy
    if self.hold_piece == nil then
        self.hold_piece = self.current.type
        self.current = self:spawn()
    -- zamień bieżący z holdem
    else
        local tmp = self.hold_piece
        self.hold_piece = self.current.type
        self.current = Pieces.new(tmp)
        
        -- reset pozycji
        self.current.x = 3
        self.current.y = 0
        if self.board:collides(self.current, 0, 0) then
            self.game_over = true
            Audio.gameover()
        end
    end

    self.fall_timer = 0
    self.on_ground = false
    self.lock_timer = 0
end

function Game:hard_drop()
    local gy = self.board:ghost_y(self.current)
    self.score = self.score + 2 * (gy - self.current.y)
    self.current.y = gy
    Audio.harddrop()
    self:land()
end

function Game:land()
    self.board:lock(self.current)
    local cleared = self.board:clear_lines()
    if cleared > 0 then
        Audio.clear(cleared)
        self.score = self.score + LINE_POINTS[cleared] * self.level
        self.lines = self.lines + cleared
        self.level = math.floor(self.lines / 10) + 1
    end

    self.current = self:spawn()
    self.hold_used = false
    self.fall_timer = 0
    self.on_ground = false
    self.lock_timer = 0

    -- auto-zapis
    -- Save.save_state(self)

    if self.score > Save.load_highscore() then
        Save.save_highscore(self.score)
    end
end

-- ruch boczny (wielokrotny dla ARR)
function Game:move_horizontal(dx, times)
    for _ = 1, times do
        if not self.board:collides(self.current, dx, 0) then
            self.current.x = self.current.x + dx
            
            -- reset lock timer przy ruchu
            if self.on_ground then
                self.lock_timer = 0 
            end
        else
            break
        end
    end
end

-- metoda do wywołania z love.update
function Game:update(dt)
    if self.game_over or self.paused then 
        return 
    end

    -- pobierz akcje z inputu
    local acts = self.input:update(dt)

    -- obsługa inputu
    if acts.left then 
        self:move_horizontal(-1, acts.left)
    end
    if acts.right then 
        self:move_horizontal(1, acts.right) 
    end

    if acts.rot_cw then
        for _ = 1, acts.rot_cw do
            if self.board:try_rotate(self.current, 1) then
                -- Audio.rotate()
                if self.on_ground then 
                    self.lock_timer = 0 
                end
                break
            end
        end
    end
    if acts.rot_ccw then
        for _ = 1, acts.rot_ccw do
            if self.board:try_rotate(self.current, -1) then
                -- Audio.rotate()
                if self.on_ground then 
                    self.lock_timer = 0 
                end
                break
            end
        end
    end

    local soft = (acts.down ~= nil)
    local speed = self:get_speed()
    if soft ~= self.last_soft then
        self.fall_timer = 0
        self.last_soft = soft
    end
    if soft then 
        speed = speed / SOFT_DROP_FACTOR 
    end

    -- opadanie
    self.fall_timer = self.fall_timer + dt
    local steps = 0
    while self.fall_timer >= speed do
        self.fall_timer = self.fall_timer - speed
        steps = steps + 1
    end

    for _ = 1, steps do
        if not self.board:collides(self.current, 0, 1) then
            self.current.y = self.current.y + 1
            if soft then 
                self.score = self.score + 1 
            end
            self.on_ground = false
        else
            self.on_ground = true
            break
        end
    end

    -- lock delay
    if self.on_ground then
        self.lock_timer = self.lock_timer + dt
        if self.lock_timer >= self.lock_delay then
            self:land()
            Audio.lock()
        end
    else
        self.lock_timer = 0
    end
end 

-- metoda do wywołania z love.keypressed
-- obsługa tych jednorazowych, te które mogą być auto-repeat w update()
function Game:keypressed(key)
    for _, k in ipairs(Input.keys_for("restart")) do
        if key == k then 
            self:reset()
            return 
        end
    end

    if self.game_over or self.paused then
        for _, k in ipairs(Input.keys_for("pause")) do
            if key == k and not self.game_over then
                self.paused = false
                return
            end
        end
        return
    end

    for _, k in ipairs(Input.keys_for("pause")) do
        if key == k then 
            self.paused = true
            return 
        end
    end

    for _, k in ipairs(Input.keys_for("hard")) do
        if key == k then 
            self:hard_drop()
            return 
        end
    end

    for _, k in ipairs(Input.keys_for("hold")) do
        if key == k then 
            self:do_hold()
            return 
        end
    end

    for _, k in ipairs(Input.keys_for("save")) do
        if key == k then 
            Save.save_state(self)
            return 
        end
    end

    for _, k in ipairs(Input.keys_for("load")) do
        if key == k then 
            Save.load_state(self)
            return 
        end
    end
end



return Game
