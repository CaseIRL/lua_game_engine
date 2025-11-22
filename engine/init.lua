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

--- @module engine.init
--- @description Single entry point for core engine modules.

--- @section Engine Modules

local _loader = require("engine.core.loader")
local _config = _loader.load_module("config")

--- @section Module

local engine = {}

-- Core modules
engine.window = require("engine.core.window")
engine.loader = _loader
engine.scene = require("engine.core.scene")
engine.api = require("engine.core.api")

-- Optional modules
if _config.modules.draw then
    engine.draw = require("engine.modules.draw")
end

if _config.modules.audio then
    engine.audio = require("engine.modules.audio")
end

if _config.modules.keyboard then
    engine.keyboard = require("engine.modules.keyboard")
end

if _config.modules.mouse then
    engine.mouse = require("engine.modules.mouse")
end

return engine

