--[[
    Support honest development retain this credit. 
    Don't claim you made it from scratch. Don't be that guy...

    MIT License

    Copyright (c) 2025 CaseIRL

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

--- @module engine.core.window
--- @description Handles window creation and lifecycle.

--- @section FFI

local ffi = require("ffi")

ffi.cdef[[
    typedef struct { unsigned char r, g, b, a; } Color;

    void InitWindow(int width, int height, const char *title);
    void CloseWindow(void);
    int WindowShouldClose(void);
    void SetTargetFPS(int fps);
    float GetFrameTime(void);
    int GetFPS(void);
    void BeginDrawing(void);
    void EndDrawing(void);
    void ClearBackground(Color color);
    void DrawFPS(int posX, int posY);
    void InitAudioDevice(void);
    void CloseAudioDevice(void);
    void ToggleFullscreen(void);
]]

local _rl = ffi.load("raylib")
local new_colour = ffi.typeof("Color")

--- @section Module

local window = {
    title = "Lua Engine",
    size = { width = 1280, height = 720 },
    fps = { draw = false, target = false },
    modules = { audio = false },
    running = false
}

--- Initialize the window.
--- @param opts table Optional settings: window.title, window.size, fps.target, modules.audio
function window.init(opts)
    opts = opts or {}

    window.title = opts.window.title or window.title
    window.size = opts.window.size or window.size
    window.fps = opts.fps or window.fps
    window.modules = opts.modules or window.modules
    
    _rl.InitWindow(window.size.width, window.size.height, window.title)

    if window.modules.audio then
        _rl.InitAudioDevice()
    end

    if window.fps.target then
        _rl.SetTargetFPS(window.fps.target)
    end
end

--- Begin a drawing frame.
function window.begin_draw()
    _rl.BeginDrawing()
    _rl.ClearBackground(new_colour(10, 10, 20, 255))
end

--- End a drawing frame.
function window.end_draw()
    _rl.EndDrawing()
end

--- Check if the window should close.
--- @return boolean True if the window should close.
function window.should_close()
    return _rl.WindowShouldClose() ~= 0
end

--- Toggle fullscreen mode.
function window.toggle_fullscreen()
    _rl.ToggleFullscreen()
end

--- Get the current window size.
--- @return number width
--- @return number height
function window.get_size()
    return window.size.width, window.size.height
end

--- Get the time elapsed since the last frame.
--- @return number Delta time in seconds.
function window.get_dt()
    return _rl.GetFrameTime()
end

--- Get the current frames per second.
--- @return number FPS
function window.get_fps()
    return _rl.GetFPS()
end

--- Draw the current FPS at a position.
--- @param x number X coordinate
--- @param y number Y coordinate
function window.draw_fps(x, y)
    _rl.DrawFPS(x, y)
end

--- Close the window and audio device if enabled.
function window.close()
    if window.modules.audio then
        _rl.CloseAudioDevice()
    end
    _rl.CloseWindow()
end

return window