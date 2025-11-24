--[[
    Test file you can and should remove this :)
]]

local test_audio = {}

function test_audio:load()
    print("Audio test scene loaded")
    
    local w, h = engine.window.get_size()
    self.center_x = w / 2
    self.theme = engine.ui.style.get_theme() 

    engine.audio.load_music("horde_drums", "game/test/audio/horde_drums.ogg")
end

function test_audio:update(dt)
    if engine.keyboard.is_pressed("space") then
        engine.audio.play_music("horde_drums")
        print("Music playing")
    end

    if engine.keyboard.is_pressed("p") then
        engine.audio.pause_music()
        print("Music paused")
    end

    if engine.keyboard.is_pressed("r") then
        engine.audio.resume_music()
        print("Music resumed")
    end

    if engine.keyboard.is_pressed("s") then
        engine.audio.stop_music()
        print("Music stopped")
    end

    if engine.keyboard.is_pressed("escape") then
        engine.audio.stop_music()
        engine.scene.switch("title")
    end
end

function test_audio:draw()
    local w, h = engine.window.get_size()
    local center_x = w / 2
    local text_col_x = center_x - 150 
    
    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local text_success = self.theme.accent3
    local accent_colour = self.theme.accent

    engine.draw.clear({ colour = self.theme.bg_main })

    engine.draw.text({ text = "AUDIO TEST", x = text_col_x, y = 100, size = 20, colour = accent_colour })
    engine.draw.text({ text = "SPACE - Play", x = text_col_x, y = 150, size = 16, colour = text_secondary })
    engine.draw.text({ text = "P - Pause", x = text_col_x, y = 180, size = 16, colour = text_secondary })
    engine.draw.text({ text = "R - Resume", x = text_col_x, y = 210, size = 16, colour = text_secondary })
    engine.draw.text({ text = "S - Stop", x = text_col_x, y = 240, size = 16, colour = text_secondary })
    engine.draw.text({ text = "ESC - Return", x = text_col_x, y = 270, size = 16, colour = text_secondary })

    local playing = engine.audio.is_music_playing()
    local status = playing and "Playing" or "Stopped"
    engine.draw.text({ text = "Status: " .. status, x = text_col_x, y = 350, size = 16, colour = text_success })
end

function test_audio:unload()
    print("Audio test scene unloaded")
    engine.audio.unload_music("horde_drums")
end

return test_audio