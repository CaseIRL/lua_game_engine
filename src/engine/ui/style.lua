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

--- @module engine.ui.style
--- @description Hold static style values for use throughout engine.

local style = {}

style.themes = {}
style.themes.default = {
    -- Fonts *(not added yet will add a font loader at some point)*
    header_font = "Kanit",
    text_font = "Roboto",
    
    -- Border Radius
    border_radius_outer = 4,
    border_radius_inner = 3,
    border_radius_small = 2,
    
    -- Backgrounds
    bg_main = {22, 22, 22, 255},
    bg_panel = {31, 30, 30, 255},
    bg_hover = {50, 48, 48, 255},
    bg_overlay = {0, 0, 0, 127},
    
    -- Text
    text_primary = {255, 255, 255, 255},
    text_secondary = {180, 180, 180, 255},
    text_tertiary = {102, 102, 102, 255},
    
    -- Accents
    accent = {228, 173, 41, 255},
    accent2 = {165, 123, 26, 255}, 
    accent3 = {181, 50, 50, 255},
    accent4 = {102, 102, 102, 255},
    
    -- Borders
    border_dark = {color = {0, 0, 0, 127}, thickness = 2},
    border_light = {color = {255, 255, 255, 25}, thickness = 2},
    border_accent = {color = {228, 173, 41, 255}, thickness = 2},
    border_dashed = {color = {102, 102, 102, 255}, thickness = 1},
    border_transparent = {color = {0, 0, 0, 0}, thickness = 2},
    
    -- Shadows
    shadow_soft = {0, 1, 2, {0, 0, 0, 127}},
    shadow_medium = {0, 2, 4, {0, 0, 0, 153}},
    shadow_large = {0, 4, 8, {0, 0, 0, 191}},
    
    -- Text shadow
    text_shadow_hard = {
        {-1, -1, {0, 0, 0, 255}},
        {1, -1, {0, 0, 0, 255}},
        {-1, 1, {0, 0, 0, 255}},
        {1, 1, {0, 0, 0, 255}},
    },
    
    -- Scrollbars
    scrollbar_track = {255, 255, 255, 64},
    scrollbar_thumb = {255, 255, 255, 204}
}

-- Current active theme (defaults to default theme)
style.current = style.themes.default

--- Set the active theme
--- @param theme_name string The name of the theme to activate
--- @return boolean success Returns true if theme was found and set
function style.set_theme(theme_name)
    if style.themes[theme_name] then
        style.current = style.themes[theme_name]
        return true
    else
        print("Warning: Theme '" .. theme_name .. "' not found, using default")
        style.current = style.themes.default
        return false
    end
end

--- Get the current theme
--- @return table The current active theme
function style.get_theme()
    return style.current
end

--- Get a specific value from the current theme with fallback
--- @param key string The style property to retrieve
--- @return any The value, or nil if not found
function style.get(key)
    return style.current[key] or style.themes.default[key]
end

return style