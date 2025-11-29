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

--- @module runtime.init
--- @description Single access loader for all runtime modules.

local runtime = {}

runtime.callbacks = require("src.engine.core.runtime.callbacks")
runtime.cooldowns = require("src.engine.core.runtime.cooldowns")
runtime.rng = require("src.engine.core.runtime.rng")
runtime.state = require("src.engine.core.runtime.state")
runtime.timers = require("src.engine.core.runtime.timers")

local promotions = {}
for _, submod in pairs(runtime) do
    if type(submod) == "table" then
        for k, v in pairs(submod) do
            promotions[k] = v
        end
    end
end

for k, v in pairs(promotions) do
    runtime[k] = v
end

return runtime