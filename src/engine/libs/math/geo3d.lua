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

--- @module maths.geometry_3d
--- @description Handles all 3D geometry functions.

local m = {}

--- Calculates the distance between two 3D points.
--- @param start_coords table {x=number,y=number,z=number} The starting coordinates.
--- @param end_coords table {x=number,y=number,z=number} The ending coordinates.
--- @return number The Euclidean distance between the two points.
function m.calculate_distance(start_coords, end_coords)
    local dx = end_coords.x - start_coords.x
    local dy = end_coords.y - start_coords.y
    local dz = end_coords.z - start_coords.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- Calculates the distance between two 3D points.
--- @param p1 table The first point (x, y, z).
--- @param p2 table The second point (x, y, z).
--- @return number The Euclidean distance between the two points.
function m.distance_3d(p1, p2)
    return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2 + (p2.z - p1.z)^2)
end

--- Returns the midpoint between two 3D points.
--- @param p1 table The first point (x, y, z).
--- @param p2 table The second point (x, y, z).
--- @return table The midpoint (x, y, z).
function m.midpoint(p1, p2)
    return {x = (p1.x + p2.x) / 2, y = (p1.y + p2.y) / 2, z = (p1.z + p2.z) / 2}
end

--- Determines if a point is inside a given 3D box boundary.
--- @param point table The point to check (x, y, z).
--- @param box table The box (x, y, z, width, height, depth).
--- @return boolean True if the point is inside the box, false otherwise.
function m.is_point_in_box(point, box)
    return point.x >= box.x and point.x <= (box.x + box.width) and point.y >= box.y and point.y <= (box.y + box.height) and point.z >= box.z and point.z <= (box.z + box.depth)
end

--- Calculates the angle between three 3D points (p1, p2 as center, p3).
--- @param p1 table The first point (x, y, z).
--- @param p2 table The center point (x, y, z).
--- @param p3 table The third point (x, y, z).
--- @return number The angle in degrees.
function m.angle_between_3_points(p1, p2, p3)
    local a = m.distance_3d(p2, p3)
    local b = m.distance_3d(p1, p3)
    local c = m.distance_3d(p1, p2)

    return math.acos((a*a + c*c - b*b) / (2*a*c)) * (180 / math.pi)
end

--- Calculates the area of a 3D triangle given three points.
--- @param p1 table The first point of the triangle (x, y, z).
--- @param p2 table The second point of the triangle (x, y, z).
--- @param p3 table The third point of the triangle (x, y, z).
--- @return number The area of the triangle.
function m.triangle_area_3d(p1, p2, p3)
    local u = {x = p2.x - p1.x, y = p2.y - p1.y, z = p2.z - p1.z}
    local v = {x = p3.x - p1.x, y = p3.y - p1.y, z = p3.z - p1.z}
    local cross_product = {x = u.y * v.z - u.z * v.y, y = u.z * v.x - u.x * v.z, z = u.x * v.y - u.y * v.x}
    return 0.5 * math.sqrt(cross_product.x^2 + cross_product.y^2 + cross_product.z^2)
end

--- Determines if a point is inside a 3D sphere defined by center and radius.
--- @param point table The point to check (x, y, z).
--- @param sphere_center table The center of the sphere (x, y, z).
--- @param sphere_radius number The radius of the sphere.
--- @return boolean True if the point is inside the sphere, false otherwise.
function m.is_point_in_sphere(point, sphere_center, sphere_radius)
    return m.distance_3d(point, sphere_center) <= sphere_radius
end

--- Determines if two spheres intersect.
--- @param s1_center table The center of the first sphere (x, y, z).
--- @param s1_radius number The radius of the first sphere.
--- @param s2_center table The center of the second sphere (x, y, z).
--- @param s2_radius number The radius of the second sphere.
--- @return boolean True if the spheres intersect, false otherwise.
function m.do_spheres_intersect(s1_center, s1_radius, s2_center, s2_radius)
    return m.distance_3d(s1_center, s2_center) <= (s1_radius + s2_radius)
end

--- Calculates the distance from a point to a plane.
--- @param point table The point to check (x, y, z).
--- @param plane_point table A point on the plane (x, y, z).
--- @param plane_normal table The normal of the plane (x, y, z). Must be a unit vector (normalized).
--- @return number The distance from the point to the plane.
function m.distance_point_to_plane(point, plane_point, plane_normal)
    local v = { x = point.x - plane_point.x, y = point.y - plane_point.y, z = point.z - plane_point.z }
    local dist = v.x * plane_normal.x + v.y * plane_normal.y + v.z * plane_normal.z

    return math.abs(dist)
end

--- Normalizes a 3D vector.
--- @param v table The vector (x, y, z).
--- @return table The normalized vector (x, y, z).
function m.normalize_vector(v)
    local length = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    if length == 0 then
        return {x = 0, y = 0, z = 0}
    end
    return {x = v.x / length, y = v.y / length, z = v.z / length}
end

return m