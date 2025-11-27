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

--- @class engine.ui.button
--- @description Reusable button class.

local _style = require("src.engine.ui.style")
local _draw = require("src.engine.modules.draw")

local button = {}
button.__index = button

--- Create a new button
--- @param opts table `{ x, y, w, h, text, on_click?, roundness?, segments? }`
--- @return table Button instance
function button.new(opts)
    local self = setmetatable({}, button)

    self.x = opts.x or 0
    self.y = opts.y or 0
    self.w = opts.w or 100
    self.h = opts.h or 40
    self.text = opts.text or ""
    self.on_click = opts.on_click or nil

    self.roundness = opts.roundness
    self.segments = opts.segments

    self.hovered = false
    self.active = false
    self.was_active = false
    self.enabled = true

    return self
end

--- Check if mouse is over button
--- @param mouse_x number Mouse x position
--- @param mouse_y number Mouse y position
--- @return boolean
function button:is_hovered(mouse_x, mouse_y)
    return mouse_x >= self.x and mouse_x <= self.x + self.w and mouse_y >= self.y and mouse_y <= self.y + self.h
end

--- Update button state
--- @param mouse_x number Mouse x position
--- @param mouse_y number Mouse y position
--- @param mouse_pressed boolean
function button:update(mouse_x, mouse_y, mouse_pressed)
    self.was_active = self.active
    
    if not self.enabled then
        self.hovered = false
        self.active = false
        return
    end
    
    self.hovered = self:is_hovered(mouse_x, mouse_y)
    
    if self.hovered and mouse_pressed then
        self.active = true

        if self.on_click and not self.was_active then
            self.on_click()
        end
    else
        self.active = false
    end
end

--- Draw the button
function button:draw()
    local bg_colour
    if not self.enabled then
        bg_colour = _style.get("bg_panel")
    elseif self.active then
        bg_colour = _style.get("accent2")
    elseif self.hovered then
        bg_colour = _style.get("bg_hover")
    else
        bg_colour = _style.get("bg_panel")
    end

    _draw.rect({ x = self.x, y = self.y, w = self.w, h = self.h, colour = bg_colour, roundness = self.roundness, segments = self.segments })

    local border = _style.get("border_accent")
    _draw.rect_lines({ x = self.x, y = self.y, w = self.w, h = self.h, colour = border.colour, roundness = self.roundness, segments = self.segments,line_thick = 1})

    if self.text then
        local text_colour = self.enabled and _style.get("text_primary") or _style.get("text_tertiary")
        local font_size = 16

        local text_x = self.x + (self.w / 2) - (#self.text * font_size / 4)
        local text_y = self.y + (self.h / 2) - (font_size / 2)

        _draw.text({ text = self.text, x = text_x, y = text_y, size = font_size, colour = text_colour })
    end
end

return button