--[[
    Test file you can and should remove this :)
]]

local test_ui = {}

function test_ui:load()
    print("UI test scene loaded")

    local w, h = engine.window.get_size()
    local btn_w = 200
    local btn_h = 50

    local center_x = (w / 2) - (btn_w / 2)
    local center_y = (h / 2) - (btn_h / 2)

    self.theme = engine.ui.style.get_theme() 
    
    self.click_count = 0 

    self.my_button = engine.ui.button.new({
        x = center_x,
        y = center_y,
        w = btn_w,
        h = btn_h,
        text = "Click Me",
        on_click = function()
            print("Button clicked!")
            self.click_count = self.click_count + 1 
        end
    })
end

function test_ui:update(dt)
    if engine.keyboard.is_pressed("escape") then
        engine.window.close()
    end
    
    local mx, my = engine.mouse.get_pos()
    local pressed = engine.mouse.is_pressed(0) 

    self.my_button:update(mx, my, pressed)
end

function test_ui:draw()
    local w, h = engine.window.get_size()

    local text_primary = self.theme.text_primary
    local accent_color = self.theme.accent

    engine.draw.clear({ colour = self.theme.bg_main })

    local header_text = "UI TEST"
    local header_size = 36
    local header_x = (w / 2) - (#header_text * header_size * 0.3) 
    engine.draw.text({ text = header_text, x = header_x, y = 50,size = header_size, colour = accent_color })


    self.my_button:draw()

    local text_y = self.my_button.y + self.my_button.h + 30
    local status_text = "Button Clicks: " .. self.click_count .. " | ESC to Quit"
    local status_size = 18
    local status_x = (w / 2) - (#status_text * status_size * 0.225)
    
    engine.draw.text({ 
        text = status_text, 
        x = status_x, 
        y = text_y, 
        size = status_size, 
        colour = text_primary 
    })
end

function test_ui:unload()
    print("UI test scene unloaded")
end

return test_ui