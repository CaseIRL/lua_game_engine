--[[
    Test file you can and should remove this :)
]]

local test_collision = {}

function test_collision:load()
    print("Collision test scene loaded")
    
    engine.actions.map_action("move_left", {"a", "arrowleft"})
    engine.actions.map_action("move_right", {"d", "arrowright"})
    engine.actions.map_action("move_up", {"w", "arrowup"})
    engine.actions.map_action("move_down", {"s", "arrowdown"})

    self.player = {x = 100, y = 100, width = 50, height = 50}
    self.obstacle = {x = 400, y = 300, width = 150, height = 80}
    self.circle = {x = 200, y = 450, radius = 40}
    self.test_point = {x = 0, y = 0}
    self.speed = 200
    self.collision_state = "No collision"
    self.distance = 0
end

function test_collision:update(dt)
    if engine.actions.is_action_down("move_left") then 
        self.player.x = self.player.x - self.speed * dt 
    end
    if engine.actions.is_action_down("move_right") then 
        self.player.x = self.player.x + self.speed * dt 
    end
    if engine.actions.is_action_down("move_up") then 
        self.player.y = self.player.y - self.speed * dt 
    end
    if engine.actions.is_action_down("move_down") then 
        self.player.y = self.player.y + self.speed * dt 
    end

    self.test_point.x, self.test_point.y = engine.mouse.get_pos()

    local player_center = {x = self.player.x + self.player.width / 2, y = self.player.y + self.player.height / 2}
    local rect_collision = engine.collision.rects_overlap({rect1 = self.player, rect2 = self.obstacle})
    local circle_collision = engine.collision.circles_overlap({c1_center = player_center, c1_radius = 30, c2_center = self.circle, c2_radius = self.circle.radius})

    self.point_in_rect = engine.collision.point_in_rect({point = self.test_point, rect = self.obstacle})
    self.point_in_circle = engine.collision.point_in_circle({point = self.test_point, center = self.circle, radius = self.circle.radius})
    self.distance = engine.collision.distance_between({p1 = player_center, p2 = self.circle})

    if rect_collision then 
        self.collision_state = "Player overlaps RECT"
    elseif circle_collision then 
        self.collision_state = "Player overlaps CIRCLE"
    else 
        self.collision_state = "No collision" 
    end
end

function test_collision:draw()
    engine.draw.clear({r = 40, g = 40, b = 40})
    engine.draw.text({text = "COLLISION TEST", x = 100, y = 30, size = 24, r = 255, g = 255, b = 255})
    engine.draw.text({text = "WASD - Move | Mouse - Test point | ESC - Return", x = 100, y = 80, size = 12, r = 200, g = 200, b = 200})

    engine.draw.rect({x = self.obstacle.x, y = self.obstacle.y, w = self.obstacle.width, h = self.obstacle.height, r = 255, g = 100, b = 100})
    engine.draw.text({text = "RECT", x = self.obstacle.x + 50, y = self.obstacle.y + 30, size = 10, r = 0, g = 0, b = 0})

    engine.draw.circle({x = self.circle.x, y = self.circle.y, radius = self.circle.radius, r = 100, g = 255, b = 100})

    engine.draw.rect({x = self.player.x, y = self.player.y, w = self.player.width, h = self.player.height, r = 100, g = 200, b = 255})
    engine.draw.text({text = "PLAYER", x = self.player.x + 5, y = self.player.y + 15, size = 10, r = 0, g = 0, b = 0})

    engine.draw.line({x1 = self.test_point.x - 10, y1 = self.test_point.y, x2 = self.test_point.x + 10, y2 = self.test_point.y, r = 255, g = 255, b = 0})
    engine.draw.line({x1 = self.test_point.x, y1 = self.test_point.y - 10, x2 = self.test_point.x, y2 = self.test_point.y + 10, r = 255, g = 255, b = 0})

    engine.draw.text({text = "Collision: " .. self.collision_state, x = 100, y = 250, size = 14, r = 255, g = 255, b = 100})
    engine.draw.text({text = "Point in RECT: " .. tostring(self.point_in_rect), x = 100, y = 280, size = 14, r = 255, g = 255, b = 100})
    engine.draw.text({text = "Point in CIRCLE: " .. tostring(self.point_in_circle), x = 100, y = 310, size = 14, r = 255, g = 255, b = 100})
    engine.draw.text({text = "Distance: " .. string.format("%.1f", self.distance), x = 100, y = 340, size = 14, r = 255, g = 255, b = 100})
end

function test_collision:unload()
    print("Collision test scene unloaded")
    engine.actions.clear_actions()
end

return test_collision