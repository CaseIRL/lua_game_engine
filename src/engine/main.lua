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

--- @section Engine Modules

local _loader = require("src.engine.modules.loader")
local _conf = _loader.load_module("game.config")

local engine = {
    loader = _loader,
    window = require("src.engine.modules.window"),
    scene = require("src.engine.modules.scene"),
    filesystem = require("src.engine.modules.filesystem"),
    ui = require("src.engine.ui.init"),
}

local optional_modules = {
    draw = "src.engine.modules.draw",
    audio = "src.engine.modules.audio",
    keyboard = "src.engine.modules.keyboard",
    mouse = "src.engine.modules.mouse",
    image = "src.engine.modules.image",
    actions = "src.engine.modules.actions",
    collision = "src.engine.modules.collision",
    network = "src.engine.modules.network",
}

--- Load any active optional modules
for name, path in pairs(optional_modules) do
    if _conf.modules[name] then
        engine[name] = require(path)
    end
end

--- Loads mods if enabled
if _conf.modules.mods then
    engine.hooks = require("src.engine.modules.hooks")
    _loader.load_mods(engine)
end

--- @section Sandbox

--- Load all scenes; _loader sandboxes them with engine as the API
local sandboxed_scenes = {}
for name, path in pairs(_conf.scenes) do
    sandboxed_scenes[name] = _loader.load_module("game." .. path, engine)
end

--- @section Scenes

local scene_name = arg[1] or _conf.default_scene or "test"
local initial_scene = sandboxed_scenes[scene_name] or _loader.load_module("src.engine.scenes.default", engine)

engine.scene.set_scenes(sandboxed_scenes)
engine.scene.load(initial_scene)

--- @section Main Code

--- Init the window
engine.window.init(_conf)

--- Main loop; handles basically everything
while not engine.window.should_close() do
    local dt = engine.window.get_dt()

    engine.window.begin_draw()

    if _conf.fps and _conf.fps.draw then
        engine.window.draw_fps(10, 10)
    end

    if _conf.modules.actions and engine.actions then
        engine.actions.update()
    end

    engine.scene.update(dt)
    engine.scene.draw()

    engine.window.end_draw()
end

--- Handle scene unloading
if engine.scene.current and engine.scene.current.unload then
    engine.scene.current:unload()
end

--- Handle window closing
engine.window.close()