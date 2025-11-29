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
    
--- @module runtime.cooldowns
--- @description Engine-agnostic cooldown tracker. Works for keys, users, or global.

local m = {}

--- @section Tables

local _registry = {}

--- @section API

--- Add a cooldown for a given id + type
--- @param id string|number: Unique actor/user/entity
--- @param type string: Action/type key
--- @param duration number: Duration in seconds
function m.add_cooldown(id, type, duration)
    assert(id, "m.add_cooldown: id is required")
    assert(type, "m.add_cooldown: type is required")
    assert(duration and duration > 0, "m.add_cooldown: duration must be > 0")

    _registry[id] = _registry[id] or {}
    _registry[id][type] = { expires = os.time() + duration }
end

--- Check if a cooldown is still active
--- @param id string|number: Unique actor/user/entity
--- @param type string: Action/type key
--- @return boolean
function m.check_cooldown(id, type)
    local now = os.time()
    local data = _registry[id] and _registry[id][type]
    return data and now < data.expires
end

--- Get remaining time on cooldown (0 if none)
--- @param id string|number: Unique actor/user/entity
--- @param type string: Action/type key
--- @return number
function m.cooldown_time_remaining(id, type)
    local data = _registry[id] and _registry[id][type]
    if not data then return 0 end
    return math.max(0, data.expires - os.time())
end

--- Clear a specific cooldown
--- @param id string|number: Unique actor/user/entity
--- @param type string: Action/type key
function m.clear_cooldown(id, type)
    if _registry[id] then
        _registry[id][type] = nil
        if not next(_registry[id]) then _registry[id] = nil end
    end
end

--- Remove all cooldowns for a given id
--- @param id string|number: Unique actor/user/entity
function m.clear_all_cooldowns(id)
    _registry[id] = nil
end

--- Clear all expired cooldowns
function m.clear_expired_cooldowns()
    local now = os.time()
    for id, types in pairs(_registry) do
        for type, data in pairs(types) do
            if now >= data.expires then
                types[type] = nil
            end
        end
        if not next(types) then
            _registry[id] = nil
        end
    end
end

return m