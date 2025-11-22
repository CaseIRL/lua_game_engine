# Creating Scenes

Scenes are the building blocks of your game. 
Each scene is a Lua module with optional lifecycle methods that the engine calls at the right time.

# Scene Lifecycle

Every scene can implement up to four methods:

```lua
function scene:load()
    -- Called once when the scene starts
    -- Initialize state, load resources
end

function scene:update(dt)
    -- Called every frame
    -- Handle input, update game logic
    -- dt = delta time in seconds
end

function scene:draw()
    -- Called every frame after update()
    -- Render everything here
end

function scene:unload()
    -- Called once when switching away
    -- Clean up if needed
end
```

All methods are optional. 
If you don't implement `update()` or `draw()`, the engine just skips them.

## Basic Scene

Here's a minimal scene that just draws text:

```lua
local menu = {}

function menu:draw()
    engine.draw.clear()
    engine.draw.text({ text = "Menu", x = 100, y = 100, size = 32 })
end

return menu
```

## Scene with State

Store scene state in the scene object itself:

```lua
local game = {}

function game:load()
    self.player_x = 100
    self.player_y = 100
    self.score = 0
end

function game:update(dt)
    if engine.input.is_key_down("arrowright") then
        self.player_x = self.player_x + 200 * dt
    end
    if engine.input.is_key_down("arrowleft") then
        self.player_x = self.player_x - 200 * dt
    end
    
    self.score = self.score + dt
end

function game:draw()
    engine.draw.clear()
    
    engine.draw.circle({ x = self.player_x, y = self.player_y, radius = 15, r = 0, g = 255, b = 100 })
    engine.draw.text({ text = "Score: " .. math.floor(self.score), x = 10, y = 10, size = 20 })
end

return game
```

## Switching Scenes

Use `engine.scene.switch()` to change scenes:

```lua
local title = {}

function title:draw()
    engine.draw.clear()
    engine.draw.text({ text = "Title Screen", x = 100, y = 100, size = 24 })
    engine.draw.text({ text = "Press SPACE to start", x = 100, y = 150, size = 16 })
end

function title:update(dt)
    if engine.input.is_key_pressed("space") then
        engine.scene.switch("game")
    end
end

return title
```

## Scene Organization

Organize scenes in a `scenes/` directory:

```
game/
  config.lua
  scenes/
    title.lua
    game.lua
    game_over.lua
```

Register scenes in your config:

```lua
-- game/config.lua
return {
    window = {
        title = "My Game",
        size = { width = 1280, height = 720 }
    },

    fps = {
        draw = true,
        target = 144
    },

    modules = {
        audio = true
    },

    scenes = { -- will probably change
        title = "title",
        game = "game",
        game_over = "game_over"
    }
}
```

The engine loads and registers these scenes automatically from the config.

# Complete Example: Game Flow

**scenes/title.lua:**
```lua
local engine = require("engine.api")
local title = {}

function title:load()
    print("Title scene started")
end

function title:update(dt)
    if engine.input.is_key_pressed("space") then
        engine.scene.switch("game")
    end
end

function title:draw()
    engine.draw.clear({ r = 30, g = 30, b = 50 })
    engine.draw.text({ text = "My Game", x = 200, y = 100, size = 48, r = 255, g = 255, b = 0 })
    engine.draw.text({ text = "Press SPACE to play", x = 200, y = 200, size = 20, r = 200, g = 200, b = 200 })
end

function title:unload()
    print("Title scene ended")
end

return title
```

**scenes/game.lua:**
```lua
local engine = require("engine.api")
local game = {}

function game:load()
    self.player = {
        x = 400,
        y = 300,
        radius = 10,
        speed = 300
    }
    self.enemies = {
        { x = 200, y = 200, radius = 10 },
        { x = 600, y = 200, radius = 10 }
    }
    self.lives = 3
end

function game:update(dt)
    -- Player movement
    if engine.input.is_key_down("arrowright") then
        self.player.x = self.player.x + self.player.speed * dt
    end
    if engine.input.is_key_down("arrowleft") then
        self.player.x = self.player.x - self.player.speed * dt
    end
    if engine.input.is_key_down("arrowup") then
        self.player.y = self.player.y - self.player.speed * dt
    end
    if engine.input.is_key_down("arrowdown") then
        self.player.y = self.player.y + self.player.speed * dt
    end
    
    -- Back to title
    if engine.input.is_key_pressed("escape") then
        engine.scene.switch("title")
    end
end

function game:draw()
    engine.draw.clear({ r = 20, g = 20, b = 30 })
    
    -- Draw player
    engine.draw.circle({
        x = self.player.x,
        y = self.player.y,
        radius = self.player.radius,
        r = 0, g = 255, b = 100
    })
    
    -- Draw enemies
    for i, enemy in ipairs(self.enemies) do
        engine.draw.circle({
        x = enemy.x,
        y = enemy.y,
        radius = enemy.radius,
        r = 255, g = 0, b = 0
        })
    end
    
    -- Draw UI
    engine.draw.text({ text = "Lives: " .. self.lives, x = 10, y = 10, size = 20 })
    engine.draw.text({ text = "ESC to return", x = 10, y = 40, size = 14 })
end

function game:unload()
    print("Game ended")
end

return game
```

---

## Tips

- Use `self` to store scene-specific data that persists across frames
- Share state between scenes by creating a separate Lua module (e.g., state.lua) that both scenes can require and modify.
- Call `engine.scene.switch()` from `update()` to queue a scene change
- Delta time (`dt`) is in seconds—multiply movement by `dt` for frame-rate-independent speed
- All drawing should happen in `draw()`, never in `update()`
- Use `load()` to initialize state, `unload()` to clean up

---

# Next Steps

- Add some stuff?
- Build some stuff?
- Bathe in Lua glory?