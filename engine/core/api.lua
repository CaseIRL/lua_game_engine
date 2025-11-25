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

--- @module engine.core.api
--- @description Public API exposed to sandboxed game code

--- @section Engine Modules

local _loader = require("engine.core.loader")
local _config = _loader.load_module("config")

--- @section Module

local api = {}

-- Core modules
api.scene = require("engine.core.scene")
api.window = require("engine.core.window")

-- Optional modules
if _config.modules.draw then
    api.draw = require("engine.modules.draw")
end

if _config.modules.audio then
    api.audio = require("engine.modules.audio")
end

if _config.modules.keyboard then
    api.keyboard = require("engine.modules.keyboard")
end

if _config.modules.mouse then
    api.mouse = require("engine.modules.mouse")
end

if _config.modules.image then
    api.image = require("engine.modules.image")
end

if _config.modules.actions then
    api.actions = require("engine.modules.actions")
end

if _config.modules.collision then
    api.collision = require("engine.modules.collision")
end

if _config.modules.ui then
    api.ui = require("engine.ui.init")
end

if _config.modules.mods then
    api.hooks = require("engine.modules.hooks")
    api.mods = require("engine.modules.mods")
end

if _config.modules.filesystem then
    api.filesystem = require("engine.core.filesystem")
end

return api