--[[
    Test file you can and should remove this :)
]]

local test_draw = {}

function test_draw:load()
    print("Draw test scene loaded")
    
    local w, h = engine.window.get_size()
    self.center_x = w / 2

    self.theme = engine.ui.style.get_theme() 
end

function test_draw:update(dt)
    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function test_draw:draw()
    local w, h = engine.window.get_size()
    local center_x = w / 2
    local text_col_x = center_x - 300
    
    local grid_colour = self.theme.bg_grid or {80, 80, 80, 255}
    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local accent1 = self.theme.accent
    local accent2 = self.theme.accent2
    local accent3 = self.theme.accent3
    local highlight_yellow = {255, 255, 0, 255}
    local highlight_magenta = {255, 0, 255, 255}
    local highlight_cyan = {0, 255, 255, 255}
    local custom_green = {100, 200, 100, 255}
    local custom_purple = {200, 100, 200, 255}
    local custom_blue = {150, 150, 255, 255}
    local custom_gold = {200, 150, 50, 255}
    local custom_gray = {200, 200, 200, 255}

    engine.draw.clear({ colour = self.theme.bg_main })

    for x = 0, 20 do
        engine.draw.line({ x1 = x * 32, y1 = 0, x2 = x * 32, y2 = 720, colour = grid_colour })
    end
    for y = 0, 22 do
        engine.draw.line({ x1 = 0, y1 = y * 32, x2 = 1280, y2 = y * 32, colour = grid_colour })
    end

    engine.draw.rect({ x = 100, y = 100, w = 64, h = 64, colour = accent3 })
    engine.draw.rect({ x = 200, y = 100, w = 64, h = 64, colour = custom_green })
    engine.draw.rect({ x = 300, y = 100, w = 64, h = 64, colour = custom_blue })

    engine.draw.rect_lines({ x = 400, y = 100, w = 64, h = 64, colour = highlight_yellow })

    engine.draw.circle({ x = 450, y = 200, radius = 20, colour = highlight_yellow })
    engine.draw.circle({ x = 520, y = 200, radius = 20, colour = highlight_magenta })
    engine.draw.circle({ x = 590, y = 200, radius = 20, colour = highlight_cyan })

    engine.draw.circle_lines({ x = 660, y = 200, radius = 20, colour = custom_gray })

    engine.draw.triangle({ x1 = 100, y1 = 350, x2 = 150, y2 = 450, x3 = 50, y3 = 450, colour = custom_green })

    engine.draw.triangle_lines({ x1 = 250, y1 = 350, x2 = 300, y2 = 450, x3 = 200, y3 = 450, colour = custom_purple })

    engine.draw.ellipse({ x = 400, y = 400, rx = 40, ry = 20, colour = custom_blue })

    engine.draw.polygon({ x = 600, y = 400, sides = 6, radius = 30, rotation = 0, colour = custom_gold })

    engine.draw.text({ text = "TEST DRAW", x = text_col_x, y = 550, size = 20, colour = accent1 })
    engine.draw.text({ text = "Press ESC to return", x = text_col_x, y = 580, size = 16, colour = text_secondary })
end

function test_draw:unload()
    print("Draw test scene unloaded")
end

return test_draw