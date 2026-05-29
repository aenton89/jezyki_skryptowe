-- input z DAS (Delayed Auto Shift) i ARR (Auto Repeat Rate)
local Input = {}
Input.__index = Input

-- w sekundach (zanim zacznie się auto-repeat, między krokami i odpowiedniki dla rotacji)
local DAS = 0.20
local ARR = 0.05
local ROT_DAS = 0.20
local ROT_ARR = 0.15

local KEYS = {
    left = {"left", "a"},
    right = {"right", "d"},
    down = {"down", "s"},
    rot_cw = {"up", "w", "x"},
    rot_ccw = {"z"},
    hard = {"space"},
    hold = {"c", "lshift"},
    pause = {"p", "escape"},
    restart = {"r"},
}



function Input.new()
    local self = setmetatable({}, Input)
    -- stan każdej akcji
    self.state = {}
    for action in pairs(KEYS) do
        self.state[action] = {
            held = false,
            das_timer = 0,
            arr_timer = 0,
        }
    end
    return self
end

-- czy którykolwiek z klawiszy dla danej akcji jest wciśnięty
local function any_down(action_keys)
    -- ipairs to pairs, ale dla tablic indeksowanych liczbami (zwróci 1 "left", 2 "a")
    for _, k in ipairs(action_keys) do
        if love.keyboard.isDown(k) then 
            return true 
        end
    end
    return false
end

function Input.keys_for(action)
    return KEYS[action]
end

-- aktualizuj stan + DAS/ARR; zwraca tabelę akcji, które powinny się wykonać w tej klatce
function Input:update(dt)
    local actions = {}

    for action, keys in pairs(KEYS) do
        local s = self.state[action]
        local now = any_down(keys)

        -- nowe wciśnięcie
        if now and not s.held then
            s.held = true
            s.das_timer = 0
            s.arr_timer = 0
            -- natychmiastowe jedno wykonanie
            actions[action] = 1

        -- puszczenie
        elseif not now and s.held then
            s.held = false
            s.das_timer = 0
            s.arr_timer = 0

        -- przytrzymanie
        elseif now and s.held then
            -- soft drop: game.lua kontroluje tempo przez SOFT_DROP_FACTOR, więc wystarczy sam sygnał że klawisz jest wciśnięty
            if action == "down" then
                actions[action] = 1
            -- obsługa DAS/ARR
            else
                local das = (action == "rot_cw" or action == "rot_ccw") and ROT_DAS or DAS
                local arr = (action == "rot_cw" or action == "rot_ccw") and ROT_ARR or ARR

                s.das_timer = s.das_timer + dt
                if s.das_timer >= das then
                    s.arr_timer = s.arr_timer + dt
                    if arr == 0 then
                        actions[action] = 999
                    else
                        local reps = math.floor(s.arr_timer / arr)
                        if reps > 0 then
                            s.arr_timer = s.arr_timer - reps * arr
                            actions[action] = reps
                        end
                    end
                end
            end
        end
    end

    return actions
end



return Input