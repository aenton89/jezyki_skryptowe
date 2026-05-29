local Game = require("game")
local Draw = require("draw")

local game



function love.load()
    love.window.setTitle("TETRIS")
    love.window.setMode(Draw.WIN_W, Draw.WIN_H, {
        resizable = false,
        vsync = true,
    })
    
    love.graphics.setDefaultFilter("nearest", "nearest")

    game = Game.new()
end

function love.update(dt)
    dt = math.min(dt, 0.10)
    game:update(dt)
end

function love.draw()
    Draw.draw(game)
end

function love.keypressed(key)
    game:keypressed(key)
end