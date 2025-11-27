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

--- @module engine.modules.actions
--- @description Handles action mapping to controls.

--- @section Engine Modules

local _keyboard = require("src.engine.modules.keyboard")
local _mouse = require("src.engine.modules.mouse")

--- @section FFI

local ffi = require("ffi")

ffi.cdef[[
    double GetTime(void);
]]

local _rl = ffi.load("raylib")

--- @section Module

local actions = {
    _actions = {},
    _state = {}
}

--- Check if a binding is triggered
--- @param binding table|string The binding to check. Can be a string (keyboard key) or a table with `mouse_button`.
--- @param check_fn function Function to check the binding against a device.
--- @return boolean True if the binding is triggered, false otherwise
local function check_binding(binding, check_fn)
    if type(binding) == "string" then
        return check_fn(_keyboard, binding)
    elseif binding.mouse_button then
        return check_fn(_mouse, binding.mouse_button)
    end
    return false
end

--- Check if any binding in a list is triggered
--- @param bindings table List of bindings (string or table) to check
--- @param check_fn function Function to check each binding against a device
--- @return boolean True if any binding is triggered, false otherwise
local function check_any_binding(bindings, check_fn)
    for _, binding in ipairs(bindings) do
        if check_binding(binding, check_fn) then
            return true
        end
    end
    return false
end

--- Map an action name to a list of input bindings
--- @param name string Unique name of the action
--- @param bindings table List of bindings (string or table) associated with the action
function actions.map_action(name, bindings)
    actions._actions[name] = bindings
    actions._state[name] = { held_since = nil, prev = false, current = false }
end

--- Update action states
function actions.update()
    local now = _rl.GetTime()
    for name, bindings in pairs(actions._actions) do
        local st = actions._state[name]
        st.prev = st.current
        st.current = actions.is_action_down(name)
        
        if st.current then
            if not st.held_since then
                st.held_since = now
            end
        else
            st.held_since = nil
        end
    end
end

--- Check if an action is currently pressed (instant press)
--- @param name string Name of the action
--- @return boolean True if any of the actions bindings are pressed, false otherwise
function actions.is_action_pressed(name)
    local bindings = actions._actions[name]
    return bindings and check_any_binding(bindings, function(device, key)
        return device.is_pressed(key)
    end) or false
end

--- Check if an action is currently held down
--- @param name string Name of the action
--- @return boolean True if any of the actions bindings are held down, false otherwise
function actions.is_action_down(name)
    local bindings = actions._actions[name]
    return bindings and check_any_binding(bindings, function(device, key)
        return device.is_down(key)
    end) or false
end

--- Check if an action was just released this frame
--- Requires actions.update() to be called each frame
--- @param name string Name of the action
--- @return boolean True if the action was released this frame
function actions.is_action_released(name)
    local st = actions._state[name]
    if not st then return false end
    return st.prev == true and st.current == false
end

--- Get how long an action has been held down in seconds
--- Requires actions.update() to be called each frame
--- @param name string Name of the action
--- @return number Seconds the action has been held (0 if not currently down)
function actions.hold_time(name)
    local st = actions._state[name]
    if not st or not st.current or not st.held_since then
        return 0
    end
    return _rl.GetTime() - st.held_since
end

--- Clear all action mappings
function actions.clear_actions()
    actions._actions = {}
    actions._state = {}
end

return actions