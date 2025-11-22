--[[
    Test file you can and should remove this :)
]]

--- @module game.scenes.title
--- @description Example api for a title, shows switching to game screen using input press.

local title = {}

function title:load()
    print("Title scene loaded") 
end

function title:update(dt)

    if engine.keyboard.is_pressed("space") then
        print("SWITCHING TO GAME")
        
        engine.scene.switch("game")
    end

end

function title:draw()
end

function title:unload()
    print("Title scene unloaded")
end

return title