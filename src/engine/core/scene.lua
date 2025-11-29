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

--- @module engine.modules.scene
--- @description Handles scene management.

--- @section Module

local m = {
    current = false,
    scenes = {}
}

--- Load a new scene, unloading the current one if necessary.
--- @param new_scene table Scene object with optional load/unload/update/draw methods.
function m.load(new_scene)
    if m.current and m.current.unload then
        m.current:unload()
    end
    
    m.current = new_scene
    if m.current.load then
        m.current:load()
    end
end

--- Set the available scenes table.
--- @param scenes_table table Keyed table of scene objects.
function m.set_scenes(scenes_table)
    m.scenes = scenes_table
end

--- Switch to a different scene by name
--- @param name string Scene name
--- @param data table? Optional data to pass to the new scene
function m.switch(name, data)
    local next_scene = m.scenes[name]
    
    if not next_scene then
        error("Scene '" .. name .. "' not found")
    end

    if m.current and m.current.unload then
        m.current:unload()
    end

    m.current = next_scene

    if data then
        m.current._scene_data = data
    end
    
    if m.current.load then
        m.current:load()
    end
end

--- Update the current scene
--- @param dt number Delta time since last frame.
function m.update(dt)
    if m.current and m.current.update then
        m.current:update(dt)
    end
end

--- Draw the current scene
function m.draw()
    if m.current and m.current.draw then
        m.current:draw()
    end
end

return m