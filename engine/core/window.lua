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
local bit = require("bit")

ffi.cdef[[
    typedef struct { unsigned char r, g, b, a; } Color;
    typedef struct { float x; float y; } Vector2;
    
    typedef struct {
        void *data;
        int width;
        int height;
        int mipmaps;
        int format;
    } Image;

    typedef enum {
        FLAG_VSYNC_HINT = 0x00000040,
        FLAG_FULLSCREEN_MODE = 0x00000002,
        FLAG_WINDOW_RESIZABLE = 0x00000004,
        FLAG_WINDOW_UNDECORATED = 0x00000008,
        FLAG_WINDOW_HIDDEN = 0x00000080,
        FLAG_WINDOW_MINIMIZED = 0x00000200,
        FLAG_WINDOW_MAXIMIZED = 0x00000400,
        FLAG_WINDOW_UNFOCUSED = 0x00000800,
        FLAG_WINDOW_TOPMOST = 0x00001000,
        FLAG_WINDOW_ALWAYS_RUN = 0x00000100,
        FLAG_WINDOW_TRANSPARENT = 0x00000010,
        FLAG_WINDOW_HIGHDPI = 0x00002000,
        FLAG_WINDOW_MOUSE_PASSTHROUGH = 0x00004000,
        FLAG_BORDERLESS_WINDOWED_MODE = 0x00008000,
        FLAG_MSAA_4X_HINT = 0x00000020,
        FLAG_INTERLACED_HINT = 0x00010000
    } ConfigFlags;

    void SetConfigFlags(unsigned int flags);
    void SetWindowState(unsigned int flags);
    void ClearWindowState(unsigned int flags);
    
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
    int GetWindowPositionX(void);
    int GetWindowPositionY(void);
    void SetWindowPosition(int x, int y);
    void MinimizeWindow(void);

    Image LoadImage(const char *fileName);
    void SetWindowIcon(Image image);
    void UnloadImage(Image image);
]]

local _rl = ffi.load("raylib")
local new_colour = ffi.typeof("Color")

local FLAG_MAP = {
    vsync_hint = ffi.C.FLAG_VSYNC_HINT,
    fullscreen_mode = ffi.C.FLAG_FULLSCREEN_MODE,
    resizable = ffi.C.FLAG_WINDOW_RESIZABLE,
    undecorated = ffi.C.FLAG_WINDOW_UNDECORATED,
    transparent = ffi.C.FLAG_WINDOW_TRANSPARENT,
    hidden = ffi.C.FLAG_WINDOW_HIDDEN,
    minimized = ffi.C.FLAG_WINDOW_MINIMIZED,
    maximized = ffi.C.FLAG_WINDOW_MAXIMIZED,
    unfocused = ffi.C.FLAG_WINDOW_UNFOCUSED,
    topmost = ffi.C.FLAG_WINDOW_TOPMOST,
    always_run = ffi.C.FLAG_WINDOW_ALWAYS_RUN,
    highdpi = ffi.C.FLAG_WINDOW_HIGHDPI,
    mouse_passthrough = ffi.C.FLAG_WINDOW_MOUSE_PASSTHROUGH,
    borderless_windowed_mode = ffi.C.FLAG_BORDERLESS_WINDOWED_MODE,
    msaa_4x_hint = ffi.C.FLAG_MSAA_4X_HINT,
    interlaced_hint = ffi.C.FLAG_INTERLACED_HINT
}

--- @section Module

local window = {
    title = "Lua Engine",
    size = { width = 1280, height = 720 },
    fps = { draw = false, target = false },
    modules = { audio = false },
    icon = nil,
    undecorated = false,
    flags = {},
    running = false
}

--- Initialize the window.
--- @param opts table Optional settings
function window.init(opts)
    opts = opts or {}

    window.title = (opts.window and opts.window.title) or window.title
    window.size = (opts.window and opts.window.size) or window.size
    window.fps = opts.fps or window.fps
    window.modules = opts.modules or window.modules
    window.flags = (opts.window and opts.window.flags) or window.flags
    window.icon = (opts.window and opts.window.icon) or window.icon

    local flags = 0

    for name, enabled in pairs(window.flags) do
        local flag_constant = FLAG_MAP[string.lower(name)]
        if flag_constant and enabled then
            flags = bit.bor(flags, flag_constant)
        end
    end

    _rl.SetConfigFlags(flags)
    _rl.InitWindow(window.size.width, window.size.height, window.title)

    if window.undecorated then
        _rl.SetWindowState(ffi.C.FLAG_WINDOW_UNDECORATED) 
    end
    
    -- Set window icon if provided
    if window.icon then
        local icon_image = _rl.LoadImage(window.icon)
        if icon_image.data ~= nil then
            _rl.SetWindowIcon(icon_image)
            _rl.UnloadImage(icon_image)
        else
            print("Warning: Failed to load icon: " .. window.icon)
        end
    end

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

--- Toggle a specific window flag
--- @param flag_name string Name of the flag (e.g., "fullscreen_mode", "topmost")
--- @param enabled boolean Whether to enable or disable the flag
function window.toggle_flag(flag_name, enabled)
    local flag_constant = FLAG_MAP[string.lower(flag_name)]
    if not flag_constant then
        print("Warning: Unknown flag '" .. flag_name .. "'")
        return
    end
    
    if enabled then
        _rl.SetWindowState(flag_constant)
        window.flags[flag_name] = true
    else
        _rl.ClearWindowState(flag_constant)
        window.flags[flag_name] = false
    end
end

--- Toggle fullscreen mode (convenience function)
function window.toggle_fullscreen()
    _rl.ToggleFullscreen()
    window.flags.fullscreen_mode = not window.flags.fullscreen_mode
end

--- Set borderless windowed mode
--- @param enabled boolean Whether to enable borderless mode
function window.set_borderless(enabled)
    window.toggle_flag("borderless_windowed_mode", enabled)
end

--- Set window to be always on top
--- @param enabled boolean Whether window should be topmost
function window.set_topmost(enabled)
    window.toggle_flag("topmost", enabled)
end

--- Set window resizable state
--- @param enabled boolean Whether window should be resizable
function window.set_resizable(enabled)
    window.toggle_flag("resizable", enabled)
end

--- Set window decorated state (window border/title bar)
--- @param enabled boolean Whether window should have decorations
function window.set_decorated(enabled)
    window.toggle_flag("undecorated", not enabled)
end

--- Check if a window flag is currently enabled
--- @param flag_name string Name of the flag to check
--- @return boolean Whether the flag is enabled
function window.is_flag_enabled(flag_name)
    return window.flags[flag_name] or false
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

--- Get the window's screen position
--- @return integer x
--- @return integer y
function window.get_position()
    return _rl.GetWindowPositionX(), _rl.GetWindowPositionY()
end

--- Set the window's screen position
--- @param x number X position
--- @param y number Y position
function window.set_position(x, y)
    _rl.SetWindowPosition(x, y)
end

--- Minimize the window
function window.minimize()
    _rl.MinimizeWindow()
end

--- Close the window and audio device if enabled.
function window.close()
    if window.modules.audio then
        _rl.CloseAudioDevice()
    end
    _rl.CloseWindow()
end

return window