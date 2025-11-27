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

--- @module engine.modules.hooks
--- @description Event hook system for game and mod communication

--- @section Module

local hooks = {}

hooks.registered = {}
hooks.available = {}

--- Register a new hook type
--- @param name string Name of the hook
--- @param description string Optional description of what the hook does
function hooks.register(name, description)
    hooks.available[name] = description or ""
    hooks.registered[name] = hooks.registered[name] or {}
    print("[Hooks] Registered: " .. name)
end

--- Listen to a hook
--- @param name string Name of the hook to listen to
--- @param callback function Function to call when hook fires
function hooks.listen(name, callback)
    if type(callback) ~= "function" then
        error("Hook callback must be a function")
    end

    if not hooks.registered[name] then
        hooks.registered[name] = {}
    end
    
    table.insert(hooks.registered[name], callback)
    print("[Hooks] Listener added to: " .. name)
end

--- Fire a hook
--- @param name string Name of the hook to fire
--- @param data table Data to pass to listeners
function hooks.fire(name, data)
    if not hooks.registered[name] then
        return
    end
    
    for _, callback in ipairs(hooks.registered[name]) do
        local success, result = pcall(callback, data)
        if not success then
            print("[Hooks] Error in hook '" .. name .. "': " .. tostring(result))
        end
    end
end

--- Remove a specific listener
--- @param name string Name of the hook
--- @param callback function The callback to remove
function hooks.unlisten(name, callback)
    if not hooks.registered[name] then
        return
    end
    
    for i, cb in ipairs(hooks.registered[name]) do
        if cb == callback then
            table.remove(hooks.registered[name], i)
            print("[Hooks] Listener removed from: " .. name)
            return
        end
    end
end

--- Clear all listeners for a hook
--- @param name string Name of the hook to clear
function hooks.clear(name)
    if hooks.registered[name] then
        hooks.registered[name] = {}
        print("[Hooks] Cleared all listeners for: " .. name)
    end
end

--- Clear all hooks
function hooks.clear_all()
    hooks.registered = {}
    print("[Hooks] Cleared all hooks")
end

--- Get list of registered hooks
--- @return table List of hook names
function hooks.list()
    local list = {}
    for name, _ in pairs(hooks.available) do
        table.insert(list, name)
    end
    return list
end

return hooks