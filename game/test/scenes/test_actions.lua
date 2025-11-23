--[[
    Test file you can and should remove this :)
]]

local test_actions = {}

function test_actions:load()
    print("Actions test scene loaded")

    engine.actions.map_action("move_left", {"a", "arrowleft"})
    engine.actions.map_action("move_right", {"d", "arrowright"})
    engine.actions.map_action("move_up", {"w", "arrowup"})
    engine.actions.map_action("move_down", {"s", "arrowdown"})
    engine.actions.map_action("jump", {"space"})
    engine.actions.map_action("shoot", {{ mouse_button = 0 }})

    self.player_x = 400
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
    engine.draw.clear({r = 40, g = 40, b = 40})

    engine.draw.text({ text = "ACTIONS TEST", x = 100, y = 30, size = 24, r = 255, g = 255, b = 255 })
    engine.draw.text({ text = "WASD / Arrow Keys - Move", x = 100, y = 100, size = 14, r = 200, g = 200, b = 200 })
    engine.draw.text({ text = "SPACE - Jump", x = 100, y = 130, size = 14, r = 200, g = 200, b = 200 })
    engine.draw.text({ text = "LMB - Shoot", x = 100, y = 160, size = 14, r = 200, g = 200, b = 200 })
    engine.draw.text({ text = "ESC - Close", x = 100, y = 190, size = 14, r = 200, g = 200, b = 200 })
    

    engine.draw.circle({ x = self.player_x, y = self.player_y, radius = 15, r = 100, g = 200, b = 255 })
    
    engine.draw.line({ x1 = 0, y1 = self.ground_y + 20, x2 = 800, y2 = self.ground_y + 20, r = 100, g = 100, b = 100 })

    local jump_status = self.is_jumping and "Jumping" or "Grounded"
    engine.draw.text({ text = "Status: " .. jump_status, x = 100, y = 250, size = 14, r = 100, g = 255, b = 100 })
end

function test_actions:unload()
    print("Actions test scene unloaded")
    engine.actions.clear_actions()
end

return test_actions