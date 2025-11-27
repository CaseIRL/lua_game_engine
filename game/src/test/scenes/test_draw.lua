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
    local header_y = 50
    local text_col_y = 600

    local grid_colour = self.theme.bg_grid or {80, 80, 80, 255}
    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local accent1 = self.theme.accent
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

    for x = 0, 40 do
        engine.draw.line({ x1 = x * 32, y1 = 0, x2 = x * 32, y2 = h, colour = grid_colour })
    end
    for y = 0, 22 do
        engine.draw.line({ x1 = 0, y1 = y * 32, x2 = w, y2 = y * 32, colour = grid_colour })
    end

    local rect_y = 100
    local rect_w, rect_h = 64, 64

    engine.draw.rect({ x = 100, y = rect_y, w = rect_w, h = rect_h, colour = accent3 })
    engine.draw.rect({ x = 200, y = rect_y, w = rect_w, h = rect_h, colour = custom_green })
    engine.draw.rect({ x = 300, y = rect_y, w = rect_w, h = rect_h, colour = custom_blue })

    local rounded_x = 400
    engine.draw.rect({ x = rounded_x, y = rect_y, w = rect_w, h = rect_h, roundness = 0.4, colour = highlight_magenta })
    engine.draw.rect({ x = rounded_x + 100, y = rect_y, w = rect_w, h = rect_h, roundness = 1.0, segments = 0, colour = highlight_cyan })

    engine.draw.rect_lines({ x = rounded_x + 200, y = rect_y, w = rect_w, h = rect_h, colour = highlight_yellow })
    engine.draw.rect_lines({ x = rounded_x + 300, y = rect_y, w = rect_w, h = rect_h, roundness = 0.6, line_thick = 2, colour = custom_gold})

    local circle_y = 250
    engine.draw.circle({ x = 150, y = circle_y, radius = 20, colour = highlight_yellow })
    engine.draw.circle({ x = 220, y = circle_y, radius = 20, colour = highlight_magenta })
    engine.draw.circle({ x = 290, y = circle_y, radius = 20, colour = highlight_cyan })
    engine.draw.circle_lines({ x = 360, y = circle_y, radius = 20, colour = custom_gray })

    engine.draw.ellipse({ x = 480, y = circle_y, rx = 40, ry = 20, colour = custom_blue })

    local shape_y = 400

    engine.draw.triangle({ x1 = 100, y1 = shape_y, x2 = 150, y2 = shape_y + 100, x3 = 50, y3 = shape_y + 100, colour = custom_green })
    engine.draw.triangle_lines({ x1 = 250, y1 = shape_y, x2 = 300, y2 = shape_y + 100, x3 = 200, y3 = shape_y + 100, colour = custom_purple })

    engine.draw.polygon({ x = 450, y = shape_y + 50, sides = 6, radius = 30, rotation = 0, colour = custom_gold })

    local header_text = "DRAWING TEST - All Shapes"
    local header_size = 30
    local header_x = (w / 2) - (#header_text * header_size * 0.3) 
    engine.draw.text({ text = header_text, x = header_x, y = header_y, size = header_size, colour = accent1 })

    local instruction_text = "Press ESC to return"
    local instruction_size = 16
    local instruction_x = (w / 2) - (#instruction_text * instruction_size * 0.4) 

    engine.draw.text({ text = instruction_text, x = instruction_x, y = text_col_y, size = instruction_size, colour = text_secondary })
end

function test_draw:unload()
    print("Draw test scene unloaded")
end

return test_draw