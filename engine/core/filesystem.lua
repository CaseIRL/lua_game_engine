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

--- @module engine.modules.filesystem
--- @description Simple save/load system for game data. All files are saved to /save/ directory.

--- @section FFI

local ffi = require("ffi")

if ffi.os == "Windows" then
    ffi.cdef[[
        int _mkdir(const char *dirname);
    ]]
elseif ffi.os == "Linux" or ffi.os == "OSX" then
    ffi.cdef[[
        int mkdir(const char *pathname, unsigned int mode);
    ]]
end

--- @section Module

local filesystem = {}

local BASE_DIR = "save/"

--- Validate path is safe (no escaping save/ directory)
--- @param path string Path to validate
--- @return boolean valid, string? error
local function validate_path(path)
    if path:match("%.%.") then
        return false, "Path cannot contain '..' (directory traversal)"
    end
    if path:match("^/") or path:match("^\\") or path:match("^%a:") then
        return false, "Path must be relative to save/ directory"
    end
    return true
end

--- Create a directory (cross-platform)
--- @param path string Directory path
--- @return boolean success
local function create_directory(path)
    if ffi.os == "Windows" then
        return ffi.C._mkdir(path) == 0 or filesystem.exists(path)
    else
        return ffi.C.mkdir(path, tonumber("0755", 8)) == 0 or filesystem.exists(path)
    end
end

--- Check if a file or directory exists
--- @param path string Path relative to save/ directory
--- @return boolean exists
function filesystem.exists(path)
    local valid, err = validate_path(path)
    if not valid then
        print("Error: " .. err)
        return false
    end
    
    local full_path = BASE_DIR .. path
    local file = io.open(full_path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

--- Create a directory inside save/ folder
--- @param path string Directory path relative to save/
--- @return boolean success, string? error
function filesystem.create_directory(path)
    local valid, err = validate_path(path)
    if not valid then
        return false, err
    end

    if not filesystem.exists("") then
        create_directory(BASE_DIR:sub(1, -2))
    end
    
    local full_path = BASE_DIR .. path

    local parts = {}
    for part in path:gmatch("[^/\\]+") do
        table.insert(parts, part)
    end
    
    local current = BASE_DIR
    for _, part in ipairs(parts) do
        current = current .. part
        if not filesystem.exists(current:sub(#BASE_DIR + 1)) then
            local success = create_directory(current)
            if not success then
                return false, "Failed to create directory: " .. current
            end
        end
        current = current .. "/"
    end
    
    print("Created directory: " .. full_path)
    return true
end

--- Serialize a Lua table to a formatted string
--- @param tbl table The table to serialize
--- @param indent string Current indentation level
--- @return string Serialized table
function filesystem.serialize(tbl, indent)
    indent = indent or ""
    local next_indent = indent .. "    "
    local lines = { "{" }

    for k, v in pairs(tbl) do
        local key
        if type(k) == "string" and k:match("^[%a_][%w_]*$") then
            key = k
        elseif type(k) == "string" then
            key = string.format("[%q]", k)
        else
            key = string.format("[%s]", tostring(k))
        end

        if type(v) == "table" then
            table.insert(lines, string.format("%s%s = %s,", next_indent, key, filesystem.serialize(v, next_indent)))
        elseif type(v) == "string" then
            table.insert(lines, string.format("%s%s = %q,", next_indent, key, v))
        elseif type(v) == "number" or type(v) == "boolean" then
            table.insert(lines, string.format("%s%s = %s,", next_indent, key, tostring(v)))
        else
            
        end
    end

    table.insert(lines, indent .. "}")
    return table.concat(lines, "\n")
end

--- Save data to a file in save/ directory
--- @param path string Path relative to save/ (e.g., "player.lua" or "profiles/player1.lua")
--- @param data table Data to save
--- @return boolean success, string? error
function filesystem.save(path, data)
    local valid, err = validate_path(path)
    if not valid then
        return false, err
    end
    
    local full_path = BASE_DIR .. path

    local dir = path:match("(.*/)")
    if dir then
        local ok, dir_err = filesystem.create_directory(dir)
        if not ok then
            return false, dir_err
        end
    else
        filesystem.create_directory("")
    end
    
    local file, open_err = io.open(full_path, "w")
    if not file then
        return false, "Failed to open file: " .. open_err
    end
    
    local serialized = "return " .. filesystem.serialize(data)
    file:write(serialized)
    file:close()
    
    print("Saved to: " .. full_path)
    return true
end

--- Load data from a file in save/ directory
--- @param path string Path relative to save/
--- @return table? data, string? error
function filesystem.load(path)
    local valid, err = validate_path(path)
    if not valid then
        return nil, err
    end
    
    local full_path = BASE_DIR .. path

    local file, open_err = io.open(full_path, "r")
    if not file then
        return nil, "File not found: " .. full_path
    end

    local content = file:read("*a")
    file:close()

    local chunk, load_err = loadstring(content)
    if not chunk then
        return nil, "Failed to parse save file: " .. load_err
    end

    local safe_api = {}

    local env = (function()
        return {
            pairs = pairs,
            ipairs = ipairs,
            tostring = tostring,
            tonumber = tonumber,
            type = type,
            table = table,
            string = string,
            math = math,
        }
    end)()

    setfenv(chunk, env)

    local ok, result = pcall(chunk)
    if not ok then
        return nil, "Failed to load data: " .. result
    end

    print("Loaded from: " .. full_path)
    return result
end


--- Delete a save file
--- @param path string Path relative to save/
--- @return boolean success, string? error
function filesystem.delete(path)
    local valid, err = validate_path(path)
    if not valid then
        return false, err
    end
    
    local full_path = BASE_DIR .. path
    local success = os.remove(full_path)
    
    if success then
        print("Deleted: " .. full_path)
        return true
    else
        return false, "Failed to delete file"
    end
end

return filesystem