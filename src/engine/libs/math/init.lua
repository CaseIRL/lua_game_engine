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

--- @module libs.math.init
--- @description Single entry point for all math modules

local math = {}

math.core = require("src.engine.libs.math.core")
math.easing = require("src.engine.libs.math.easing")
math.geo2d = require("src.engine.libs.math.geo2d")
math.geo3d = require("src.engine.libs.math.geo3d")
math.mat4 = require("src.engine.libs.math.mat4")
math.probability = require("src.engine.libs.math.probability")
math.statistics = require("src.engine.libs.math.statistics")
math.vec3 = require("src.engine.libs.math.vec3")

local promotions = {}
for _, submod in pairs(math) do
    if type(submod) == "table" then
        for k, v in pairs(submod) do
            promotions[k] = v
        end
    end
end

for k, v in pairs(promotions) do
    math[k] = v
end

return math