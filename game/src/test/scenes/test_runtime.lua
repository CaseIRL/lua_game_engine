--[[
    Test file you can and should remove this :)
]]

local test_runtime = {}

function test_runtime:load()
    engine.log.info("Runtime test scene loaded")
    
    self.theme = engine.ui.style.get_theme()
    local w, h = engine.window.get_size()
    self.width = w
    self.height = h
    
    self.test_index = 1
    self.tests = {"Timers", "Cooldowns", "State", "Callbacks", "RNG"}
    self.animation_time = 0

    self.timers_log = {}
    self.active_timer_id = nil

    self.cooldown_user = "player_1"
    self.cooldown_type = "attack"
    self.cooldown_duration = 5
    self.cooldowns_log = {}

    engine.runtime.state.use_state("game")
    engine.runtime.state.set_state("level", 1)
    engine.runtime.state.set_state("health", 100)
    engine.runtime.state.set_state("score", 0)

    engine.runtime.callbacks.register_callback("on_test_event", function(msg)
        table.insert(self.callbacks_log, "Event: "..msg)
    end, true)
    self.callbacks_log = {}

    engine.runtime.rng.set_rng_seed(42)
    self.rng_log = {}
    
    engine.log.success("Runtime tests initialized")
end

function test_runtime:update(dt)
    self.animation_time = self.animation_time + dt

    engine.runtime.timers.update_timer(dt)

    if math.floor(self.animation_time) % 2 == 0 then
        engine.runtime.cooldowns.clear_expired_cooldowns()
    end

    if engine.keyboard.is_pressed("arrowup") then
        self.test_index = math.max(1, self.test_index - 1)
    end
    if engine.keyboard.is_pressed("arrowdown") then
        self.test_index = math.min(#self.tests, self.test_index + 1)
    end

    if self.test_index == 1 then
        self:update_timers_test()
    elseif self.test_index == 2 then
        self:update_cooldowns_test()
    elseif self.test_index == 3 then
        self:update_state_test()
    elseif self.test_index == 4 then
        self:update_callbacks_test()
    elseif self.test_index == 5 then
        self:update_rng_test()
    end
    
    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function test_runtime:update_timers_test()
    if engine.keyboard.is_pressed("space") then
        table.insert(self.timers_log, "Timer started at "..os.date("%H:%M:%S"))
        self.active_timer_id = engine.runtime.timers.set_timer(3, function()
            table.insert(self.timers_log, "Timer fired!")
        end)
    end
    if engine.keyboard.is_pressed("r") then
        if self.active_timer_id then
            engine.runtime.timers.cancel_timer(self.active_timer_id)
            table.insert(self.timers_log, "Timer cancelled")
        end
    end
end

function test_runtime:update_cooldowns_test()
    if engine.keyboard.is_pressed("space") then
        local remaining = engine.runtime.cooldowns.cooldown_time_remaining(self.cooldown_user, self.cooldown_type)
        if remaining == 0 then
            engine.runtime.cooldowns.add_cooldown(self.cooldown_user, self.cooldown_type, self.cooldown_duration)
            table.insert(self.cooldowns_log, "Cooldown started: "..self.cooldown_duration.."s")
        end
    end
end

function test_runtime:update_state_test()
    if engine.keyboard.is_pressed("space") then
        local score = engine.runtime.state.get_state("score", 0)
        engine.runtime.state.set_state("score", score + 10)
    end
    if engine.keyboard.is_pressed("r") then
        engine.runtime.state.set_state("score", 0)
    end
end

function test_runtime:update_callbacks_test()
    if engine.keyboard.is_pressed("space") then
        engine.runtime.callbacks.trigger_callback("on_test_event", "Triggered at "..os.date("%H:%M:%S"))
    end
end

function test_runtime:update_rng_test()
    if engine.keyboard.is_pressed("space") then
        local r1 = engine.runtime.rng.random_rng()
        local r2 = engine.runtime.rng.random_rng()
        table.insert(self.rng_log, "["..string.format("%.4f", r1)..", "..string.format("%.4f", r2).."]")
        if #self.rng_log > 6 then table.remove(self.rng_log, 1) end
    end
    if engine.keyboard.is_pressed("r") then
        engine.runtime.rng.set_rng_seed(42)
        self.rng_log = {}
    end
end

function test_runtime:draw()
    engine.draw.clear({colour = self.theme.bg_main})
    
    local theme = self.theme
    local x, y = 20, 30
    
    engine.draw.text({text = "RUNTIME TEST", x = x, y = y, size = 18, colour = theme.accent})
    engine.draw.text({text = "UP/DOWN: Navigate | SPACE: Test | R: Reset | ESC: Exit", x = x, y = y + 24, size = 11, colour = theme.text_secondary})
    
    y = y + 65
    engine.draw.text({text = "Tests:", x = x, y = y, size = 13, colour = theme.accent2})
    y = y + 25
    
    for i, test_name in ipairs(self.tests) do
        local selected = i == self.test_index
        local col = selected and theme.accent2 or theme.text_secondary
        engine.draw.text({text = (selected and "> " or "  ")..test_name, x = x, y = y + (i-1)*20, size = 12, colour = col})
    end
    
    y = y + 130
    engine.draw.text({text = "--- "..self.tests[self.test_index].." ---", x = 300, y = y - 35, size = 15, colour = theme.accent})
    
    if self.test_index == 1 then
        self:draw_timers(300, y)
    elseif self.test_index == 2 then
        self:draw_cooldowns(300, y)
    elseif self.test_index == 3 then
        self:draw_state(300, y)
    elseif self.test_index == 4 then
        self:draw_callbacks(300, y)
    elseif self.test_index == 5 then
        self:draw_rng(300, y)
    end
end

function test_runtime:text(x, y, txt, col)
    engine.draw.text({text = txt, x = x, y = y, size = 11, colour = col or self.theme.text_primary})
end

function test_runtime:draw_timers(x, y)
    local t = self.theme
    self:text(x, y, "Press SPACE to start 3-second timer", t.accent2)
    self:text(x, y + 22, "Press R to cancel active timer", t.accent2)
    self:text(x, y + 50, "Activity Log:", t.accent2)
    
    y = y + 70
    for i = math.max(1, #self.timers_log - 5), #self.timers_log do
        if self.timers_log[i] then
            self:text(x, y + (i - math.max(1, #self.timers_log - 5)) * 18, self.timers_log[i], t.text_primary)
        end
    end
end

function test_runtime:draw_cooldowns(x, y)
    local t = self.theme
    local remaining = engine.runtime.cooldowns.cooldown_time_remaining(self.cooldown_user, self.cooldown_type)
    
    self:text(x, y, "Cooldown Test: "..self.cooldown_user.." / "..self.cooldown_type, t.accent2)
    self:text(x, y + 22, "Press SPACE to start "..self.cooldown_duration.."s cooldown", t.accent2)
    
    y = y + 60
    if remaining > 0 then
        self:text(x, y, "Cooldown ACTIVE - "..string.format("%.1f", remaining).."s remaining", t.accent3)
        local bar_width = 200
        engine.draw.rect({x = x, y = y + 20, w = bar_width * (1 - remaining / self.cooldown_duration), h = 15, colour = t.accent})
        engine.draw.rect_lines({x = x, y = y + 20, w = bar_width, h = 15, colour = t.text_secondary})
    else
        self:text(x, y, "Cooldown READY - Press SPACE to trigger", t.success or t.accent3)
    end
end

function test_runtime:draw_state(x, y)
    local t = self.theme
    local level = engine.runtime.state.get_state("level", 0)
    local health = engine.runtime.state.get_state("health", 0)
    local score = engine.runtime.state.get_state("score", 0)
    
    self:text(x, y, "State: game", t.accent2)
    self:text(x, y + 22, "Press SPACE to add 10 score", t.accent2)
    self:text(x, y + 40, "Press R to reset score", t.accent2)
    
    y = y + 70
    self:text(x, y, "Level: "..level, t.text_primary)
    self:text(x, y + 20, "Health: "..health, t.text_primary)
    self:text(x, y + 40, "Score: "..score, t.accent3)
end

function test_runtime:draw_callbacks(x, y)
    local t = self.theme
    self:text(x, y, "Callback Test", t.accent2)
    self:text(x, y + 22, "Press SPACE to trigger event", t.accent2)
    self:text(x, y + 50, "Callback Log:", t.accent2)
    
    y = y + 70
    for i = math.max(1, #self.callbacks_log - 5), #self.callbacks_log do
        if self.callbacks_log[i] then
            self:text(x, y + (i - math.max(1, #self.callbacks_log - 5)) * 18, self.callbacks_log[i], t.text_primary)
        end
    end
end

function test_runtime:draw_rng(x, y)
    local t = self.theme
    local seed = engine.runtime.rng.get_rng_seed()
    
    self:text(x, y, "RNG Test (Seed: "..seed..")", t.accent2)
    self:text(x, y + 22, "Press SPACE to generate random values", t.accent2)
    self:text(x, y + 40, "Press R to reset seed to 42", t.accent2)
    
    y = y + 70
    self:text(x, y, "Random Pairs:", t.accent2)
    y = y + 20
    for i, pair in ipairs(self.rng_log) do
        self:text(x, y + (i-1) * 18, pair, t.text_primary)
    end
end

function test_runtime:unload()
    engine.log.info("Runtime test scene unloaded")
end

return test_runtime