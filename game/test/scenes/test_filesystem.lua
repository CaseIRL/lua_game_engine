--[[
    Test file you can and should remove this :)
]]

local test_filesystem = {}

function test_filesystem:load()
    print("Filesystem test scene loaded")
    
    local w, h = engine.window.get_size()
    self.center_x = w / 2
    self.theme = engine.ui.style.get_theme()

    self.player = { name = "Hero", level = 1, xp = 0, xp_to_level = 100 }

    local saved_data, err = engine.filesystem.load("player_save.lua")
    if saved_data then
        self.player = saved_data
        print("Loaded existing save!")
    else
        print("No save found, starting fresh")
    end
    
    self.last_action = "Press L to load, S to save"
    self.save_status = ""
end

function test_filesystem:update(dt)
    if engine.keyboard.is_pressed("space") then
        self.player.xp = self.player.xp + 25
        self.last_action = "Gained 25 XP!"

        if self.player.xp >= self.player.xp_to_level then
            self.player.level = self.player.level + 1
            self.player.xp = self.player.xp - self.player.xp_to_level
            self.player.xp_to_level = self.player.xp_to_level + 50
            self.last_action = "LEVEL UP! Now level " .. self.player.level
            print("Level up! Now level " .. self.player.level)
        end
    end

    if engine.keyboard.is_pressed("s") then
        local success, err = engine.filesystem.save("player_save.lua", self.player)
        if success then
            self.save_status = "Saved successfully!"
            print("Game saved!")
        else
            self.save_status = "Save failed: " .. (err or "unknown error")
            print("Save failed: " .. (err or "unknown error"))
        end
    end

    if engine.keyboard.is_pressed("l") then
        local data, err = engine.filesystem.load("player_save.lua")
        if data then
            self.player = data
            self.save_status = "Loaded successfully!"
            print("Game loaded!")
        else
            self.save_status = "Load failed: " .. (err or "no save found")
            print("Load failed: " .. (err or "no save found"))
        end
    end

    if engine.keyboard.is_pressed("r") then
        self.player = { name = "Hero", level = 1, xp = 0, xp_to_level = 100 }
        self.last_action = "Progress reset!"
        print("Progress reset!")
    end

    if engine.keyboard.is_pressed("d") then
        local success, err = engine.filesystem.delete("player_save.lua")
        if success then
            self.save_status = "Save deleted!"
            print("Save deleted!")
        else
            self.save_status = "Delete failed: " .. (err or "unknown error")
        end
    end
    
    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function test_filesystem:draw()
    local w, h = engine.window.get_size()
    local center_x = w / 2
    local text_col_x = center_x - 200
    
    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local text_success = self.theme.accent3
    local accent_colour = self.theme.accent
    local accent2 = self.theme.accent2

    engine.draw.clear({ colour = self.theme.bg_main })

    engine.draw.text({ text = "FILESYSTEM TEST", x = text_col_x, y = 50, size = 20, colour = accent_colour })
    engine.draw.text({ text = "SPACE - Gain XP (+25)", x = text_col_x, y = 120, size = 14, colour = text_secondary })
    engine.draw.text({ text = "S - Save Game", x = text_col_x, y = 150, size = 14, colour = text_secondary })
    engine.draw.text({ text = "L - Load Game", x = text_col_x, y = 180, size = 14, colour = text_secondary })
    engine.draw.text({ text = "R - Reset Progress", x = text_col_x, y = 210, size = 14, colour = text_secondary })
    engine.draw.text({ text = "D - Delete Save", x = text_col_x, y = 240, size = 14, colour = text_secondary })
    engine.draw.text({ text = "ESC - Return", x = text_col_x, y = 270, size = 14, colour = text_secondary })
    engine.draw.text({ text = "Player: " .. self.player.name, x = text_col_x, y = 340, size = 18, colour = text_primary })
    engine.draw.text({ text = "Level: " .. self.player.level, x = text_col_x, y = 370, size = 16, colour = accent2 })
    engine.draw.text({ text = "XP: " .. self.player.xp .. " / " .. self.player.xp_to_level, x = text_col_x, y = 400, size = 16, colour = accent2 })

    local bar_width = 300
    local bar_height = 25
    local bar_x = center_x - bar_width / 2
    local bar_y = 440
    local xp_percent = self.player.xp / self.player.xp_to_level

    engine.draw.rect({ x = bar_x, y = bar_y, w = bar_width, h = bar_height, colour = self.theme.bg_panel })
    engine.draw.rect({ x = bar_x, y = bar_y, w = bar_width * xp_percent, h = bar_height, colour = text_success})
    engine.draw.rect_lines({ x = bar_x, y = bar_y, w = bar_width, h = bar_height, colour = self.theme.border_light.colour,line_thick = 2})

    engine.draw.text({ text = "Last Action: " .. self.last_action, x = text_col_x, y = 500, size = 14, colour = text_primary })
    
    if self.save_status ~= "" then
        engine.draw.text({ text = self.save_status, x = text_col_x, y = 530, size = 14, colour = text_success })
    end

    local save_exists = engine.filesystem.exists("player_save.lua")
    local file_status = save_exists and "Save file exists" or "No save file found"
    engine.draw.text({ text = file_status, x = text_col_x, y = 580, size = 12, colour = text_secondary })
end

function test_filesystem:unload()
    print("Filesystem test scene unloaded")
end

return test_filesystem