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

--- @module config
--- @description Game config settings; will change / move but for now does the job.

return {

    --- @section Window Settings

    window = {
        title = "Lua Engine", -- Window title
        icon = "src/engine/assets/case_icon.png", -- Window icon
        size = {
            width = 1280, -- Window width
            height = 720  -- Window height
        },
        flags = { -- Raylib window flags
            vsync_hint = false,
            fullscreen_mode = false,
            resizable = false,
            undecorated = false,
            transparent = false,
            hidden = false,
            minimized = false,
            maximized = false,
            unfocused = false,
            topmost = false,
            always_run = false,
            highdpi = false,
            mouse_passthrough = false,
            borderless_windowed_mode = false,
            msaa_4x_hint = false,
            interlaced_hint = false
        },
        console = false
    },

    --- @section FPS

    fps = { 
        draw = true, -- Draws fps to the screen
        target = 500 -- Target fps (sort of works a cap) false or number
    },

    --- @section Network

    network = { -- Runs of a server relay
        ip = "87.106.110.127", -- Replace with your ip
        port = 8000, -- Replace with your port
        type = "mixed", -- Mixed is recommended: "tcp" or "udp" or "mixed"
        none_blocking = true -- Toggle none blocking
    },

    --- @section Build Settings

    build = {
        external_save = true, -- If true, save folder is external (user-editable). If false, saves are bundled in exe data
    },

    --- @section Modules

    modules = {
        audio = true, -- Enables raylibs InitAudioDevice()
        draw = true, -- Enables `draw` functions
        image = true, -- Enables `image` functions
        keyboard = true, -- Enables `keyboard` input functions
        mouse = true, -- Enables `mouse` input functions
        actions = true, -- Enables `action` mapping functions
        collision = true, -- Enables `collision` functions; these are basic if need more details add a physics library
        ui = true, -- Enables ui module; handles pretty much the same as any gui lib
        mods = true, -- Enables mod support; loads all mods and allows access to `engine.hooks`
        filesystem = true, -- Basic file saving and loading; useful for single player persistance
        network = true, -- Enable networking; requires a basic relay server
    },

    --- @section Game Scenes

    default_scene = "test_mods", -- Specify the default scene game should load; required for .exe.

    scenes = {
        -- Game scenes
        title = "src.scenes.title",
        game = "src.scenes.game",
        
        -- Test scenes
        test_draw = "src.test.scenes.test_draw",
        test_audio = "src.test.scenes.test_audio",
        test_image = "src.test.scenes.test_image",
        test_actions = "src.test.scenes.test_actions",
        test_collision = "src.test.scenes.test_collision",
        test_ui = "src.test.scenes.test_ui",
        test_mods = "src.test.scenes.test_mods",
        test_filesystem = "src.test.scenes.test_filesystem",
        test_network1 = "src.test.scenes.test_network1",
        test_network2 = "src.test.scenes.test_network2"
    }
}