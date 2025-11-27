--[[
    Test file you can and should remove this :)
]]

--- @module game.scenes.game
--- @description Example api for a game screen, shows switching to title screen using input press.

local game = {}

function game:load()
    print("Game scene loaded") 
end

function game:update(dt)
    if engine.keyboard.is_pressed("backspace") then
        print("SWITCHING TO TITLE")
        engine.scene.switch("title")
    end
end

function game:draw()
end

function game:unload()
    print("Game scene unloaded")
end

return game