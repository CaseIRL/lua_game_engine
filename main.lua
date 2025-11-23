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

--- @script main
--- @description Main engine entry point; `luajit.exe main.lua scene?` to launch engine, will use default scene if none declared / exist.

--- @section Command Line Args

local scene_type = arg[1] or "test"

--- @section Engine

local _engine = require("engine.init")
local _api = _engine.api or false

--- @section Sandbox

local _config = _engine.loader.load_module("config")

_engine.window.init(_config)

local sandboxed_scenes = {}
for name, path in pairs(_config.scenes) do
    sandboxed_scenes[name] = _engine.loader.load_module("game." .. path, _api)
end

--- @section Scenes

local scene = sandboxed_scenes[scene_type] or _engine.loader.load_module("engine.scenes.default", _api)

_engine.scene.set_scenes(sandboxed_scenes)
_engine.scene.load(scene)

--- @section Main loop

while not _engine.window.should_close() do
    local dt = _engine.window.get_dt()

    _engine.window.begin_draw()

    if _config.fps.draw then
        _engine.window.draw_fps(10, 10)
    end

    _engine.scene.update(dt)
    _engine.scene.draw()

    _engine.window.end_draw()
end

if _engine.scene.current and _engine.scene.current.unload then
    _engine.scene.current:unload()
end

_engine.window.close()