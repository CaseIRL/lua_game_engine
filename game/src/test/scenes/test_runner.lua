--[[
    Test file you can and should remove this :)
]]

local test_runner = {}

function test_runner:load()
    self.w, self.h = engine.window.get_size()
    self.theme = engine.ui.style.get_theme()

    engine.actions.map_action("jump", {"space", "w", "arrowup"})

    self.ground_y = self.h - 50
    self.gravity = 1200
    self.jump_power = -500

    self.player = { x = 100, y = self.h - 100, r = 20, vy = 0, grounded = true }

    self.obstacles = {}
    self.obstacle_timer = 0
    self.obstacle_interval = 1.5
    self.obstacle_speed = 300

    self.alive = true
    self.score = 0
end

function test_runner:update(dt)
    if not self.alive then
        if engine.keyboard.is_pressed("space") then engine.scene.switch("test_runner") end
        return
    end

    local p = self.player

    if engine.actions.is_action_pressed("jump") and p.grounded then
        p.vy = self.jump_power
        p.grounded = false
    end

    p.vy = p.vy + self.gravity * dt
    p.y = p.y + p.vy * dt

    local floor = self.ground_y - p.r
    if p.y >= floor then
        p.y, p.vy, p.grounded = floor, 0, true
    end

    self.obstacle_timer = self.obstacle_timer + dt
    if self.obstacle_timer >= self.obstacle_interval then
        self.obstacle_timer = 0
        self.obstacles[#self.obstacles+1] = { x = self.w + 50, y = self.ground_y - 30, w = 30, h = 30 }
    end

    for i = #self.obstacles, 1, -1 do
        local o = self.obstacles[i]
        o.x = o.x - self.obstacle_speed * dt
        if o.x + o.w < 0 then
            table.remove(self.obstacles, i)
            self.score = self.score + 1
        end
    end

    for _, o in ipairs(self.obstacles) do
        if engine.collision.rects_overlap({
            rect1 = { x = p.x - p.r, y = p.y - p.r, width = p.r*2, height = p.r*2 },
            rect2 = { x = o.x, y = o.y - o.h, width = o.w, height = o.h }
        }) then
            self.alive = false
        end
    end

    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function test_runner:draw()
    engine.draw.clear({ colour = self.theme.bg_main })

    engine.draw.line({ x1 = 0, y1 = self.ground_y, x2 = self.w, y2 = self.ground_y, colour = {100,100,100,255} })

    local p = self.player
    engine.draw.circle({ x = p.x, y = p.y, radius = p.r, colour = self.alive and {100,200,255,255} or {255,50,50,255} })

    for _, o in ipairs(self.obstacles) do
        engine.draw.rect({ x = o.x, y = o.y - o.h, w = o.w, h = o.h, colour = {255,100,100,255} })
    end

    engine.draw.text({ text = "Score: "..self.score, x = 10, y = 40, size = 20, colour = self.theme.text_primary })
    engine.draw.text({ text = "SPACE / W / ArrowUp to jump", x = 10, y = 70, size = 14, colour = self.theme.text_secondary })

    if not self.alive then
        local cx, cy = self.w/2, self.h/2
        engine.draw.text({ text = "GAME OVER", x = cx-100, y = cy-40, size = 32, colour = {255,50,50,255} })
        engine.draw.text({ text = "Score: "..self.score, x = cx-60, y = cy, size = 24, colour = self.theme.text_primary })
        engine.draw.text({ text = "SPACE to restart", x = cx-80, y = cy+40, size = 16, colour = self.theme.text_secondary })
    end
end

function test_runner:unload()
    engine.actions.clear_actions()
end

return test_runner