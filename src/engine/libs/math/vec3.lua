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

--- @module maths.vec3
--- @description Minimal Vec3 math module with metamethods.

local vec3 = {}

vec3.__index = vec3

-- Epsilon for floating-point comparisons
local EPSILON = 1e-10

--- Create a new vec3 instance
--- @param x number|nil X component (default 0)
--- @param y number|nil Y component (default 0)
--- @param z number|nil Z component (default 0)
--- @return table New vec3 instance
function vec3.new(x, y, z)
    return setmetatable({
        x = type(x) == "number" and x or 0,
        y = type(y) == "number" and y or 0,
        z = type(z) == "number" and z or 0
    }, vec3)
end

--- Create a copy of a vector
--- @param v table Vector to copy
--- @return table New vec3 copy
function vec3.copy(v)
    if not v or not v.x then
        error("Invalid vector for copy")
    end
    return vec3.new(v.x, v.y, v.z)
end

--- Set vector components in-place
--- @param v table Vector to modify
--- @param x number New x component
--- @param y number New y component
--- @param z number New z component
--- @return table The modified vector
function vec3.set(v, x, y, z)
    if not v then
        error("Invalid vector for set")
    end
    v.x = type(x) == "number" and x or 0
    v.y = type(y) == "number" and y or 0
    v.z = type(z) == "number" and z or 0
    return v
end

--- Add two vectors
--- @param a table First vector
--- @param b table Second vector
--- @return table Result vector
function vec3.add(a, b)
    if not a or not b or not a.x or not b.x then
        error("Invalid vectors for addition")
    end
    return vec3.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

--- Subtract two vectors
--- @param a table First vector
--- @param b table Second vector
--- @return table Result vector
function vec3.sub(a, b)
    if not a or not b or not a.x or not b.x then
        error("Invalid vectors for subtraction")
    end
    return vec3.new(a.x - b.x, a.y - b.y, a.z - b.z)
end

--- Scale a vector by a scalar
--- @param v table Vector to scale
--- @param s number Scalar value
--- @return table Scaled vector
function vec3.scale(v, s)
    if not v or not v.x or type(s) ~= "number" then
        error("Invalid vector or scalar for scaling")
    end
    return vec3.new(v.x * s, v.y * s, v.z * s)
end

--- Calculate dot product of two vectors
--- @param a table First vector
--- @param b table Second vector
--- @return number Dot product
function vec3.dot(a, b)
    if not a or not b or not a.x or not b.x then
        error("Invalid vectors for dot product")
    end
    return a.x * b.x + a.y * b.y + a.z * b.z
end

--- Calculate cross product of two vectors
--- @param a table First vector
--- @param b table Second vector
--- @return table Cross product vector
function vec3.cross(a, b)
    if not a or not b or not a.x or not b.x then
        error("Invalid vectors for cross product")
    end
    return vec3.new(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

--- Calculate length (magnitude) of a vector
--- @param v table Vector
--- @return number Length of the vector
function vec3.length(v)
    if not v or not v.x then
        error("Invalid vector for length calculation")
    end
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

--- Calculate squared length (faster than length for comparisons)
--- @param v table Vector
--- @return number Squared length
function vec3.length_squared(v)
    if not v or not v.x then
        error("Invalid vector for length calculation")
    end
    return v.x * v.x + v.y * v.y + v.z * v.z
end

--- Normalize a vector (unit vector)
--- @param v table Vector to normalize
--- @return table Normalized vector
function vec3.normalize(v)
    if not v or not v.x then
        error("Invalid vector for normalization")
    end
    local len = vec3.length(v)
    if len > EPSILON then
        return vec3.new(v.x / len, v.y / len, v.z / len)
    end
    return vec3.new(0, 0, 0)
end

--- Check if vector is zero (within epsilon tolerance)
--- @param v table Vector to check
--- @return boolean True if vector is effectively zero
function vec3.is_zero(v)
    if not v or not v.x then
        error("Invalid vector for zero check")
    end
    return vec3.length_squared(v) < EPSILON * EPSILON
end

--- Calculate distance between two points
--- @param a table First point
--- @param b table Second point
--- @return number Distance between points
function vec3.distance(a, b)
    if not a or not b or not a.x or not b.x then
        error("Invalid vectors for distance calculation")
    end
    return vec3.length(vec3.sub(a, b))
end

--- Calculate squared distance (faster for comparisons)
--- @param a table First point
--- @param b table Second point
--- @return number Squared distance
function vec3.distance_squared(a, b)
    if not a or not b or not a.x or not b.x then
        error("Invalid vectors for distance calculation")
    end
    return vec3.length_squared(vec3.sub(a, b))
end

--- Linear interpolation between two vectors
--- @param a table Start vector
--- @param b table End vector
--- @param t number Interpolation factor (0 to 1)
--- @return table Interpolated vector
function vec3.lerp(a, b, t)
    if not a or not b or not a.x or not b.x then
        error("Invalid vectors for lerp")
    end
    if type(t) ~= "number" then
        error("Interpolation factor must be a number")
    end
    return vec3.new(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t)
end

--- Metamethod: Addition
function vec3.__add(a, b)
    return vec3.add(a, b)
end

--- Metamethod: Subtraction
function vec3.__sub(a, b)
    return vec3.sub(a, b)
end

--- Metamethod: Scalar multiplication (vec * scalar or scalar * vec)
function vec3.__mul(a, b)
    if type(a) == "number" then
        return vec3.scale(b, a)
    else
        return vec3.scale(a, b)
    end
end

--- Metamethod: Division by scalar
function vec3.__div(a, b)
    if type(b) ~= "number" then
        error("Can only divide vector by number")
    end
    if math.abs(b) < EPSILON then
        error("Division by zero")
    end
    return vec3.scale(a, 1 / b)
end

--- Metamethod: String representation
function vec3.__tostring(v)
    return string.format("vec3(%.3f, %.3f, %.3f)", v.x, v.y, v.z)
end

--- Metamethod: Equality comparison
function vec3.__eq(a, b)
    if not a or not b then
        return false
    end
    return math.abs(a.x - b.x) < EPSILON and math.abs(a.y - b.y) < EPSILON and math.abs(a.z - b.z) < EPSILON
end

--- Callable constructor: vec3(x, y, z) instead of vec3.new(x, y, z)
return setmetatable(vec3, {
    __call = function(_, x, y, z)
        return vec3.new(x, y, z)
    end
})