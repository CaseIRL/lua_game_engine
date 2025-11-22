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

--- @module engine.modules.keyboard
--- @description Handles keyboard input stuff; split for ease in future.

--- @section FFI

local ffi = require("ffi")

ffi.cdef[[
    bool IsKeyDown(int key);
    bool IsKeyPressed(int key);
]]

local _rl = ffi.load("raylib")

--- @section Module

local keyboard = {
    keymap = {
        -- Letters
        a = 65, b = 66, c = 67, d = 68, e = 69, f = 70, g = 71, h = 72, i = 73, j = 74,
        k = 75, l = 76, m = 77, n = 78, o = 79, p = 80, q = 81, r = 82, s = 83, t = 84,
        u = 85, v = 86, w = 87, x = 88, y = 89, z = 90,
        
        -- Numbers
        ["0"] = 48, ["1"] = 49, ["2"] = 50, ["3"] = 51, ["4"] = 52,
        ["5"] = 53, ["6"] = 54, ["7"] = 55, ["8"] = 56, ["9"] = 57,

        -- F Keys
        f1 = 290, f2 = 291, f3 = 292, f4 = 293, f5 = 294, f6 = 295,
        f7 = 296, f8 = 297, f9 = 298, f10 = 299, f11 = 300, f12 = 301,
        
        -- Special
        space = 32, enter = 257, escape = 256, tab = 259, backspace = 259,
        leftshift = 340, rightshift = 344, leftctrl = 341, rightctrl = 345,
        leftalt = 342, rightalt = 346,
        arrowup = 265, arrowdown = 264, arrowleft = 263, arrowright = 262,
        home = 268, end_key = 269, pageup = 266, pagedown = 267,
        insert = 260, delete = 261,
    }
}

--- Check if a key is currently held down
--- @param key string|number Key name (e.g. "w") or raw Raylib keycode
--- @return boolean down True if the key is currently down
function keyboard.is_down(key)
    return _rl.IsKeyDown(keyboard.keymap[key] or key)
end

--- Check if a key was pressed this frame
--- @param key string|number Key name (e.g. "space") or raw Raylib keycode
--- @return boolean pressed True if the key was pressed this frame
function keyboard.is_pressed(key)
    return _rl.IsKeyPressed(keyboard.keymap[key] or key)
end

return keyboard