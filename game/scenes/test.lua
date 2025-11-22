--[[
    Test file you can and should remove this :)
]]

--- @module game.scenes.test
--- @description Test scene, remove it or use it for testing things?

local test = {}

local test_module = require("test.some_module")
if test_module then
    print(test_module.message)
end

function test:load()
    print("Test scene loaded") 
end

function test:update(dt)
    if engine.input.is_key_pressed("backspace") then
        print("SWITCHING TO TITLE")
        engine.scene.switch("title")
    end
end

function test:draw()
    for x = 0, 20 do
        engine.draw.line({ x1 = x * 32, y1 = 0, x2 = x * 32, y2 = 720, r = 80, g = 80, b = 80 })
    end
    for y = 0, 22 do
        engine.draw.line({ x1 = 0, y1 = y * 32, x2 = 1280, y2 = y * 32, r = 80, g = 80, b = 80 })
    end

    engine.draw.rect({ x = 100, y = 100, w = 64, h = 64, r = 255, g = 0, b = 0 })
    engine.draw.rect({ x = 200, y = 100, w = 64, h = 64, r = 0, g = 255, b = 0 })
    engine.draw.rect({ x = 300, y = 100, w = 64, h = 64, r = 0, g = 0, b = 255 })

    engine.draw.rect_lines({ x = 400, y = 100, w = 64, h = 64, r = 255, g = 255, b = 0 })

    engine.draw.circle({ x = 450, y = 200, radius = 20, r = 255, g = 255, b = 0 })
    engine.draw.circle({ x = 520, y = 200, radius = 20, r = 255, g = 0, b = 255 })
    engine.draw.circle({ x = 590, y = 200, radius = 20, r = 0, g = 255, b = 255 })

    engine.draw.circle_lines({ x = 660, y = 200, radius = 20, r = 200, g = 200, b = 200 })

    engine.draw.triangle({ x1 = 100, y1 = 350, x2 = 150, y2 = 450, x3 = 50, y3 = 450, r = 100, g = 200, b = 100 })

    engine.draw.triangle_lines({ x1 = 250, y1 = 350, x2 = 300, y2 = 450, x3 = 200, y3 = 450, r = 200, g = 100, b = 200 })

    engine.draw.ellipse({ x = 400, y = 400, rx = 40, ry = 20, r = 150, g = 150, b = 255 })

    engine.draw.polygon({ x = 600, y = 400, sides = 6, radius = 30, rotation = 0, r = 200, g = 150, b = 50 })

    engine.draw.text({ text = "TEST SCENE - All Draw Functions", x = 100, y = 550, size = 20, r = 255, g = 255, b = 255 })
end

function test:unload()
    print("Test scene unloaded")
end

return test