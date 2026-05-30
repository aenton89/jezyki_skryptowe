-- efekty dźwiękowe
local Audio = {}

local sounds = {}

local FILES = {
    lock = "sounds/677861__el_boss__ui-button-click.wav",
    clear = "sounds/779817__kenneth_cooney__success2.wav",
    tetris = "sounds/609336__kenneth_cooney__completed.wav",
    harddrop = "sounds/743670__qubodup__finger-snap-fail.wav",
    -- rotate = "sounds/rotate.wav",
    hold = "sounds/365672__mikala_oidua__retro-game-sfx_jump-bump.wav",
    gameover = "sounds/404743__owlstorm__retro-video-game-sfx-fail.wav",
}



function Audio.load()
    for name, path in pairs(FILES) do
        -- pcall żeby brakujący plik nie crashował gry
        local ok, src = pcall(love.audio.newSource, path, "static")
        if ok then
            sounds[name] = src
        end
    end
end

local function play(name)
    local s = sounds[name]
    if not s then 
        return 
    end
    local clone = s:clone()
    clone:play()
end

function Audio.lock()
    play("lock")
end

-- function Audio.rotate()
--     play("rotate")
-- end

function Audio.harddrop() 
    play("harddrop") 
end

function Audio.hold()
    play("hold")
end
function Audio.gameover() 
    play("gameover") 
end

function Audio.clear(lines)
    if lines >= 4 then
        play("tetris")
    else
        play("clear")
    end
end



return Audio