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

--- @module engine.scenes.default
--- @description Default fallback scene shown when no scene is found

local default = {}

function default:load()
    print("Default scene loaded")
    self.theme = engine.ui.style.get_theme() 
end

function default:update(dt)
    if engine.keyboard.is_pressed("escape") then
        engine.window.close()
    end
end

function default:draw()
    local width, height = engine.window.get_size()
    local accent = self.theme.accent
    local text_primary = self.theme.text_primary
    local text_secondary = self.theme.text_secondary
    local bg_main = self.theme.bg_main

    local text = "DEFAULT TEST SCENE"
    local subtext = "Add your own scenes in config and files into /game/scenes/"
    local exittext = "Press ESC to exit"

    engine.draw.clear({ colour = bg_main })
    
    local size_main = 40
    engine.draw.text({ text = text, x = (width / 2) - (#text * size_main * 0.35), y = height / 2 - 80, size = size_main, colour = accent })

    local size_sub = 16
    engine.draw.text({ text = subtext, x = (width / 2) - (#subtext * size_sub * 0.26), y = height / 2 - 20, size = size_sub, colour = text_secondary })

    local size_exit = 16
    engine.draw.text({ text = exittext, x = (width / 2) - (#exittext * size_exit * 0.31), y = height / 2 + 30, size = size_exit, colour = text_secondary })
end

function default:unload()
    print("Default scene unloaded")
end

return default