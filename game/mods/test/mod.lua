--[[
    Test file you can and should remove this :)
]]

local mod = {
    name = "Test Mod",
    version = "1.0.0"
}

function mod.init(engine)
    print("Test mod loaded!")

    engine.hooks.listen("player_damage", function(data)
        print("Player took " .. data.damage .. " damage. Health remaining: " .. data.health)
    end)

    engine.hooks.listen("enemy_killed", function(data)
        print("A mod detected: A " .. data.type .. " was killed! Score is now: " .. data.score)
    end)

    engine.hooks.listen("draw_after", function(data)
        local player = data.player
        engine.draw.text({ text = "MOD SCORE: " .. player.score, x = 20, y = 190, size = 14, colour = {0, 255, 0, 255}})

        if player.health < 50 then
            engine.draw.circle({ x = player.x, y = player.y, radius = 30, colour = {255, 0, 0, 50}})
        end
    end)

    engine.hooks.listen("player_spawn", function(data)
        print("Player spawned at (" .. math.floor(data.x) .. ", " .. math.floor(data.y) .. ")")
    end)

    engine.hooks.listen("enemy_spawn", function(data)
        print("New " .. data.type .. " spawned at (" .. math.floor(data.x) .. ", " .. math.floor(data.y) .. ")")
    end)
end

return mod