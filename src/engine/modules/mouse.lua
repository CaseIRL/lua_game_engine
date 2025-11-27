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

--- @module engine.module.mouse
--- @description High-level drawing helpers wrapping Raylib FFI calls.

--- @section FFI

local ffi = require("ffi")

ffi.cdef[[
    typedef struct { float x, y; } Vector2;
    
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

local mouse = {}

--- Get the current mouse position
--- @return number x Current cursor X position
--- @return number y Current cursor Y position
function mouse.get_pos()
    return _rl.GetMouseX(), _rl.GetMouseY()
end

--- Check if a mouse button was pressed this frame
--- @param button number Mouse button index (e.g. 0 = left, 1 = right)
--- @return boolean pressed True if the button was pressed this frame
function mouse.is_pressed(button)
    return _rl.IsMouseButtonPressed(button)
end

--- Check if a mouse button is currently held down
--- @param button number Mouse button index (0 = left, 1 = right)
--- @return boolean down True if the button is being held down
function mouse.is_down(button)
    return _rl.IsMouseButtonDown(button)
end

--- Get mouse movement delta since last frame
--- @return number dx Horizontal mouse movement
--- @return number dy Vertical mouse movement
function mouse.get_delta()
    local v = _rl.GetMouseDelta()
    return v.x, v.y
end

--- Set the mouse cursor position
--- @param x number New cursor X position
--- @param y number New cursor Y position
function mouse.set_pos(x, y)
    _rl.SetMousePosition(x, y)
end

--- Show the mouse cursor
function mouse.show()
    _rl.ShowCursor()
end

--- Hide the mouse cursor
function mouse.hide()
    _rl.HideCursor()
end

--- Lock the mouse cursor
function mouse.lock()
    _rl.DisableCursor()
end

--- Unlock the mouse cursor
function mouse.unlock()
    _rl.EnableCursor()
end

return mouse