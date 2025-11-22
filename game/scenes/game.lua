--[[
    Test file you can and should remove this :)
]]

local game = {}

function game:load()
    print("Game scene loaded") 
end

function game:update(dt)
    if engine.input.is_key_pressed("backspace") then
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