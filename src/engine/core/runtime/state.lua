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

--- @module runtime.state
--- @description Named state manager with metatable proxy for easy key access, with optional scope access.

local m = {}

local _states = {}
local _current = "__default"

local _proxy = {}

setmetatable(_proxy, {
    __index = function(_, key)
        local s = _states[_current]
        return s and s[key]
    end,
    __newindex = function(_, key, value)
        _states[_current] = _states[_current] or {}
        _states[_current][key] = value
    end,
    __pairs = function()
        return pairs(_states[_current] or {})
    end,
    __len = function()
        return #(_states[_current] or {})
    end
})

--- Switch to a named state (or create it if missing).
--- @param name string? Name of the state to use (default: "__default").
function m.use_state(name)
    _current = name or "__default"
    _states[_current] = _states[_current] or {}
end

--- Get the current state name.
--- @return string
function m.current_state()
    return _current
end

--- Set a value in a state (default: current).
--- @param key any
--- @param value any
--- @param scope string? Optional state name to write to
function m.set_state(key, value, scope)
    local target = scope or _current
    _states[target] = _states[target] or {}
    _states[target][key] = value
end

--- Get a value from a state (default: current).
--- @param key any
--- @param fallback any?
--- @param scope string? Optional state name to read from
--- @return any
function m.get_state(key, fallback, scope)
    local s = _states[scope or _current]
    return (s and s[key]) or fallback
end

--- Clear a single key from a state (default: current).
--- @param key any
--- @param scope string? Optional state name to clear from
function m.clear_state(key, scope)
    local target = scope or _current
    if _states[target] then
        _states[target][key] = nil
    end
end

--- Clear all keys from a state (default: current).
--- @param scope string? Optional state name to clear
function m.clear_all(scope)
    local target = scope or _current
    _states[target] = {}
end

--- Return all key-values from a state as a table (default: current).
--- @param scope string? Optional state name
--- @return table
function m.dump_state(scope)
    return _states[scope or _current]
end

--- Delete a named state completely.
--- @param name string
function m.delete_state(name)
    _states[name] = nil
    if _current == name then
        m.use_state("__default")
    end
end

--- List all state names.
--- @return string[]
function m.list_states()
    local list = {}
    for name in pairs(_states) do
        table.insert(list, name)
    end
    return list
end

--- Temporarily run code in another state scope.
--- @param scope string State name to use temporarily
--- @param fn function Function to execute while scoped
function m.with_state(scope, fn)
    local previous = _current
    m.use_state(scope)
    local ok, err = pcall(fn)
    m.use_state(previous)
    if not ok then error(err) end
end

--- Expose proxy for direct state access (state.key = val)
m.data = _proxy

return m