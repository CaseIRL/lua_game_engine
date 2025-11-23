--[[
    Test file you can and should remove this :)
]]

local test_audio = {}

function test_audio:load()
    print("Audio test scene loaded")
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
    engine.draw.text({ text = "AUDIO TEST", x = 100, y = 100, size = 20, r = 255, g = 255, b = 255 })
    engine.draw.text({ text = "SPACE - Play", x = 100, y = 150, size = 16, r = 200, g = 200, b = 200 })
    engine.draw.text({ text = "P - Pause", x = 100, y = 180, size = 16, r = 200, g = 200, b = 200 })
    engine.draw.text({ text = "R - Resume", x = 100, y = 210, size = 16, r = 200, g = 200, b = 200 })
    engine.draw.text({ text = "S - Stop", x = 100, y = 240, size = 16, r = 200, g = 200, b = 200 })
    engine.draw.text({ text = "ESC - Return", x = 100, y = 270, size = 16, r = 200, g = 200, b = 200 })

    local playing = engine.audio.is_music_playing()
    local status = playing and "Playing" or "Stopped"
    engine.draw.text({ text = "Status: " .. status, x = 100, y = 350, size = 16, r = 100, g = 255, b = 100 })
end

function test_audio:unload()
    print("Audio test scene unloaded")
    engine.audio.unload_music("horde_drums")
end

return test_audio