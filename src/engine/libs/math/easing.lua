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

--- @module m.easing
--- @description Common easing functions for animations, tweens, transitions, etc.

local m = {}

-- Epsilon for floating-point comparisons
local EPSILON = 1e-10

--- Linear easing (no curve).
--- @param t number Current time [0–1]
--- @return number Eased value
function m.linear(t)
    return t
end

--- Quadratic ease-in.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.in_quad(t)
    return t * t
end

--- Quadratic ease-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.out_quad(t)
    return t * (2 - t)
end

--- Quadratic ease-in-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.in_out_quad(t)
    return (t < 0.5) and (2 * t * t) or (-1 + (4 - 2 * t) * t)
end

--- Cubic ease-in.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.in_cubic(t)
    return t * t * t
end

--- Cubic ease-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.out_cubic(t)
    t = t - 1
    return t * t * t + 1
end

--- Cubic ease-in-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.in_out_cubic(t)
    return (t < 0.5) and (4 * t * t * t) or ((t - 1) * (2 * t - 2)^2 + 1)
end

--- Elastic ease-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.out_elastic(t)
    if math.abs(t) < EPSILON or math.abs(t - 1) < EPSILON then
        return t
    end
    return (math.pow(2, -10 * t) * math.sin((t - 0.075) * (2 * math.pi) / 0.3) + 1)
end

return m