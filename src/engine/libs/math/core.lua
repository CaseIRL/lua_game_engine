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

--- @module maths.core
--- @description Handles core math functions not covered by default lua m.

local m = {}

--- Rounds a number to the specified number of decimal places.
--- @param number number The number to round.
--- @param decimals number The number of decimal places.
--- @return number The rounded number.
function m.round(number, decimals)
    local mult = 10 ^ decimals
    return math.floor(number * mult + 0.5) / mult
end

--- Clamps a value within a specified range.
--- @param val number The value to clamp.
--- @param lower number The lower bound.
--- @param upper number The upper bound.
--- @return number The clamped value.
function m.clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

--- Linearly interpolates between two values.
--- @param a number The start value.
--- @param b number The end value.
--- @param t number Interpolation factor between 0 and 1.
--- @return number The interpolated value.
function m.lerp(a, b, t)
    return a + (b - a) * t
end

--- Calculates the factorial of a non-negative integer.
--- @param n number The integer to compute factorial for.
--- @return number The factorial of n.
function m.factorial(n)
    if n == 0 then
        return 1
    else
        return n * m.factorial(n - 1)
    end
end

--- Converts degrees to radians.
--- @param deg number Angle in degrees.
--- @return number Angle in radians.
function m.deg_to_rad(deg)
    return deg * (math.pi / 180)
end

--- Converts radians to degrees.
--- @param rad number Angle in radians.
--- @return number Angle in degrees.
function m.rad_to_deg(rad)
    return rad * (180 / math.pi)
end

return m