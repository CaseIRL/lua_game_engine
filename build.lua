--- @script build.lua
--- @description luastatic style bundler for windows
--- Bundles all Lua files as hex-encoded byte arrays, then compiles with MSVC

--- @section Command Line

local output_name = arg[1] or "game"

--- @section Config

--- Load the game's configuration file
--- @return table config Parsed configuration table
local function load_config()
    local f = io.open("game/config.lua", "r")
    if not f then
        print("[BUILD] Warning: Could not read game/config.lua, defaulting to console=false")
        return { window = { console = false } }
    end
    local content = f:read("*a")
    f:close()
    
    local chunk = loadstring(content)
    if not chunk then
        print("[BUILD] Warning: Could not parse game/config.lua, defaulting to console=false")
        return { window = { console = false } }
    end
    
    local conf = chunk()
    return conf
end

local config = load_config()
local show_console = config.window and config.window.console or false

print("[BUILD] Console mode: " .. (show_console and "ENABLED" or "DISABLED"))

--- @section Env Vars

local lua_include = os.getenv("LUA_INCLUDE") or "C:\\luajit\\src"
local lua_lib = os.getenv("LUA_LIB") or "C:\\luajit\\src\\lua51.lib"
local cl_exe = "C:\\Program Files\\Microsoft Visual Studio\\18\\Community\\VC\\Tools\\MSVC\\14.44.35207\\bin\\Hostx64\\x64\\cl.exe"

if not lua_lib or not lua_include then
    print("[ERROR] Set LUA_LIB and LUA_INCLUDE environment variables!")
    os.exit(1)
end

--- @section Helpers

--- Recursively scan a directory for .lua files and generate module names
--- @param dir string Root directory to scan
--- @param prefix string Module prefix to prepend (e.g. "src.")
--- @return table files List of tables { path = string, module = string }
local function find_lua_files(dir, prefix)
    local all_files = {}
    
    --- Internal helper to recursively walk directories
    --- @param path string Current filesystem path
    --- @param mod_prefix string Current module name prefix
    local function recurse(path, mod_prefix)
        local cmd = 'dir "' .. path .. '" /b 2>nul'
        local popen = io.popen(cmd)
        if not popen then return end
        
        for line in popen:lines() do
            line = line:match("^%s*(.-)%s*$")
            if line ~= "" and line ~= "." and line ~= ".." then
                local full_path = path .. "\\" .. line
                
                if line:match("%.lua$") then
                    local filename = line:gsub("%.lua$", "")
                    local module_name
                    
                    if filename == "init" then
                        module_name = mod_prefix .. "init"
                    else
                        module_name = mod_prefix .. filename
                    end
                    
                    if module_name ~= "" then
                        table.insert(all_files, { path = full_path, module = module_name:gsub("\\", "/") })
                    end
                else
                    recurse(full_path, mod_prefix .. line .. ".")
                end
            end
        end
        popen:close()
    end
    
    recurse(dir, prefix)
    return all_files
end

--- Read a file as binary and return its full contents
--- @param path string File path
--- @return string|nil data File contents or nil if unreadable
local function read_file(path)
    local f = io.open(path, "rb")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

--- Convert raw file bytes into a comma-separated list of C hex literals
--- @param data string Raw file content
--- @return string hex_array A string like "0x12, 0xAF, ..."
local function to_hex_array(data)
    local result = {}
    for i = 1, #data do
        table.insert(result, string.format("0x%02x", string.byte(data, i)))
    end
    return table.concat(result, ", ")
end

--- @section Get Files

print("[BUILD] Scanning for Lua files...")
local lua_files = {}

for _, scan_dir in ipairs({"src", "game"}) do
    local found = find_lua_files(scan_dir, scan_dir .. ".")
    for _, file in ipairs(found) do
        table.insert(lua_files, file)
    end
end

if #lua_files == 0 then
    print("[ERROR] No Lua files found in src/ or game/")
    os.exit(1)
end

print("[BUILD] Found " .. #lua_files .. " Lua files")

--- @section Bundler

local bundle_c = [[
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

]]

for idx, file_info in ipairs(lua_files) do
    local content = read_file(file_info.path)
    if not content then
        print("[ERROR] Could not read " .. file_info.path)
        os.exit(1)
    end
    
    local var_name = "lua_module_" .. idx
    local hex_data = to_hex_array(content)
    
    bundle_c = bundle_c .. string.format("static const unsigned char %s[] = {%s};\n", var_name, hex_data)
end

bundle_c = bundle_c .. [[

typedef struct {
    const char *name;
    const unsigned char *data;
    size_t size;
} lua_module_t;

static const lua_module_t lua_modules[] = {
]]

for idx, file_info in ipairs(lua_files) do
    local var_name = "lua_module_" .. idx
    bundle_c = bundle_c .. string.format('    {"%s", %s, sizeof(%s)},\n', file_info.module, var_name, var_name)
end

bundle_c = bundle_c .. [[
    {NULL, NULL, 0}
};

static int lua_bundled_loader(lua_State *L) {
    const char *module_name = luaL_checkstring(L, 1);
    
    for (int i = 0; lua_modules[i].name != NULL; i++) {
        if (strcmp(lua_modules[i].name, module_name) == 0) {
            int status = luaL_loadbuffer(L, (const char *)lua_modules[i].data, lua_modules[i].size, module_name);
            if (status != 0) {
                return lua_error(L);
            }
            return 1;
        }
    }
    return 0;
}

static void install_bundled_loader(lua_State *L) {
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "searchers");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_getfield(L, -1, "loaders");
    }
    
    lua_pushcfunction(L, lua_bundled_loader);
    lua_rawseti(L, -2, 2);
    
    lua_pop(L, 2);
}

int main(int argc, char *argv[]) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    install_bundled_loader(L);
    
    /* Create arg table */
    lua_newtable(L);
    for (int i = 0; i < argc; i++) {
        lua_pushstring(L, argv[i]);
        lua_rawseti(L, -2, i);
    }
    lua_setglobal(L, "arg");

    const char *entry_points[] = {"src.engine.main", "engine.main", NULL};
    
    for (int e = 0; entry_points[e] != NULL; e++) {
        for (int i = 0; lua_modules[i].name != NULL; i++) {
            if (strcmp(lua_modules[i].name, entry_points[e]) == 0) {
                int status = luaL_loadbuffer(L, (const char *)lua_modules[i].data, 
                                            lua_modules[i].size, entry_points[e]);
                if (status != 0) {
                    fprintf(stderr, "Load error: %s\n", lua_tostring(L, -1));
                    lua_close(L);
                    return 1;
                }
                
                status = lua_pcall(L, 0, 0, 0);
                
                if (status != 0) {
                    fprintf(stderr, "Runtime error: %s\n", lua_tostring(L, -1));
                    lua_close(L);
                    return 1;
                }
                lua_close(L);
                return 0;
            }
        }
    }
    
    fprintf(stderr, "Error: entry point not found\n");
    lua_close(L);
    return 1;
}
]]

local c_file = output_name .. ".c"
local f = io.open(c_file, "w")
f:write(bundle_c)
f:close()
print("[BUILD] Generated " .. c_file)

local build_folder = "build\\" .. output_name
os.execute('mkdir "' .. build_folder .. '" 2>nul')

local subsystem_flag = show_console and "" or "/link /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup"

local cl_cmd = string.format('cmd /c "\"%s\" \"%s\" /I\"%s\" \"%s\" /Fe\"%s\\%s.exe\" /nologo %s"', cl_exe, c_file, lua_include, lua_lib, build_folder, output_name, subsystem_flag)

print("[BUILD] Compiling with MSVC...")
if os.execute(cl_cmd) ~= 0 then
    print("[ERROR] Compilation failed")
    os.exit(1)
end

print("[BUILD] SUCCESS! Executable created at:")
print("   " .. build_folder .. "\\" .. output_name .. ".exe")

os.execute('copy "src\\bin\\lua51.dll" "' .. build_folder .. '" /Y >nul 2>&1')
os.execute('copy "src\\bin\\raylib.dll" "' .. build_folder .. '" /Y >nul 2>&1')

print("[BUILD] Cleaning up temporary files...")
os.remove(c_file)
os.remove(output_name .. ".obj")

print("[BUILD] Build complete!")