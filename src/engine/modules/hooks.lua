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

local m = {}

m.registered = {}
m.available = {}

--- Register a new hook type
--- @param name string Name of the hook
--- @param description string Optional description of what the hook does
function m.register(name, description)
    m.available[name] = description or ""
    m.registered[name] = m.registered[name] or {}
    print("[Hooks] Registered: " .. name)
end

--- Listen to a hook
--- @param name string Name of the hook to listen to
--- @param callback function Function to call when hook fires
function m.listen(name, callback)
    if type(callback) ~= "function" then
        error("Hook callback must be a function")
    end

    if not m.registered[name] then
        m.registered[name] = {}
    end
    
    table.insert(m.registered[name], callback)
    print("[Hooks] Listener added to: " .. name)
end

--- Fire a hook
--- @param name string Name of the hook to fire
--- @param data table Data to pass to listeners
function m.fire(name, data)
    if not m.registered[name] then
        return
    end
    
    for _, callback in ipairs(m.registered[name]) do
        local success, result = pcall(callback, data)
        if not success then
            print("[Hooks] Error in hook '" .. name .. "': " .. tostring(result))
        end
    end
end

--- Remove a specific listener
--- @param name string Name of the hook
--- @param callback function The callback to remove
function m.unlisten(name, callback)
    if not m.registered[name] then
        return
    end
    
    for i, cb in ipairs(m.registered[name]) do
        if cb == callback then
            table.remove(m.registered[name], i)
            print("[Hooks] Listener removed from: " .. name)
            return
        end
    end
end

--- Clear all listeners for a hook
--- @param name string Name of the hook to clear
function m.clear(name)
    if m.registered[name] then
        m.registered[name] = {}
        print("[Hooks] Cleared all listeners for: " .. name)
    end
end

--- Clear all hooks
function m.clear_all()
    m.registered = {}
    print("[Hooks] Cleared all hooks")
end

--- Get list of registered hooks
--- @return table List of hook names
function m.list()
    local list = {}
    for name, _ in pairs(m.available) do
        table.insert(list, name)
    end
    return list
end

return m