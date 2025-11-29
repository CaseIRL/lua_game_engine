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

--- @module maths.mat4
--- @description Matrix utility module for 3D transformations (4x4 matrices)

local mat4 = {}

mat4.__index = mat4

local EPSILON = 1e-10

--- Create a new identity matrix instance
--- @param values table|nil Optional raw values (length 16)
--- @return mat4 instance
function mat4.new(values)
    local self = setmetatable({}, mat4)
    self.m = {}
    for i = 1, 16 do
        self.m[i] = values and values[i] or ((i == 1 or i == 6 or i == 11 or i == 16) and 1 or 0)
    end
    return self
end

--- Create a translation matrix
--- @param x number Translation in X axis
--- @param y number Translation in Y axis
--- @param z number Translation in Z axis
--- @return mat4 Translation matrix
function mat4.translate(x, y, z)
    return mat4.new({
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        x, y, z, 1
    })
end

--- Create a rotation matrix from Euler angles (XYZ order)
--- @param rx number Rotation in X axis (degrees)
--- @param ry number Rotation in Y axis (degrees)
--- @param rz number Rotation in Z axis (degrees)
--- @return mat4 Rotation matrix
function mat4.rotate_euler(rx, ry, rz)
    local rx_rad = math.rad(rx)
    local ry_rad = math.rad(ry)
    local rz_rad = math.rad(rz)
    
    local sin_x, cos_x = math.sin(rx_rad), math.cos(rx_rad)
    local sin_y, cos_y = math.sin(ry_rad), math.cos(ry_rad)
    local sin_z, cos_z = math.sin(rz_rad), math.cos(rz_rad)
    
    return mat4.new({
        cos_y * cos_z, cos_y * sin_z, -sin_y, 0,
        sin_x * sin_y * cos_z - cos_x * sin_z, sin_x * sin_y * sin_z + cos_x * cos_z, sin_x * cos_y, 0,
        cos_x * sin_y * cos_z + sin_x * sin_z, cos_x * sin_y * sin_z - sin_x * cos_z, cos_x * cos_y, 0,
        0, 0, 0, 1
    })
end

--- Create a rotation matrix around a specific axis
--- @param axis table Rotation axis (x, y, z) - should be normalized
--- @param angle number Rotation angle in degrees
--- @return mat4 Rotation matrix
function mat4.rotate_axis(axis, angle)
    local angle_rad = math.rad(angle)
    local sin_a = math.sin(angle_rad)
    local cos_a = math.cos(angle_rad)
    local one_minus_cos = 1 - cos_a
    
    local x, y, z = axis.x, axis.y, axis.z
    
    return mat4.new({
        cos_a + x*x*one_minus_cos, x*y*one_minus_cos + z*sin_a, x*z*one_minus_cos - y*sin_a, 0,
        x*y*one_minus_cos - z*sin_a, cos_a + y*y*one_minus_cos, y*z*one_minus_cos + x*sin_a, 0,
        x*z*one_minus_cos + y*sin_a, y*z*one_minus_cos - x*sin_a, cos_a + z*z*one_minus_cos, 0,
        0, 0, 0, 1
    })
end

--- Create a scale matrix
--- @param sx number Scale in X axis
--- @param sy number Scale in Y axis
--- @param sz number Scale in Z axis
--- @return mat4 Scale matrix
function mat4.scale(sx, sy, sz)
    return mat4.new({
        sx, 0, 0, 0,
        0, sy, 0, 0,
        0, 0, sz, 0,
        0, 0, 0, 1
    })
end

--- Create a perspective projection matrix
--- @param fov number Field of view in degrees
--- @param aspect number Aspect ratio (width / height)
--- @param near number Near clipping plane
--- @param far number Far clipping plane
--- @return mat4 Perspective matrix
function mat4.perspective(fov, aspect, near, far)
    if near <= 0 or far <= 0 or near >= far then
        error("Invalid near/far planes for perspective matrix")
    end
    
    local f = 1 / math.tan(math.rad(fov) / 2)
    return mat4.new({
        f / aspect, 0, 0, 0,
        0, f, 0, 0,
        0, 0, (far + near) / (near - far), -1,
        0, 0, (2 * far * near) / (near - far), 0
    })
end

--- Create an orthographic projection matrix
--- @param left number Left clipping plane
--- @param right number Right clipping plane
--- @param bottom number Bottom clipping plane
--- @param top number Top clipping plane
--- @param near number Near clipping plane
--- @param far number Far clipping plane
--- @return mat4 Orthographic matrix
function mat4.orthographic(left, right, bottom, top, near, far)
    return mat4.new({
        2 / (right - left), 0, 0, 0,
        0, 2 / (top - bottom), 0, 0,
        0, 0, -2 / (far - near), 0,
        -(right + left) / (right - left), -(top + bottom) / (top - bottom), -(far + near) / (far - near), 1
    })
end

--- Create a look-at matrix
--- @param eye table Eye position (x, y, z)
--- @param target table Target position (x, y, z)
--- @param up table Up vector (x, y, z)
--- @return mat4 Look-at matrix
function mat4.look_at(eye, target, up)
    local function safe_normalize(v)
        local len = math.sqrt(v.x^2 + v.y^2 + v.z^2)
        return len > EPSILON and { x = v.x/len, y = v.y/len, z = v.z/len } or { x=0,y=0,z=0 }
    end

    local function cross(a, b)
        return { x = a.y*b.z - a.z*b.y, y = a.z*b.x - a.x*b.z, z = a.x*b.y - a.y*b.x }
    end

    local function subtract(a, b)
        return { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }
    end

    local z = safe_normalize(subtract(eye, target))
    local x = safe_normalize(cross(up, z))
    local y = cross(z, x)

    return mat4.new({
        x.x, y.x, z.x, 0,
        x.y, y.y, z.y, 0,
        x.z, y.z, z.z, 0,
        -(x.x*eye.x + x.y*eye.y + x.z*eye.z),
        -(y.x*eye.x + y.y*eye.y + y.z*eye.z),
        -(z.x*eye.x + z.y*eye.y + z.z*eye.z),
        1
    })
end

--- Multiply this matrix with another mat4
--- @param self mat4 First matrix
--- @param other mat4 Second matrix
--- @return mat4 Result of multiplication
function mat4:multiply(other)
    if not other or not other.m then
        error("Cannot multiply with non-mat4 object")
    end
    
    local a = self.m
    local b = other.m
    local r = {}
    
    for row = 0, 3 do
        for col = 0, 3 do
            r[1 + row * 4 + col] =
                a[1 + row * 4 + 0] * b[1 + 0 * 4 + col] +
                a[1 + row * 4 + 1] * b[1 + 1 * 4 + col] +
                a[1 + row * 4 + 2] * b[1 + 2 * 4 + col] +
                a[1 + row * 4 + 3] * b[1 + 3 * 4 + col]
        end
    end
    
    return mat4.new(r)
end

--- Multiply matrix with a 3D vector (treats as 4D with w=1), returns 3D result
--- @param self mat4 Matrix
--- @param v table Vector (x, y, z)
--- @return table Transformed vector (x, y, z)
function mat4:multiply_vec3(v)
    if not v or not v.x or not v.y or not v.z then
        error("Invalid vector for multiplication")
    end
    
    local m = self.m
    local x = v.x
    local y = v.y
    local z = v.z
    
    local res_x = m[1]*x + m[5]*y + m[9]*z + m[13]
    local res_y = m[2]*x + m[6]*y + m[10]*z + m[14]
    local res_z = m[3]*x + m[7]*y + m[11]*z + m[15]
    local res_w = m[4]*x + m[8]*y + m[12]*z + m[16]
    
    if math.abs(res_w) > EPSILON then
        res_x = res_x / res_w
        res_y = res_y / res_w
        res_z = res_z / res_w
    end
    
    return { x = res_x, y = res_y, z = res_z }
end

--- Transpose the matrix
--- @param self mat4 Matrix to transpose
--- @return mat4 Transposed matrix
function mat4:transpose()
    local m = self.m
    return mat4.new({
        m[1], m[5], m[9],  m[13],
        m[2], m[6], m[10], m[14],
        m[3], m[7], m[11], m[15],
        m[4], m[8], m[12], m[16],
    })
end

--- Invert the matrix
--- @param self mat4 Matrix to invert
--- @return mat4|nil Inverted matrix, or nil if matrix is singular
function mat4:invert()
    local t = self.m
    local inv = {}

    inv[1] = t[6]*t[11]*t[16] - t[6]*t[12]*t[15] - t[10]*t[7]*t[16] + t[10]*t[8]*t[15] + t[14]*t[7]*t[12] - t[14]*t[8]*t[11]
    inv[2] = -t[2]*t[11]*t[16] + t[2]*t[12]*t[15] + t[10]*t[3]*t[16] - t[10]*t[4]*t[15] - t[14]*t[3]*t[12] + t[14]*t[4]*t[11]
    inv[3] = t[2]*t[7]*t[16] - t[2]*t[8]*t[15] - t[6]*t[3]*t[16] + t[6]*t[4]*t[15] + t[14]*t[3]*t[8] - t[14]*t[4]*t[7]
    inv[4] = -t[2]*t[7]*t[12] + t[2]*t[8]*t[11] + t[6]*t[3]*t[12] - t[6]*t[4]*t[11] - t[10]*t[3]*t[8] + t[10]*t[4]*t[7]

    inv[5] = -t[5]*t[11]*t[16] + t[5]*t[12]*t[15] + t[9]*t[7]*t[16] - t[9]*t[8]*t[15] - t[13]*t[7]*t[12] + t[13]*t[8]*t[11]
    inv[6] = t[1]*t[11]*t[16] - t[1]*t[12]*t[15] - t[9]*t[3]*t[16] + t[9]*t[4]*t[15] + t[13]*t[3]*t[12] - t[13]*t[4]*t[11]
    inv[7] = -t[1]*t[7]*t[16] + t[1]*t[8]*t[15] + t[5]*t[3]*t[16] - t[5]*t[4]*t[15] - t[13]*t[3]*t[8] + t[13]*t[4]*t[7]
    inv[8] = t[1]*t[7]*t[12] - t[1]*t[8]*t[11] - t[5]*t[3]*t[12] + t[5]*t[4]*t[11] + t[9]*t[3]*t[8] - t[9]*t[4]*t[7]

    inv[9] = t[5]*t[10]*t[16] - t[5]*t[12]*t[14] - t[9]*t[6]*t[16] + t[9]*t[8]*t[14] + t[13]*t[6]*t[12] - t[13]*t[8]*t[10]
    inv[10] = -t[1]*t[10]*t[16] + t[1]*t[12]*t[14] + t[9]*t[2]*t[16] - t[9]*t[4]*t[14] - t[13]*t[2]*t[12] + t[13]*t[4]*t[10]
    inv[11] = t[1]*t[6]*t[16] - t[1]*t[8]*t[14] - t[5]*t[2]*t[16] + t[5]*t[4]*t[14] + t[13]*t[2]*t[8] - t[13]*t[4]*t[6]
    inv[12] = -t[1]*t[6]*t[12] + t[1]*t[8]*t[10] + t[5]*t[2]*t[12] - t[5]*t[4]*t[10] - t[9]*t[2]*t[8] + t[9]*t[4]*t[6]

    inv[13] = -t[5]*t[10]*t[15] + t[5]*t[11]*t[14] + t[9]*t[6]*t[15] - t[9]*t[7]*t[14] - t[13]*t[6]*t[11] + t[13]*t[7]*t[10]
    inv[14] = t[1]*t[10]*t[15] - t[1]*t[11]*t[14] - t[9]*t[2]*t[15] + t[9]*t[3]*t[14] + t[13]*t[2]*t[11] - t[13]*t[3]*t[10]
    inv[15] = -t[1]*t[6]*t[15] + t[1]*t[7]*t[14] + t[5]*t[2]*t[15] - t[5]*t[3]*t[14] - t[13]*t[2]*t[7] + t[13]*t[3]*t[6]
    inv[16] = t[1]*t[6]*t[11] - t[1]*t[7]*t[10] - t[5]*t[2]*t[11] + t[5]*t[3]*t[10] + t[9]*t[2]*t[7] - t[9]*t[3]*t[6]

    local det = t[1]*inv[1] + t[2]*inv[5] + t[3]*inv[9] + t[4]*inv[13]
    
    if math.abs(det) < EPSILON then
        return nil
    end
    
    for i = 1, 16 do
        inv[i] = inv[i] / det
    end
    
    return mat4.new(inv)
end

--- Extract translation from matrix
--- @param self mat4 Matrix
--- @return table Position (x, y, z)
function mat4:get_translation()
    return { x = self.m[13], y = self.m[14], z = self.m[15] }
end

--- Extract scale from matrix
--- @param self mat4 Matrix
--- @return table Scale (x, y, z)
function mat4:get_scale()
    local sx = math.sqrt(self.m[1]^2 + self.m[2]^2 + self.m[3]^2)
    local sy = math.sqrt(self.m[5]^2 + self.m[6]^2 + self.m[7]^2)
    local sz = math.sqrt(self.m[9]^2 + self.m[10]^2 + self.m[11]^2)
    return { x = sx, y = sy, z = sz }
end

--- Get raw matrix table (for interfacing)
--- @param self mat4 Matrix
--- @return table Raw 16-element table
function mat4:raw()
    return self.m
end

--- Metamethod for matrix multiplication using * operator
function mat4.__mul(a, b)
    if type(a) == "number" then
        error("Cannot multiply scalar * matrix")
    end
    return a:multiply(b)
end

return mat4