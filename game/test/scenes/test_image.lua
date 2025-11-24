--[[
    Test file you can and should remove this :)
]]

local test_image = {}

function test_image:load()
    print("Image test scene loaded")
    
    local w, h = engine.window.get_size()
    self.center_x = w / 2

    self.theme = engine.ui.style.get_theme() 
    
    self.image_loaded = false
    self.sprite_loaded = false
    
    self.sprite_x = self.center_x
    self.sprite_y = 360
    self.current_anim = "idle_down"
    self.current_frame = 1
    self.frame_timer = 0
    self.frame_duration = 0.15
end

function test_image:update(dt)
    if engine.keyboard.is_pressed("i") then
        if self.image_loaded then
            engine.image.unload("test_image")
            self.image_loaded = false
            print("Image unloaded")
        else
            engine.image.load({ type = "image", key = "test_image", path = "game/test/image/pixel_case.png" })
            self.image_loaded = true
            print("Image loaded")
        end
    end

    if engine.keyboard.is_pressed("o") then
        if self.sprite_loaded then
            engine.image.unload("test_sprite")
            self.sprite_loaded = false
            print("Sprite unloaded")
        else
            engine.image.load({
                type = "sprite",
                key = "test_sprite",
                path = "game/test/image/rpg_base_character_16.png",
                frame_width = 16,
                frame_height = 16,
                animations = {
                    idle_down = { x = 0, y = 0, frames = 2 },
                    idle_up = { x = 0, y = 1, frames = 2 },
                    idle_right = { x = 0, y = 2, frames = 2 },
                    idle_left = { x = 0, y = 3, frames = 2 },
                    walk_down = { x = 0, y = 4, frames = 4 },
                    walk_up = { x = 0, y = 5, frames = 4 },
                    walk_right = { x = 0, y = 6, frames = 4 },
                    walk_left = { x = 0, y = 7, frames = 4 } 
                }
            })
            self.sprite_loaded = true
            print("Sprite loaded")
        end
    end

    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end

    if self.sprite_loaded then
        local speed = 100
        local moving = false
        local new_anim = self.current_anim

        if engine.keyboard.is_down("w") then
            self.sprite_y = self.sprite_y - speed * dt
            new_anim = "walk_up"
            moving = true
        elseif engine.keyboard.is_down("s") then
            self.sprite_y = self.sprite_y + speed * dt
            new_anim = "walk_down"
            moving = true
        elseif engine.keyboard.is_down("a") then
            self.sprite_x = self.sprite_x - speed * dt
            new_anim = "walk_left"
            moving = true
        elseif engine.keyboard.is_down("d") then
            self.sprite_x = self.sprite_x + speed * dt
            new_anim = "walk_right"
            moving = true
        end

        if self.sprite_x < 16 then self.sprite_x = 16 end
        if self.sprite_y < 16 then self.sprite_y = 16 end
        local w, h = engine.window.get_size()
        if self.sprite_x > w - 16 then self.sprite_x = w - 16 end
        if self.sprite_y > h - 16 then self.sprite_y = h - 16 end

        if not moving then
            new_anim = new_anim:gsub("^walk_", "idle_")
        end

        if new_anim ~= self.current_anim then
            self.current_anim = new_anim
            self.current_frame = 1
            self.frame_timer = 0
        else
            self.current_anim = new_anim
        end

        self.frame_timer = self.frame_timer + dt
        if self.frame_timer >= self.frame_duration then
            self.frame_timer = self.frame_timer - self.frame_duration
            
            local anim_name = self.current_anim
            local frame_count = 2
            if anim_name:match("^walk_") then
                frame_count = 4
            end
            
            self.current_frame = self.current_frame + 1
            if self.current_frame > frame_count then
                self.current_frame = 1
            end
        end
    end
end

function test_image:draw()
    local w, h = engine.window.get_size()
    local center_x = w / 2
    local center_y = h / 2
    local text_col_x = center_x - 300
    
    local accent_colour = self.theme.accent
    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local text_success = self.theme.accent3 

    engine.draw.clear({ colour = self.theme.bg_main })

    engine.draw.text({ text = "IMAGE TEST", x = text_col_x, y = 50, size = 20, colour = accent_colour })
    engine.draw.text({ text = "Press 'I' to load/unload image", x = text_col_x, y = 100, size = 16, colour = text_secondary })
    engine.draw.text({ text = "Press 'O' to load/unload sprite | WASD to move", x = text_col_x, y = 130, size = 16, colour = text_secondary })
    engine.draw.text({ text = "Press ESC to quit", x = text_col_x, y = 160, size = 16, colour = text_secondary })

    if self.image_loaded then
        engine.image.draw({ key = "test_image", x = center_x - 32, y = center_y - 32, scale = 4 })
    end
    
    if self.sprite_loaded then
        engine.image.draw_sprite({ key = "test_sprite", anim = self.current_anim, frame = self.current_frame, x = self.sprite_x, y = self.sprite_y })

        engine.draw.text({ text = "Sprite: " .. self.current_anim .. " Frame: " .. self.current_frame, x = text_col_x, y = 200, size = 14, colour = text_success })
    end
end

function test_image:unload()
    print("Image test scene unloaded")
    if self.image_loaded then
        engine.image.unload("test_image")
    end
    if self.sprite_loaded then
        engine.image.unload("test_sprite")
    end
end

return test_image