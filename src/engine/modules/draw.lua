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

--- @module engine.modules.draw
--- @description High-level drawing helpers wrapping Raylib FFI calls.

--- @section FFI

local ffi = require("ffi")

ffi.cdef[[
    typedef struct { float x, y, width, height; } Rectangle; 
    typedef struct { unsigned char r, g, b, a; } Color;
    typedef struct { float x, y; } Vector2;

    void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color);
    void DrawRectangle(int posX, int posY, int width, int height, Color color);
    void DrawRectangleRec(Rectangle rec, Color color);
    void DrawRectangleLines(int posX, int posY, int width, int height, Color color);

    void DrawRectangleRounded(Rectangle rec, float roundness, int segments, Color color);
    void DrawRectangleRoundedLinesEx(Rectangle rec, float roundness, int segments, float lineThick, Color color);

    void DrawText(const char *text, int posX, int posY, int fontSize, Color color);
    void DrawCircle(int centerX, int centerY, float radius, Color color);
    void DrawCircleLines(int centerX, int centerY, float radius, Color color);
    void DrawTriangle(Vector2 v1, Vector2 v2, Vector2 v3, Color color);
    void DrawTriangleLines(Vector2 v1, Vector2 v2, Vector2 v3, Color color);
    void DrawEllipse(int centerX, int centerY, float radiusH, float radiusV, Color color);
    void DrawPoly(Vector2 center, int sides, float radius, float rotation, Color color);
    void ClearBackground(Color color);
]]

local _rl = ffi.load("raylib")
local new_colour = ffi.typeof("Color")
local new_vec2 = ffi.typeof("Vector2")
local new_rect = ffi.typeof("Rectangle")

--- @section Module

local draw = {}

--- Helper function to convert the style array {R, G, B, A} to a Raylib Color FFI object.
--- @param opts table Drawing options table
--- @return Color Raylib Color FFI object
local function build_colour(opts)
    local colour_array = opts.colour or opts.color
    local r, g, b, a = 255, 255, 255, 255

    if type(colour_array) == "table" and #colour_array >= 4 then
        r, g, b, a = colour_array[1], colour_array[2], colour_array[3], colour_array[4]
    end

    return new_colour(r, g, b, a)
end

--- Draw a filled rectangle.
--- @param opts table `{ x, y, w, h, colour?, roundness?, segments? }`
function draw.rect(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    local rec = new_rect(opts.x, opts.y, opts.w, opts.h)

    if opts.roundness ~= nil then
        local roundness = opts.roundness
        local segments = opts.segments or 0
        _rl.DrawRectangleRounded(rec, roundness, segments, colour)
    else
        _rl.DrawRectangleRec(rec, colour)
    end
end

--- Draw a rectangle outline (or rounded outline if 'roundness' is provided).
--- @param opts table `{ x, y, w, h, colour?, roundness?, segments?, line_thick? }`
function draw.rect_lines(opts)
    opts = opts or {}
    local colour = build_colour(opts)

    if opts.roundness ~= nil then
        local rec = new_rect(opts.x, opts.y, opts.w, opts.h)
        local roundness = opts.roundness
        local segments = opts.segments or 0
        local line_thick = opts.line_thick or 1.0
        _rl.DrawRectangleRoundedLinesEx(rec, roundness, segments, line_thick, colour)
    else
        _rl.DrawRectangleLines(opts.x, opts.y, opts.w, opts.h, colour)
    end
end

--- Draw text on the screen.
--- @param opts table `{ text, x, y, size?, colour? }`
function draw.text(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    _rl.DrawText(opts.text, opts.x, opts.y, opts.size or 16, colour)
end

--- Draw a line between two points.
--- @param opts table `{ x1, y1, x2, y2, colour? }`
function draw.line(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    _rl.DrawLine(opts.x1, opts.y1, opts.x2, opts.y2, colour)
end

--- Draw a filled circle.
--- @param opts table `{ x, y, radius?, colour? }`
function draw.circle(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    _rl.DrawCircle(opts.x, opts.y, opts.radius or 10, colour)
end

--- Draw a circle outline.
--- @param opts table `{ x, y, radius?, colour? }`
function draw.circle_lines(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    _rl.DrawCircleLines(opts.x, opts.y, opts.radius or 10, colour)
end

--- Draw a filled triangle.
--- @param opts table `{ x1, y1, x2, y2, x3, y3, colour? }`
function draw.triangle(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    local v1 = new_vec2(opts.x1 or 0, opts.y1 or 0)
    local v2 = new_vec2(opts.x2 or 0, opts.y2 or 0)
    local v3 = new_vec2(opts.x3 or 0, opts.y3 or 0)
    _rl.DrawTriangle(v1, v2, v3, colour)
end

--- Draw a triangle outline.
--- @param opts table `{ x1, y1, x2, y2, x3, y3, colour? }`
function draw.triangle_lines(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    local v1 = new_vec2(opts.x1 or 0, opts.y1 or 0)
    local v2 = new_vec2(opts.x2 or 0, opts.y2 or 0)
    local v3 = new_vec2(opts.x3 or 0, opts.y3 or 0)
    _rl.DrawTriangleLines(v1, v2, v3, colour)
end

--- Draw an ellipse.
--- @param opts table `{ x, y, rx?, ry?, colour? }`
function draw.ellipse(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    _rl.DrawEllipse(opts.x or 0, opts.y or 0, opts.rx or 20, opts.ry or 20, colour)
end

--- Draw a regular polygon.
--- @param opts table `{ x, y, sides?, radius?, rotation?, colour? }`
function draw.polygon(opts)
    opts = opts or {}
    local colour = build_colour(opts)
    local center = new_vec2(opts.x or 0, opts.y or 0)
    _rl.DrawPoly(center, opts.sides or 6, opts.radius or 20, opts.rotation or 0, colour)
end

--- Clear the background to a colour.
--- @param opts table `{ colour? }`
function draw.clear(opts)
    opts = opts or {}
    local colour_array = opts.colour or opts.color
    local r, g, b, a = 10, 10, 20, 255

    if type(colour_array) == "table" and #colour_array >= 4 then
        r, g, b, a = colour_array[1], colour_array[2], colour_array[3], colour_array[4]
    end
    local colour = new_colour(r, g, b, a)
    _rl.ClearBackground(colour)
end

return draw