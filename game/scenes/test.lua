--[[
    Test file you can and should remove this :)
]]

--- @module game.scenes.test
--- @description Test scene, remove it or use it for testing things?

local test = {}

local test_module = require("test.some_module")
if test_module then
    print(test_module.message)
end

function test:load()
    print("Test scene loaded")
    engine.audio.load_music("horde_drums", "game/test/audio/horde_drums.ogg")
    
    self.image_loaded = false
    self.sprite_loaded = false
    
    self.sprite_x = 640
    self.sprite_y = 360
    self.current_anim = "idle_down"
    self.current_frame = 1
    self.frame_timer = 0
    self.frame_duration = 0.15
end

function test:update(dt)
    if engine.keyboard.is_pressed("space") then
        engine.audio.play_music("horde_drums")
        print("Done")
    end
    
    if engine.keyboard.is_pressed("backspace") then
        engine.audio.stop_music()
        engine.scene.switch("title")
    end
    
    if engine.keyboard.is_pressed("i") then
        if self.image_loaded then
            engine.image.unload("test_image")
            self.image_loaded = false
        else
            engine.image.load({
                type = "image",
                key = "test_image",
                path = "game/test/image/pixel_case.png"
            })
            self.image_loaded = true
        end
    end
    
    if engine.keyboard.is_pressed("o") then
        if self.sprite_loaded then
            engine.image.unload("test_sprite")
            self.sprite_loaded = false
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
        end
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

function test:draw()
    for x = 0, 20 do
        engine.draw.line({ x1 = x * 32, y1 = 0, x2 = x * 32, y2 = 720, r = 80, g = 80, b = 80 })
    end
    for y = 0, 22 do
        engine.draw.line({ x1 = 0, y1 = y * 32, x2 = 1280, y2 = y * 32, r = 80, g = 80, b = 80 })
    end

    engine.draw.rect({ x = 100, y = 100, w = 64, h = 64, r = 255, g = 0, b = 0 })
    engine.draw.rect({ x = 200, y = 100, w = 64, h = 64, r = 0, g = 255, b = 0 })
    engine.draw.rect({ x = 300, y = 100, w = 64, h = 64, r = 0, g = 0, b = 255 })

    engine.draw.rect_lines({ x = 400, y = 100, w = 64, h = 64, r = 255, g = 255, b = 0 })

    engine.draw.circle({ x = 450, y = 200, radius = 20, r = 255, g = 255, b = 0 })
    engine.draw.circle({ x = 520, y = 200, radius = 20, r = 255, g = 0, b = 255 })
    engine.draw.circle({ x = 590, y = 200, radius = 20, r = 0, g = 255, b = 255 })

    engine.draw.circle_lines({ x = 660, y = 200, radius = 20, r = 200, g = 200, b = 200 })

    engine.draw.triangle({ x1 = 100, y1 = 350, x2 = 150, y2 = 450, x3 = 50, y3 = 450, r = 100, g = 200, b = 100 })

    engine.draw.triangle_lines({ x1 = 250, y1 = 350, x2 = 300, y2 = 450, x3 = 200, y3 = 450, r = 200, g = 100, b = 200 })

    engine.draw.ellipse({ x = 400, y = 400, rx = 40, ry = 20, r = 150, g = 150, b = 255 })

    engine.draw.polygon({ x = 600, y = 400, sides = 6, radius = 30, rotation = 0, r = 200, g = 150, b = 50 })

    engine.draw.text({ text = "TEST SCENE - All Draw Functions", x = 100, y = 550, size = 20, r = 255, g = 255, b = 255 })
    engine.draw.text({ text = "Press 'I' to load/unload image", x = 100, y = 580, size = 16, r = 200, g = 200, b = 200 })
    engine.draw.text({ text = "Press 'O' to load/unload sprite | WASD to move", x = 100, y = 610, size = 16, r = 200, g = 200, b = 200 })

    if self.image_loaded then
        local w, h = engine.window.get_size()
        local center_x = w / 2
        local center_y = h / 2
        
        engine.image.draw({ key = "test_image", x = center_x - 32, y = center_y - 32, scale = 2 })
    end
    
    if self.sprite_loaded then
        engine.image.draw_sprite({
            key = "test_sprite",
            anim = self.current_anim,
            frame = self.current_frame,
            x = self.sprite_x,
            y = self.sprite_y,
            scale = 1
        })
        
        engine.draw.text({ text = "Sprite: " .. self.current_anim .. " Frame: " .. self.current_frame, x = 100, y = 640, size = 14, r = 100, g = 255, b = 100 })
    end
end

function test:unload()
    print("Test scene unloaded")
    engine.audio.unload_music("horde_drums")
    if self.image_loaded then
        engine.image.unload("test_image")
    end
    if self.sprite_loaded then
        engine.image.unload("test_sprite")
    end
end

return test