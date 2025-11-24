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

    self.player_x = self.center_x
    self.player_y = 300
    self.speed = 200
    self.is_jumping = false
    self.jump_velocity = 0
    self.gravity = 500
    self.ground_y = 300
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

    if engine.actions.is_action_pressed("shoot") then
        print("Shot fired!")
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
end

function test_actions:draw()
    local w, h = engine.window.get_size()
    local center_x = w / 2
    
    engine.draw.clear({ colour = self.theme.bg_main })

    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local accent_colour = self.theme.accent
    local text_success = self.theme.accent3
    
    local text_col_x = center_x - 150

    engine.draw.text({ text = "ACTIONS TEST", x = text_col_x, y = 30, size = 24, colour = accent_colour })
    engine.draw.text({ text = "WASD / Arrow Keys - Move", x = text_col_x, y = 100, size = 14, colour = text_secondary })
    engine.draw.text({ text = "SPACE - Jump", x = text_col_x, y = 130, size = 14, colour = text_secondary })
    engine.draw.text({ text = "LMB - Shoot", x = text_col_x, y = 160, size = 14, colour = text_secondary })
    engine.draw.text({ text = "ESC - Close", x = text_col_x, y = 190, size = 14, colour = text_secondary })

    engine.draw.circle({ x = self.player_x, y = self.player_y, radius = 15, colour = accent_colour })

    engine.draw.line({ x1 = 0, y1 = self.ground_y + 20, x2 = w,y2 = self.ground_y + 20, colour = self.theme.border_light.colour })

    local jump_status = self.is_jumping and "Jumping" or "Grounded"
    engine.draw.text({ text = "Status: " .. jump_status, x = text_col_x, y = 250, size = 14, colour = text_success })
end

function test_actions:unload()
    print("Actions test scene unloaded")
    engine.actions.clear_actions()
end

return test_actions