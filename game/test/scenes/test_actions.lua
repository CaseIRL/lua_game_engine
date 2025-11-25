--[[
    Test file you can and should remove this :)
]]

local test_actions = {}

function test_actions:load()
    print("Actions test scene loaded")

    local w, h = engine.window.get_size()
    self.center_x = w / 2
    self.center_y = h / 2

    self.theme = engine.ui.style.get_theme() 

    engine.actions.map_action("move_left", { "a", "arrowleft" })
    engine.actions.map_action("move_right", { "d", "arrowright" })
    engine.actions.map_action("move_up", { "w", "arrowup" })
    engine.actions.map_action("move_down", { "s", "arrowdown" })
    engine.actions.map_action("jump", { "space" })
    engine.actions.map_action("shoot", { { mouse_button = 0 } })
    engine.actions.map_action("charge", { "e" })

    self.player_x = self.center_x
    self.player_y = 300
    self.speed = 200
    self.is_jumping = false
    self.jump_velocity = 0
    self.gravity = 500
    self.ground_y = 300
    self.last_shot = "None"
    self.charge_power = 0
end

function test_actions:update(dt)
    if engine.actions.is_action_down("move_left") then
        self.player_x = self.player_x - self.speed * dt
    end
    if engine.actions.is_action_down("move_right") then
        self.player_x = self.player_x + self.speed * dt
    end
    if engine.actions.is_action_down("move_up") then
        self.player_y = self.player_y - self.speed * dt
    end
    if engine.actions.is_action_down("move_down") then
        self.player_y = self.player_y + self.speed * dt
    end

    if engine.actions.is_action_pressed("jump") and not self.is_jumping then
        self.is_jumping = true
        self.jump_velocity = -300
        print("Jump!")
    end

    if self.is_jumping then
        self.jump_velocity = self.jump_velocity + self.gravity * dt
        self.player_y = self.player_y + self.jump_velocity * dt
        
        if self.player_y >= self.ground_y then
            self.player_y = self.ground_y
            self.is_jumping = false
            self.jump_velocity = 0
        end
    end

    if engine.actions.is_action_released("shoot") then
        self.last_shot = "Quick shot!"
        print("Shot fired!")
    end

    local charge_time = engine.actions.hold_time("charge")
    if charge_time > 0 then
        self.charge_power = math.min(charge_time / 2.0, 1.0)
    end

    if engine.actions.is_action_released("charge") and self.charge_power > 0 then
        local power_percent = math.floor(self.charge_power * 100)
        self.last_shot = "Charged attack: " .. power_percent .. "%"
        print("Charged attack released at " .. power_percent .. "% power!")
        self.charge_power = 0
    end
    
    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function test_actions:draw()
    local w, h = engine.window.get_size()
    local center_x = w / 2
    
    engine.draw.clear({ colour = self.theme.bg_main })

    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local accent_colour = self.theme.accent
    local accent2 = self.theme.accent2
    local text_success = self.theme.accent3
    
    local text_col_x = center_x - 200

    engine.draw.text({ text = "ACTIONS TEST", x = text_col_x, y = 30, size = 24, colour = accent_colour })

    engine.draw.text({ text = "WASD / Arrow Keys - Move", x = text_col_x, y = 100, size = 14, colour = text_secondary })
    engine.draw.text({ text = "SPACE - Jump", x = text_col_x, y = 130, size = 14, colour = text_secondary })
    engine.draw.text({ text = "LMB - Quick Shot (on release)", x = text_col_x, y = 160, size = 14, colour = text_secondary })
    engine.draw.text({ text = "E - Hold to charge attack", x = text_col_x, y = 190, size = 14, colour = text_secondary })
    engine.draw.text({ text = "ESC - Return", x = text_col_x, y = 220, size = 14, colour = text_secondary })

    engine.draw.circle({ x = self.player_x, y = self.player_y, radius = 15, colour = accent_colour })
    
    engine.draw.line({ x1 = 0, y1 = self.ground_y + 20, x2 = w, y2 = self.ground_y + 20, colour = self.theme.border_light.colour })

    local jump_status = self.is_jumping and "Jumping" or "Grounded"
    engine.draw.text({ text = "Status: " .. jump_status, x = text_col_x, y = 250, size = 14, colour = text_success })
    engine.draw.text({ text = "Last Action: " .. self.last_shot, x = text_col_x, y = 280, size = 14, colour = text_primary })

    if self.charge_power > 0 then
        local bar_width = 200
        local bar_height = 20
        local bar_x = center_x - bar_width / 2
        local bar_y = 400

        engine.draw.rect({ x = bar_x, y = bar_y, w = bar_width, h = bar_height, colour = self.theme.bg_panel })
        engine.draw.rect({ x = bar_x, y = bar_y, w = bar_width * self.charge_power, h = bar_height, colour = accent2})
        engine.draw.rect_lines({ x = bar_x, y = bar_y, w = bar_width, h = bar_height, colour = self.theme.border_light.colour,line_thick = 2})
        
        local charge_percent = math.floor(self.charge_power * 100)
        engine.draw.text({ text = "CHARGING: " .. charge_percent .. "%", x = center_x - 70, y = bar_y - 25, size = 14, colour = accent2 })
    end
end

function test_actions:unload()
    print("Actions test scene unloaded")
    engine.actions.clear_actions()
end

return test_actions