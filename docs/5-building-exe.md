# Building .exe Games

Package your game into a standalone executable. 
Your game logic stays private, players get a runnable `.exe` only.

## Prerequisites

- **LuaJIT** installed (with `lua51.lib`)
- **MSVC Compiler** (Visual Studio or Build Tools)
- **luastatic** installed via LuaRocks

## Build Steps

### Step 1: Set environment variables

Run once in your command prompt:

```bash
set LUASTATIC_PATH=C:\path\to\luastatic.bat
set LUA_LIB=C:\path\to\lua51.lib
set LUA_INCLUDE=C:\path\to\luajit\src
```

### Step 2: Build

From **x64 Native Tools Command Prompt**, run:

```bash
lua build.lua main
cl main.luastatic.c -I"%LUA_INCLUDE%" "%LUA_LIB%" /FeYOUR_GAME.exe
del main.luastatic.c main.luastatic.obj
```

> **Note:** Make sure `default_scene` is set in `config.lua`, otherwise the engine will load its fallback default scene.

You now have `YOUR_GAME.exe` ready to distribute.

## Output

Your game is a single `YOUR_GAME.exe` file with:
- All Lua code embedded
- All engine code included
- All game scenes bundled
- Ready to share with players