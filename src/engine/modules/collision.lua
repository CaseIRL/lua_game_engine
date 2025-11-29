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

--- @module engine.modules.collision
--- @description 2D collision detection and spatial queries

local m = {}

--- Calculate distance between two points
--- @param p1 table Point {x, y}
--- @param p2 table Point {x, y}
--- @return number Distance
local function distance_2d(p1, p2)
    return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)
end

--- Check if a point is inside a rectangle
--- @param opts table {point, rect}
--- @return boolean
function m.point_in_rect(opts)
    local point = opts.point
    local rect = opts.rect
    return point.x >= rect.x and point.x <= (rect.x + rect.width) and point.y >= rect.y and point.y <= (rect.y + rect.height)
end

--- Check if a point is inside a circle
--- @param opts table {point, center, radius}
--- @return boolean
function m.point_in_circle(opts)
    local point = opts.point
    local center = opts.center
    local radius = opts.radius
    return distance_2d(point, center) <= radius
end

--- Check if two rectangles overlap (AABB)
--- @param opts table {rect1, rect2}
--- @return boolean
function m.rects_overlap(opts)
    local r1 = opts.rect1
    local r2 = opts.rect2
    return not (r1.x + r1.width < r2.x or r2.x + r2.width < r1.x or r1.y + r1.height < r2.y or r2.y + r2.height < r1.y)
end

--- Check if two circles overlap
--- @param opts table {c1_center, c1_radius, c2_center, c2_radius}
--- @return boolean
function m.circles_overlap(opts)
    local c1_center = opts.c1_center
    local c1_radius = opts.c1_radius
    local c2_center = opts.c2_center
    local c2_radius = opts.c2_radius
    return distance_2d(c1_center, c2_center) <= (c1_radius + c2_radius)
end

--- Get distance between two points
--- @param opts table {p1, p2}
--- @return number
function m.distance_between(opts)
    return distance_2d(opts.p1, opts.p2)
end

return m