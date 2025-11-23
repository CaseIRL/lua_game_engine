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

--- @script build
--- @description Handles files ready for luastatic building.

local output_name = arg[1] or "game"

local luastatic_path = os.getenv("LUASTATIC_PATH")
local lua_lib = os.getenv("LUA_LIB")
local lua_include = os.getenv("LUA_INCLUDE")

if not luastatic_path or not lua_lib or not lua_include then
    print("[ERROR] Environment variables not set!")
    print("Set these before running:")
    print("  set LUASTATIC_PATH=C:\\path\\to\\luastatic.bat")
    print("  set LUA_LIB=C:\\path\\to\\lua51.lib")
    print("  set LUA_INCLUDE=C:\\path\\to\\luajit\\src")
    os.exit(1)
end

print("[BUILD] Scanning for Lua files...")

local files = {"main.lua", "config.lua"}
local function scan_directory(dir)
    local handle = io.popen('dir /b /s "' .. dir .. '\\*.lua"')
    if handle then
        for file in handle:lines() do
            table.insert(files, file)
        end
        handle:close()
    end
end

scan_directory("engine")
scan_directory("game")

print("[BUILD] Found " .. #files .. " Lua files")

local cmd = luastatic_path .. " " .. table.concat(files, " ") .. " -o " .. output_name .. ".luastatic.c"
print("[BUILD] Running luastatic...")

local result = os.execute(cmd)
if result ~= 0 then
    os.exit(1)
end

print("[BUILD] C file generated: " .. output_name .. ".luastatic.c")