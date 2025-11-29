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

--- @module runtime.timers
--- @description Generic timer manager.

local m = {}

local _next_id = 0
local _active = {}

--- @section Helpers

--- Generate a unique timer ID.
local function _generate_id()
    _next_id = _next_id + 1
    return _next_id
end

--- @section API

--- Run a function after a delay (once).
--- @param delay number: Seconds to wait
--- @param fn function: Callback to call
--- @return number id: Timer ID
function m.set_timer(delay, fn)
    local id = _generate_id()
    _active[id] = {
        id = id,
        time = delay,
        repeat_timer = 0,
        interval = 0,
        fn = fn
    }
    return id
end

--- Repeated timer (like setInterval)
--- @param interval number: Interval in seconds
--- @param fn function: Function to call
--- @param count number: How many times to repeat_timer (-1 = infinite)
--- @return number id: Timer ID
function m.repeat_timer(interval, fn, count)
    local id = _generate_id()
    _active[id] = {
        id = id,
        time = interval,
        interval = interval,
        repeat_timer = count or -1,
        fn = fn
    }
    return id
end

--- Cancel a timer by ID
--- @param id number
function m.cancel_timer(id)
    _active[id] = nil
end

--- Clear all active timers
function m.clear_all_timers()
    _active = {}
end

--- Call every frame to advance timers
--- @param dt number: Delta time (seconds)
function m.update_timer(dt)
    for id, t in pairs(_active) do
        t.time = t.time - dt
        if t.time <= 0 then
            local ok, err = pcall(t.fn)
            if not ok then
                print("[utilitas.timer] Timer " .. id .. " error:", err)
            end
            if t.repeat_timer == 0 then
                _active[id] = nil
            else
                if t.repeat_timer > 0 then
                    t.repeat_timer = t.repeat_timer - 1
                end
                t.time = t.interval
            end
        end
    end
end

return m