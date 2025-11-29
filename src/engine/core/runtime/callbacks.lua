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
    
--- @module runtime.callbacks
--- @description Lightweight callback _registry

local m = {}

--- @section Tables

local _registry = {} -- internal name → function map

--- @section Module Functions

--- Register a callback.
--- @param name string: Unique key.
--- @param fn function: The function to store.
--- @param overwrite? boolean: Set true to replace an existing entry (default false).
function m.register_callback(name, fn, overwrite)
    assert(type(name) == "string",  "name must be string")
    assert(type(fn)  == "function", "fn must be function")
    if _registry[name] and not overwrite then
        error(("callback '%s' exists"):format(name), 2)
    end
    _registry[name] = fn
end

--- Trigger a callback.
--- @param name string: Key to look up.
--- @return ...: Whatever the stored function returns, or nil + error message.
function m.trigger_callback(name, ...)
    local cb = _registry[name]
    return cb and cb(...) or nil, ("callback '%s' not found"):format(name)
end

--- Remove a callback.
--- @param name string
function m.unregister_callback(name)
    _registry[name] = nil
end

--- Check whether a callback exists.
--- @param name string
--- @return boolean
function m.callback_exists(name)
    return _registry[name] ~= nil
end

--- Iterate over all m.
--- @return function iterator
function m.get_each_callback()
    return next, _registry
end

return m