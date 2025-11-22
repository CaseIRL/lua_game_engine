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

--- @module engine.core.input
--- @description Handles keyboard and mouse input.

--- @section FFI

local ffi = require("ffi")

ffi.cdef[[
    typedef struct { float x, y; } Vector2;
    
    bool IsKeyDown(int key);
    bool IsKeyPressed(int key);
    int GetMouseX(void);
    int GetMouseY(void);
    bool IsMouseButtonPressed(int button);
    bool IsMouseButtonDown(int button);
    Vector2 GetMouseDelta(void);
    void SetMousePosition(int x, int y);
    void ShowCursor(void);
    void HideCursor(void);
    void EnableCursor(void);
    void DisableCursor(void);
]]

local _rl = ffi.load("raylib")

--- @section Module

local input = {
    keymap = {
        --- Letters
        a = 65, b = 66, c = 67, d = 68, e = 69, f = 70, g = 71, h = 72, i = 73, j = 74,
        k = 75, l = 76, m = 77, n = 78, o = 79, p = 80, q = 81, r = 82, s = 83, t = 84,
        u = 85, v = 86, w = 87, x = 88, y = 89, z = 90,

        --- Numbers
        ["0"] = 48, ["1"] = 49, ["2"] = 50, ["3"] = 51, ["4"] = 52,
        ["5"] = 53, ["6"] = 54, ["7"] = 55, ["8"] = 56, ["9"] = 57,
        
        --- F keys
        f1 = 290, f2 = 291, f3 = 292, f4 = 293, f5 = 294, f6 = 295,
        f7 = 296, f8 = 297, f9 = 298, f10 = 299, f11 = 300, f12 = 301,

        --- Special
        space = 32, enter = 257, escape = 256, tab = 259, backspace = 259,
        leftshift = 340, rightshift = 344, leftctrl = 341, rightctrl = 345,
        leftalt = 342, rightalt = 346,
        arrowup = 265, arrowdown = 264, arrowleft = 263, arrowright = 262,
        home = 268, end_key = 269, pageup = 266, pagedown = 267,
        insert = 260, delete = 261,
    }
}

--- Check if a key is currently pressed.
--- @param key string|number Key name or key code.
--- @return boolean True if the key is down.
function input.is_key_down(key)
    return _rl.IsKeyDown(input.keymap[key] or key)
end

--- Check if a key was pressed this frame.
--- @param key string|number Key name or key code.
--- @return boolean True if the key was pressed.
function input.is_key_pressed(key)
    return _rl.IsKeyPressed(input.keymap[key] or key)
end

--- Check if a mouse button was pressed this frame.
--- @param button number Mouse button index.
--- @return boolean True if the button was pressed.
function input.is_mouse_pressed(button)
    return _rl.IsMouseButtonPressed(button)
end

--- Check if a mouse button is currently down.
--- @param button number Mouse button index.
--- @return boolean True if the button is down.
function input.is_mouse_down(button)
    return _rl.IsMouseButtonDown(button)
end

--- Get the current mouse position.
--- @return number x The x coordinate.
--- @return number y The y coordinate.
function input.get_mouse_pos()
    return _rl.GetMouseX(), _rl.GetMouseY()
end

--- Get the mouse movement delta since last frame.
--- @return number dx Delta x.
--- @return number dy Delta y.
function input.get_mouse_delta()
    local v = _rl.GetMouseDelta()
    return v.x, v.y
end

--- Set the mouse cursor position.
--- @param x number X coordinate.
--- @param y number Y coordinate.
function input.set_mouse_pos(x, y)
    _rl.SetMousePosition(x, y)
end

--- Show the mouse cursor.
function input.show_cursor()
    _rl.ShowCursor()
end

--- Hide the mouse cursor.
function input.hide_cursor()
    _rl.HideCursor()
end

--- Lock the mouse cursor (disable).
function input.lock_cursor()
    _rl.DisableCursor()
end

--- Unlock the mouse cursor (enable).
function input.unlock_cursor()
    _rl.EnableCursor()
end

return input