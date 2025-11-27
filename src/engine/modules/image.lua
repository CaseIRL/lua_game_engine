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

--- @module engine.modules.image
--- @description Handles loading, drawing and updating images and sprites.

--- @section FFI

local ffi = require("ffi")

ffi.cdef[[
    typedef struct { unsigned char r, g, b, a; } Color;
    typedef struct { float x, y; } Vector2;
    typedef struct { float x, y, width, height; } Rectangle;
    typedef struct {
        unsigned int id;
        int width;
        int height;
        int mipmaps;
        int format;
    } Texture2D;

    Texture2D LoadTexture(const char *fileName);
    void UnloadTexture(Texture2D texture);
    void DrawTextureEx(Texture2D texture, Vector2 position, float rotation, float scale, Color tint);
    void DrawTextureRec(Texture2D texture, Rectangle source, Vector2 position, Color tint);
]]

local _rl = ffi.load("raylib")
local new_color = ffi.typeof("Color")
local new_vec2 = ffi.typeof("Vector2")
local new_rect = ffi.typeof("Rectangle")

--- @section Module

local image = {
    images = {},
    sprites = {}
}

--- @section Helpers

local function build_animation_frames(anim_def, frame_width, frame_height)
    local frames = {}
    for frame_idx = 1, anim_def.frames do
        frames[frame_idx] = {
            x = (anim_def.x + frame_idx - 1) * frame_width,
            y = anim_def.y * frame_height
        }
    end
    return frames
end

local function build_all_animations(animations, frame_width, frame_height)
    local all_frames = {}
    for anim_name, anim_def in pairs(animations) do
        all_frames[anim_name] = build_animation_frames(anim_def, frame_width, frame_height)
    end
    return all_frames
end

local function make_color(r, g, b, a)
    return new_color(r or 255, g or 255, b or 255, a or 255)
end

--- @section API

--- Load image or sprite
--- @param opts table `{ type, key, path, frame_width?, frame_height?, animations? }`
function image.load(opts)
    opts = opts or {}
    
    if image.images[opts.key] then
        return
    end
    
    local texture = _rl.LoadTexture(opts.path)
    image.images[opts.key] = texture
    
    if opts.type ~= "sprite" then
        return
    end
    
    local frames = opts.animations and build_all_animations(opts.animations, opts.frame_width, opts.frame_height) or {}
    
    image.sprites[opts.key] = { frame_width = opts.frame_width, frame_height = opts.frame_height, frames = frames }
end

--- Draw image at position
--- @param opts table `{ key, x, y, scale?, tint? }`
function image.draw(opts)
    opts = opts or {}
    if not image.images[opts.key] then
        return
    end
    
    local scale = opts.scale or 1.0
    local color = make_color(opts.tint and opts.tint.r, opts.tint and opts.tint.g, opts.tint and opts.tint.b, opts.tint and opts.tint.a)
    
    _rl.DrawTextureEx(image.images[opts.key], new_vec2(opts.x, opts.y), 0, scale, color)
end

--- Draw sprite frame from spritesheet
--- @param opts table `{ key, x, y, frame_width, frame_height, frame_x, frame_y, scale? }`
function image.draw_frame(opts)
    opts = opts or {}
    if not image.images[opts.key] then
        return
    end
    
    local frame_x = (opts.frame_x ~= nil) and opts.frame_x or 0
    local frame_y = (opts.frame_y ~= nil) and opts.frame_y or 0
    local scale = opts.scale or 1.0
    local source = new_rect(frame_x, frame_y, opts.frame_width, opts.frame_height)
    local pos = new_vec2(opts.x, opts.y)
    local white = make_color()
    
    _rl.DrawTextureRec(image.images[opts.key], source, pos, white)
end

--- Draw sprite with animation metadata
--- @param opts table `{ key, anim, frame, x, y, scale? }`
function image.draw_sprite(opts)
    opts = opts or {}
    
    local sprite = image.sprites[opts.key]
    if not sprite or not image.images[opts.key] then
        return
    end
    
    local anim_frames = sprite.frames[opts.anim]
    if not anim_frames or not anim_frames[opts.frame] then
        return
    end
    
    local frame_data = anim_frames[opts.frame]
    
    image.draw_frame({
        key = opts.key,
        x = opts.x,
        y = opts.y,
        frame_width = sprite.frame_width,
        frame_height = sprite.frame_height,
        frame_x = frame_data.x,
        frame_y = frame_data.y,
        scale = opts.scale or 1.0
    })
end

--- Unload and free image
--- @param key string Image identifier
function image.unload(key)
    if not image.images[key] then
        return
    end
    
    _rl.UnloadTexture(image.images[key])
    image.images[key] = nil
    image.sprites[key] = nil
end

--- Clean up all images
function image.cleanup()
    for key in pairs(image.images) do
        image.unload(key)
    end
end

return image