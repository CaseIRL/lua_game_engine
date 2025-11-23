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
        size = {
            width = 1280, -- Window width
            height = 720  -- Window height
        }
    },

    --- @section FPS Settings

    fps = { 
        draw = true, -- Draws fps to the screen
        target = 144 -- Target fps (sort of works a cap)
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
    },

    --- @section Game Scenes

    scenes = {
        -- Game scenes
        title = "scenes/title",
        game = "scenes/game",
        
        -- Test scenes
        test_draw = "test/scenes/test_draw",
        test_audio = "test/scenes/test_audio",
        test_image = "test/scenes/test_image",
        test_actions = "test/scenes/test_actions",
        test_collision = "test/scenes/test_collision"
    }
}