# Building .exe Games

Package your game into a standalone executable with embedded Lua code.
Your game logic stays private, players get a runnable `.exe`.

## Prerequisites

- **Lua5.1** installed and added to your systems paths
- **LuaJIT** installed (with `lua51.lib`)
- **MSVC Compiler** (Visual Studio or Build Tools)
- Both accessible from command line

## Setup (One-time)

### Step 1: Set environment variables

Run once in your command prompt (or add to system environment variables):

```cmd
set LUA_LIB=C:\luajit\src\lua51.lib
set LUA_INCLUDE=C:\luajit\src
```

> Replace paths if your LuaJIT is installed elsewhere.

### Step 2: Update build.lua paths

Open `build.lua` and update the MSVC compiler path if needed:

```lua
local cl_exe = "C:\\Program Files\\Microsoft Visual Studio\\18\\Community\\VC\\Tools\\MSVC\\14.44.35207\\bin\\Hostx64\\x64\\cl.exe"
```

Find your actual MSVC `cl.exe` path:
```cmd
dir "C:\Program Files" /s /b | findstr cl.exe
```

## Building Your Game

### From command prompt in your project root:

```cmd
lua build.lua mygame
```

Replace `mygame` with your desired executable name.

### What happens:

1.  Scans all Lua files in `src/` and `game/`
2.  Bundles them as hex-encoded byte arrays in C
3.  Reads `game/conf.lua` for build settings (console mode, icon)
4.  Compiles with MSVC
5.  Copies required DLLs (`lua51.dll`, `raylib.dll`)
6.  Cleans up temporary files (`.c`, `.obj`, `.rc`, `.res`)

### Output location:

```
build/mygame/
├── mygame.exe      ← Your standalone game
├── lua51.dll       ← Required runtime *(dont remove)*
└── raylib.dll      ← Required runtime *(dont remove)*
```

## Distribution

Share the entire `build/mygame/` folder with players. They can run `mygame.exe` directly.

### Folder structure for users:

```
mygame/
├── mygame.exe
├── lua51.dll
├── raylib.dll
├── mods/          ← Optional: for mod support
└── save/          ← Optional: created automatically for saves
```

> **Note:** Mods and saves use external folders by default. Users can add mods or edit saves if enabled in config.

## Configuration

Edit `game/conf.lua` to control build behavior:
This covers everything from window sizing, enabling modules, to setting your network information.

### Debug build (with console):
```lua
-- In game/conf.lua
window = { console = true }
```

### Release build (no console):
```lua
-- In game/conf.lua
window = { console = false }
```

### Private/Public save files:
```lua
build = {
    external_save = true,  -- true = save/ folder is external, false = internal to exe
}
```

## Troubleshooting

**"cl.exe not found"**
- Verify MSVC is installed
- Check the path in `build.lua` matches your installation
- Run `dir "C:\Program Files" /s /b | findstr cl.exe`

**"LUA_LIB not found"**
- Verify environment variables: `echo %LUA_LIB%`
- Re-run `set LUA_LIB=...` if needed
- Or set them permanently in System Properties → Environment Variables

**Exe crashes immediately**
- Check `default_scene` is set in `game/conf.lua`
- Run from command prompt to see error output
- Enable console mode: set `window.console = true` in config

**Icon not showing**
- Icon must be `.ico` format (not PNG)
- Icon file must exist at build time
- Check path in `game/conf.lua` is correct

**Missing DLLs error**
- Copy `lua51.dll` and `raylib.dll` to same folder as exe
- Build script does this automatically to `build/mygame/`

## How It Works

1. **Bundling:** All Lua files are converted to byte arrays and embedded in C code
2. **Custom Loader:** A custom `package.searchers` function loads modules from embedded data
3. **Sandboxing:** Game scenes get sandboxed environments with the engine API
4. **Fallback:** Development mode uses file loading, bundled exe uses embedded code

## Notes

- Entire codebase bundled no loose Lua files needed
- Source code protected (compiled into exe)
- Mods load from external `mods/` folder (if enabled)
- Saves go to `save/` or `data/save/` based on config
- Builds are reproducible: same source = same exe
- Works on Windows (MSVC required)

## Advanced

### Multiple builds:
```cmd
luajit build.lua game_debug
luajit build.lua game_release
```

### Custom MSVC version:
Edit `build.lua` and update the `cl_exe` path to your specific MSVC installation.

### Packaging for distribution:
Zip the entire `/mygame/` folder from `/build/` and share. No installer needed users just extract and run.