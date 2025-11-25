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

--- @module engine.core.loader
--- @description Loads and sandboxes game and mod files, providing an isolated environment for scripts.

--- @section Module

local loader = {}

--- Create a sandboxed environment containing the engine API and safe Lua functions.
--- @param api table The engine API table exposed inside the sandbox.
--- @param is_mod boolean Whether this is a mod (changes print prefix)
--- @return table env A sandbox environment table.
local function create_sandbox_env(api, is_mod)
    local prefix = is_mod and "[MOD]" or "[GAME]"
    
    local env = {
        engine = api,

        -- Safe standard libs
        math = math,
        string = string,
        table = table,
        ipairs = ipairs,
        pairs = pairs,
        tostring = tostring,
        tonumber = tonumber,
        type = type,
        pcall = pcall,
        xpcall = xpcall,

        print = function(msg)
            print(prefix .. " " .. tostring(msg))
        end,
    }

    function env.require(path)
        if path:match("^game%.") or path:match("^mods%.") then
            return loader.load_module(path, api)
        else
            local full_path = "game." .. path
            return loader.load_module(full_path, api)
        end
    end

    return env
end

--- Load and execute a Lua module with optional sandboxing.
--- @param module_path string Module path using dots, e.g. "game.scenes.test" or "mods.test.mod"
--- @param api table|nil Engine API exposed to sandboxed code. If nil, no sandbox is applied.
--- @return any result The return value of the executed module.
function loader.load_module(module_path, api)
    -- Convert dots to path separators (works on both Windows and Unix)
    local file_path = module_path:gsub("%.", "/") .. ".lua"
    
    -- On Windows, convert forward slashes to backslashes
    if package.config:sub(1,1) == '\\' then
        file_path = file_path:gsub("/", "\\")
    end

    local file = io.open(file_path, "r")
    if not file then
        error("Module not found: " .. file_path)
    end

    local code = file:read("*a")
    file:close()

    local chunk, err = loadstring(code)
    if not chunk then
        error("Syntax error in " .. file_path .. ": " .. err)
    end

    local env
    if api then
        local is_mod = module_path:match("^mods%.") ~= nil
        env = create_sandbox_env(api, is_mod)
    else
        env = {
            require = require,
            pairs = pairs,
            ipairs = ipairs,
            table = table,
        }
    end

    setfenv(chunk, env)
    return chunk()
end

return loader