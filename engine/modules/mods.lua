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

--- @module engine.modules.mods
--- @description Handles mod loading and management

--- @section Engine Modules

local _loader = require("engine.core.loader")

--- @section FFI

local ffi = require("ffi")

-- FFI definitions for Windows directory scanning
ffi.cdef[[
    typedef struct _WIN32_FIND_DATAA {
        uint32_t dwFileAttributes;
        struct {
            uint32_t dwLowDateTime;
            uint32_t dwHighDateTime;
        } ftCreationTime;
        struct {
            uint32_t dwLowDateTime;
            uint32_t dwHighDateTime;
        } ftLastAccessTime;
        struct {
            uint32_t dwLowDateTime;
            uint32_t dwHighDateTime;
        } ftLastWriteTime;
        uint32_t nFileSizeHigh;
        uint32_t nFileSizeLow;
        uint32_t dwReserved0;
        uint32_t dwReserved1;
        char cFileName[260];
        char cAlternateFileName[14];
    } WIN32_FIND_DATAA;
    
    void* FindFirstFileA(const char* lpFileName, WIN32_FIND_DATAA* lpFindFileData);
    int FindNextFileA(void* hFindFile, WIN32_FIND_DATAA* lpFindFileData);
    int FindClose(void* hFindFile);
]]

--- @section Constants

local INVALID_HANDLE_VALUE = ffi.cast("void*", -1)
local FILE_ATTRIBUTE_DIRECTORY = 0x10

--- @section Module

local mods = {}
mods.loaded = {}

--- Scan for immediate subdirectories inside the mod directory
--- @param directory string Directory path to scan for mod folders
--- @return table A list of full paths to folders containing mods
local function scan_for_mods(directory)
    local folders = {}
    local find_data = ffi.new("WIN32_FIND_DATAA")
    local search_path = directory .. "\\*"
    
    local handle = ffi.C.FindFirstFileA(search_path, find_data)
    
    if handle == INVALID_HANDLE_VALUE then
        return folders
    end
    
    repeat
        local name = ffi.string(find_data.cFileName)
        if name ~= "." and name ~= ".." and name ~= "" then
            if bit.band(find_data.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY) ~= 0 then
                local folder_path = directory .. "\\" .. name
                table.insert(folders, folder_path)
            end
        end
    until ffi.C.FindNextFileA(handle, find_data) == 0
    
    ffi.C.FindClose(handle)
    return folders
end

--- Load a single mod from a folder using the engine loader
--- @param mod_path string Full path to the mod directory
--- @param engine table Engine instance to pass into mod modules
--- @return table|nil Loaded mod table, or nil on failure
local function load_mod(mod_path, engine)
    local mod_file = mod_path .. "\\mod.lua"
    
    local f = io.open(mod_file, "r")
    if not f then
        print("[Mods] Warning: No mod.lua found in " .. mod_path)
        return nil
    end
    f:close()
    
    print("[Mods] Loading mod from: " .. mod_path)
    
    local success, mod = pcall(function()
        local module_path = mod_path:gsub("\\", ".") .. ".mod"
        return _loader.load_module(module_path, engine)
    end)
    
    if not success then
        print("[Mods] Error loading mod: " .. tostring(mod))
        return nil
    end
    
    if type(mod) ~= "table" then
        print("[Mods] Error: mod.lua must return a table")
        return nil
    end
    
    mod._path = mod_path
    mod._name = mod.name or "Unnamed Mod"
    
    if mod.init then
        local ok, err = pcall(mod.init, engine)
        if not ok then
            print("[Mods] Error initializing: " .. tostring(err))
            return nil
        end
    end
    
    print("[Mods] Loaded: " .. mod._name)
    return mod
end

--- Initialize the mod system and load all mods inside the given directory
--- @param engine table Engine instance passed to mods during loading
--- @param mod_directory string|nil Directory to load mods from (defaults to `"mods"`)
function mods.init(engine, mod_directory)
    mod_directory = mod_directory or "mods"
    
    print("[Mods] Initializing mod system...")
    
    local mod_folders = scan_for_mods(mod_directory)
    
    if #mod_folders == 0 then
        print("[Mods] No mods found")
        return
    end
    
    print("[Mods] Found " .. #mod_folders .. " mod folder(s)")
    
    for _, mod_path in ipairs(mod_folders) do
        local mod = load_mod(mod_path, engine)
        if mod then
            table.insert(mods.loaded, mod)
        end
    end
    
    print("[Mods] Successfully loaded " .. #mods.loaded .. " mod(s)")
end

--- Retrieve metadata for all loaded mods
--- @return table List of loaded mods, each containing name, version, author, and path
function mods.list()
    local list = {}
    for _, mod in ipairs(mods.loaded) do
        table.insert(list, {
            name = mod._name,
            version = mod.version,
            author = mod.author,
            path = mod._path
        })
    end
    return list
end

return mods