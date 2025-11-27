--[[
    Test file you can and should remove this :)
]]

local test_mods = {}

local player = {
    x = 400,
    y = 300,
    health = 100,
    score = 0
}

local enemies = {}

function test_mods:load()
    print("Mods test scene loaded")
    
    local w, h = engine.window.get_size()
    self.center_x = w / 2
    self.theme = engine.ui.style.get_theme()

    engine.hooks.register("player_spawn")
    engine.hooks.register("player_damage")
    engine.hooks.register("enemy_spawn")
    engine.hooks.register("enemy_killed")
    engine.hooks.register("draw_after")

    player.x = self.center_x
    player.y = h / 2
    engine.hooks.fire("player_spawn", { x = player.x, y = player.y, health = player.health })

    for i = 1, 3 do
        local enemy = { x = math.random(100, w - 100), y = math.random(100, h - 100), type = "goblin" }
        table.insert(enemies, enemy)
        engine.hooks.fire("enemy_spawn", { type = enemy.type, x = enemy.x, y = enemy.y })
    end
end

function test_mods:update(dt)
    if engine.keyboard.is_down("w") then player.y = player.y - 200 * dt end
    if engine.keyboard.is_down("s") then player.y = player.y + 200 * dt end
    if engine.keyboard.is_down("a") then player.x = player.x - 200 * dt end
    if engine.keyboard.is_down("d") then player.x = player.x + 200 * dt end
    
    if engine.keyboard.is_pressed("space") then
        player.health = player.health - 10
        engine.hooks.fire("player_damage", { damage = 10, health = player.health })
    end

    if engine.keyboard.is_pressed("e") and #enemies > 0 then
        local enemy = table.remove(enemies, 1)
        player.score = player.score + 100
        engine.hooks.fire("enemy_killed", { type = enemy.type, x = enemy.x, y = enemy.y, score = player.score })
    end
    
    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function test_mods:draw()
    local w, h = engine.window.get_size()
    local text_col_x = self.center_x - 200
    
    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local accent_colour = self.theme.accent
    local accent2 = self.theme.accent2
    local accent3 = self.theme.accent3
    
    engine.draw.clear({ colour = self.theme.bg_main })

    engine.draw.text({ text = "MODS TEST", x = text_col_x, y = 50, size = 20, colour = accent_colour })

    engine.draw.circle({ x = player.x, y = player.y, radius = 20, colour = accent_colour })

    for _, enemy in ipairs(enemies) do
        engine.draw.circle({ x = enemy.x, y = enemy.y, radius = 15, colour = {255, 50, 50, 255} })
    end

    engine.draw.text({ text = "Health: " .. player.health, x = 20, y = 100, size = 16, colour = text_primary })
    engine.draw.text({ text = "Score: " .. player.score, x = 20, y = 130, size = 16, colour = text_primary })
    engine.draw.text({ text = "Enemies: " .. #enemies, x = 20, y = 160, size = 16, colour = text_primary })
    
    engine.draw.text({ text = "WASD - Move Player", x = text_col_x, y = h - 150, size = 14, colour = text_secondary })
    engine.draw.text({ text = "SPACE - Take Damage", x = text_col_x, y = h - 120, size = 14, colour = text_secondary })
    engine.draw.text({ text = "E - Kill Enemy", x = text_col_x, y = h - 90, size = 14, colour = text_secondary })
    engine.draw.text({ text = "ESC - Quit", x = text_col_x, y = h - 60, size = 14, colour = text_secondary })
    
    engine.hooks.fire("draw_after", { player = player, enemies = enemies })
end

function test_mods:unload()
    print("Mods test scene unloaded")
end

return test_mods