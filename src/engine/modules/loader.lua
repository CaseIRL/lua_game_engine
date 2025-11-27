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
--- @description Loads and sandboxes game and mod files, handles mod discovery

--- @section Building

--- Detect if running from bundled exe
local function is_bundled()
    local f = io.open("src/engine/main.lua", "r")
    if f then
        f:close()
        return false
    end
    return true
end

local BUNDLED = is_bundled()

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

local loader = {}

--- Loaded mods cache
loader.loaded = {}

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

--- Scan for immediate subdirectories inside a directory
--- @param directory string Directory path to scan for folders
--- @return table A list of full paths to folders
local function scan_directories(directory)
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

--- Scan a directory for .lua files
--- @param directory string Directory path to scan
--- @return table A list of full paths to .lua files
local function scan_lua_files(directory)
    local files = {}
    local find_data = ffi.new("WIN32_FIND_DATAA")
    local search_path = directory .. "\\*.lua"
    
    local handle = ffi.C.FindFirstFileA(search_path, find_data)
    
    if handle == INVALID_HANDLE_VALUE then
        return files
    end
    
    repeat
        local name = ffi.string(find_data.cFileName)
        if name ~= "." and name ~= ".." and name ~= "" then
            if bit.band(find_data.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY) == 0 then
                local file_path = directory .. "\\" .. name
                table.insert(files, file_path)
            end
        end
    until ffi.C.FindNextFileA(handle, find_data) == 0
    
    ffi.C.FindClose(handle)
    return files
end

--- Load and execute a Lua module with optional sandboxing.
--- @param module_path string Module path using dots, e.g. "game.scenes.test" or "mods.test.mod"
--- @param api table|nil Engine API exposed to sandboxed code. If nil, no sandbox is applied.
--- @return any result The return value of the executed module.
function loader.load_module(module_path, api)
    if package.preload[module_path] then
        return package.preload[module_path]()
    end

    local chunk
    local found = false
    
    -- Try bundled loader first
    for i = 1, #(package.searchers or package.loaders or {}) do
        local searcher = (package.searchers or package.loaders)[i]
        local loader_func = searcher(module_path)
        if type(loader_func) == "function" then
            chunk = loader_func
            found = true
            break
        end
    end
    
    -- Fall back to file loading
    if not found then
        local file_path = module_path:gsub("%.", "/") .. ".lua"
        if package.config:sub(1,1) == '\\' then
            file_path = file_path:gsub("/", "\\")
        end

        local file = io.open(file_path, "r")
        if not file then
            error("Module not found: " .. file_path)
        end

        local code = file:read("*a")
        file:close()

        local err
        chunk, err = loadstring(code)
        if not chunk then
            error("Syntax error in " .. file_path .. ": " .. err)
        end
    end
    
    -- Apply sandbox if api provided
    if api then
        local is_mod = module_path:match("^mods%.") ~= nil
        local env = create_sandbox_env(api, is_mod)
        setfenv(chunk, env)
    end
    
    return chunk()
end

--- Load a single Lua file from a mod folder
--- @param file_path string Full path to the .lua file
--- @param mod_name string The mod folder name
--- @param engine table Engine instance to pass into mod modules
--- @return table|nil Loaded mod table, or nil on failure
local function load_mod_file(file_path, mod_name, engine)
    print("[Mods] Loading: " .. file_path)
    
    local f = io.open(file_path, "r")
    if not f then
        print("[Mods] Error reading file: " .. file_path)
        return nil
    end
    
    local code = f:read("*a")
    f:close()
    
    local chunk, err = loadstring(code, "@" .. file_path)
    if not chunk then
        print("[Mods] Syntax error in " .. file_path .. ": " .. err)
        return nil
    end
    
    local env = create_sandbox_env(engine, true)
    setfenv(chunk, env)
    
    local success, result = pcall(chunk)
    if not success then
        print("[Mods] Error executing mod: " .. tostring(result))
        return nil
    end
    
    if type(result) ~= "table" then
        print("[Mods] Warning: " .. file_path .. " did not return a table, skipping")
        return nil
    end
    
    result._path = file_path
    result._name = result.name or mod_name
    
    if result.init then
        local ok, err = pcall(result.init, engine)
        if not ok then
            print("[Mods] Error initializing " .. result._name .. ": " .. tostring(err))
            return nil
        end
    end
    
    print("[Mods] Loaded: " .. result._name)
    return result
end

--- Initialize the mod system and load all mods from game/mods
--- @param engine table Engine instance passed to mods during loading
function loader.load_mods(engine)
    print("[Mods] Initializing mod system...")
    
    -- Use different path based on whether we're bundled
    local mods_dir = BUNDLED and "mods" or "game\\mods"
    local mod_folders = scan_directories(mods_dir)
    
    if #mod_folders == 0 then
        print("[Mods] No mod folders found in " .. mods_dir)
        return
    end
    
    print("[Mods] Found " .. #mod_folders .. " mod folder(s)")
    
    for _, mod_path in ipairs(mod_folders) do
        local mod_name = mod_path:match("\\([^\\]+)$")
        local lua_files = scan_lua_files(mod_path)
        
        if #lua_files == 0 then
            print("[Mods] Warning: No .lua files in " .. mod_path)
        else
            for _, file_path in ipairs(lua_files) do
                local mod = load_mod_file(file_path, mod_name, engine)
                if mod then
                    table.insert(loader.loaded, mod)
                end
            end
        end
    end
    
    print("[Mods] Successfully loaded " .. #loader.loaded .. " mod(s)")
end

--- Retrieve metadata for all loaded mods
--- @return table List of loaded mods, each containing name, version, author, and path
function loader.list()
    local list = {}
    for _, mod in ipairs(loader.loaded) do
        table.insert(list, {
            name = mod._name,
            version = mod.version,
            author = mod.author,
            path = mod._path
        })
    end
    return list
end

return loader