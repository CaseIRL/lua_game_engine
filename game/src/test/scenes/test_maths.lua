--[[
    Test file you can and should remove this :)
]]

local test_maths = {}

function test_maths:load()
    print("Maths test loaded")
    self.theme = engine.ui.style.get_theme()
    local w, h = engine.window.get_size()
    self.width = w
    self.height = h
    self.test_index = 1
    self.tests = {"Core Math", "Easing Functions", "Geometry 2D", "Geometry 3D", "Matrix 4x4", "Probability", "Statistics", "Vector 3D"}
    self.animation_time = 0
    self:run_all_tests()
end

function test_maths:run_all_tests()
    print("CORE MATH TESTS")
    print("round(3.7, 0) =", engine.math.round(3.7, 0))
    print("clamp(150, 0, 100) =", engine.math.clamp(150, 0, 100))
    print("lerp(0, 100, 0.5) =", engine.math.lerp(0, 100, 0.5))
    print("deg_to_rad(180) =", engine.math.deg_to_rad(180))
    print("rad_to_deg(3.14159) =", engine.math.rad_to_deg(3.14159))

    print("EASING TESTS")
    print("linear(0.5) =", engine.math.linear(0.5))
    print("in_quad(0.5) =", engine.math.in_quad(0.5))
    print("out_cubic(0.5) =", engine.math.out_cubic(0.5))

    print("GEO2D TESTS")
    print("distance_2d([0,0], [3,4]) =", engine.math.distance_2d({x=0,y=0}, {x=3,y=4}))
    print("circle_area(radius=5) =", engine.math.circle_area(5))
    print("angle_between_points =", engine.math.angle_between_points({x=0,y=0}, {x=1,y=1}))

    print("GEO3D TESTS")
    print("distance_3d([0,0,0], [1,1,1]) =", engine.math.distance_3d({x=0,y=0,z=0}, {x=1,y=1,z=1}))
    print("midpoint =", engine.math.midpoint({x=0,y=0,z=0}, {x=1,y=1,z=1}))

    print("MAT4 TESTS")
    local mat_a = engine.math.mat4.translate(1, 2, 3)
    print("Matrix multiplication successful:", (mat_a * engine.math.mat4.scale(2,2,2)) ~= nil)
    print("Translation from matrix =", mat_a:get_translation())

    print("PROBABILITY TESTS")
    engine.math.set_seed(42)
    print("random_between(1, 10) =", engine.math.random_between(1, 10))
    print("random_int(1, 10) =", engine.math.random_int(1, 10))
    print("chance(0.5) =", engine.math.chance(0.5))

    print("STATISTICS TESTS")
    local data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    print("mean([1..10]) =", engine.math.mean(data))
    print("median([1..10]) =", engine.math.median(data))
    print("std_dev([1..10]) =", engine.math.standard_deviation(data))
    print("VEC3 TESTS")

    local v1, v2 = engine.math.vec3(1,2,3), engine.math.vec3(4,5,6)
    print("v1 =", v1)
    print("v1 + v2 =", v1 + v2)
    print("v1:dot(v2) =", v1:dot(v2))
    print("v1:length() =", v1:length())
    print("\n=== ALL TESTS COMPLETE ===\n")
end

function test_maths:update(dt)
    self.animation_time = self.animation_time + dt
    if engine.keyboard.is_pressed("arrowup") then
        self.test_index = self.test_index - 1
        if self.test_index < 1 then self.test_index = #self.tests end
    end
    if engine.keyboard.is_pressed("arrowdown") then
        self.test_index = self.test_index + 1
        if self.test_index > #self.tests then self.test_index = 1 end
    end
    if engine.keyboard.is_pressed("escape") then engine.scene.switch("title") end
end

function test_maths:draw()
    engine.draw.clear({colour = self.theme.bg_main})
    local theme, x, y = self.theme, 20, 30
    engine.draw.text({text = "MATHS TEST", x = x, y = y, size = 18, colour = theme.accent})
    engine.draw.text({text = "UP/DOWN Navigate | ESC Return", x = x, y = y + 24, size = 12, colour = theme.text_secondary})
    
    local menu_y = 80
    for i, test_name in ipairs(self.tests) do
        local selected = i == self.test_index
        engine.draw.text({text = (selected and "> " or "  ")..test_name, x = x, y = menu_y + (i-1)*22, size = 13, colour = selected and theme.accent2 or theme.text_secondary})
    end
    
    engine.draw.text({text = "--- "..self.tests[self.test_index].."", x = 300, y = 80, size = 15, colour = theme.accent})
    
    if self.test_index == 1 then 
        self:draw_core(300, 110)
    elseif self.test_index == 2 then 
        self:draw_easing(300, 110)
    elseif self.test_index == 3 then 
        self:draw_geo2d(300, 110)
    elseif self.test_index == 4 then 
        self:draw_geo3d(300, 110)
    elseif self.test_index == 5 then 
        self:draw_mat4(300, 110)
    elseif self.test_index == 6 then 
        self:draw_prob(300, 110)
    elseif self.test_index == 7 then 
        self:draw_stats(300, 110)
    elseif self.test_index == 8 then 
        self:draw_vec3(300, 110)
    end
end

function test_maths:text(x, y, txt, col)
    engine.draw.text({text = txt, x = x, y = y, size = 12, colour = col or self.theme.text_primary})
end

function test_maths:draw_core(x, y)
    local t = self.theme
    self:text(x, y, "round(3.7, 0) = "..engine.math.round(3.7, 0), t.text_primary)
    self:text(x, y+22, "clamp(150, 0, 100) = "..engine.math.clamp(150, 0, 100), t.text_primary)
    self:text(x, y+44, "lerp(0, 100, 0.5) = "..engine.math.lerp(0, 100, 0.5), t.text_primary)
    self:text(x, y+66, "deg_to_rad(90) = "..string.format("%.4f", engine.math.deg_to_rad(90)), t.text_primary)
    self:text(x, y+88, "rad_to_deg(pi) = "..string.format("%.2f", engine.math.rad_to_deg(3.14159)), t.text_primary)
end

function test_maths:draw_easing(x, y)
    local t = (math.sin(self.animation_time * 2) + 1) / 2
    self:text(x, y, "t = "..string.format("%.2f", t), self.theme.accent2)
    
    local easings = {linear = engine.math.linear(t), in_quad = engine.math.in_quad(t), out_quad = engine.math.out_quad(t), out_cubic = engine.math.out_cubic(t)}
    local i = 0
    for name, val in pairs(easings) do
        self:text(x, y+28+(i*22), name.." = "..string.format("%.3f", val), self.theme.text_primary)
        engine.draw.rect({x = x+120, y = y+28+(i*22), w = val*80, h = 13, colour = self.theme.accent})
        i = i + 1
    end
end

function test_maths:draw_geo2d(x, y)
    local t = self.theme
    local dist = engine.math.distance_2d({x=0,y=0}, {x=3,y=4})
    local angle = engine.math.angle_between_points({x=0,y=0}, {x=1,y=1})
    local area = engine.math.circle_area(50)
    
    self:text(x, y, "Distance: "..string.format("%.2f", dist), t.text_primary)
    self:text(x, y+22, "Angle: "..string.format("%.2f deg", angle), t.text_primary)
    self:text(x, y+44, "Circle area (r=50): "..string.format("%.2f", area), t.text_primary)
    
    engine.draw.circle({x = x, y = y+90, radius = 4, colour = t.accent})
    engine.draw.circle({x = x+80, y = y+110, radius = 4, colour = t.accent2})
    engine.draw.line({x1 = x, y1 = y+90, x2 = x+80, y2 = y+110, colour = t.text_secondary})
    engine.draw.circle({x = x, y = y+150, radius = 25, colour = {1, 0, 0, 0.3}})
end

function test_maths:draw_geo3d(x, y)
    local t = self.theme
    local dist = engine.math.distance_3d({x=0,y=0,z=0}, {x=3,y=4,z=0})
    local mid = engine.math.midpoint({x=0,y=0,z=0}, {x=1,y=1,z=1})
    local inbox = engine.math.is_point_in_box({x=5,y=5,z=5}, {x=0,y=0,z=0,width=10,height=10,depth=10})
    
    self:text(x, y, "3D Distance [0,0,0] to [3,4,0]: "..string.format("%.2f", dist), t.text_primary)
    self:text(x, y+22, "Midpoint: ("..string.format("%.1f,%.1f,%.1f", mid.x, mid.y, mid.z)..")", t.text_primary)
    self:text(x, y+44, "Point in box: "..tostring(inbox), t.text_primary)
end

function test_maths:draw_mat4(x, y)
    local t = self.theme
    local trans = engine.math.mat4.translate(10, 20, 30)
    local pos = trans:get_translation()
    local scale = engine.math.mat4.scale(2, 3, 4)
    local scale_vals = scale:get_scale()
    local mult = trans * scale
    local vec = trans:multiply_vec3({x=1, y=0, z=0})
    
    self:text(x, y, "Translation: ("..pos.x..", "..pos.y..", "..pos.z..")", t.text_primary)
    self:text(x, y+22, "Scale: ("..scale_vals.x..", "..scale_vals.y..", "..scale_vals.z..")", t.text_primary)
    self:text(x, y+44, "Multiply: "..(mult and "OK" or "FAIL"), mult and t.accent3 or t.text_primary)
    self:text(x, y+66, "Vector transform: ("..string.format("%.2f,%.2f,%.2f", vec.x, vec.y, vec.z)..")", t.text_primary)
end

function test_maths:draw_prob(x, y)
    local t = self.theme
    engine.math.set_seed(math.floor(self.animation_time * 10))
    
    self:text(x, y, "random_between(1,100): "..engine.math.random_between(1, 100), t.text_primary)
    self:text(x, y+22, "random_int(1,6): "..engine.math.random_int(1, 6), t.text_primary)
    self:text(x, y+44, "chance(0.5): "..tostring(engine.math.chance(0.5)), t.text_primary)
    local choice = engine.math.weighted_choice({apple=5, banana=3, cherry=2})
    self:text(x, y+66, "weighted_choice: "..(choice or "nil"), t.text_primary)
end

function test_maths:draw_stats(x, y)
    local t = self.theme
    local data = {2, 4, 6, 8, 10, 12, 14, 16, 18, 20}
    
    self:text(x, y, "Data: {2,4,6,8,10,12,14,16,18,20}", t.accent2)
    self:text(x, y+22, "Mean: "..string.format("%.2f", engine.math.mean(data)), t.text_primary)
    self:text(x, y+44, "Median: "..string.format("%.2f", engine.math.median(data)), t.text_primary)
    self:text(x, y+66, "Std Dev: "..string.format("%.2f", engine.math.standard_deviation(data)), t.text_primary)
    self:text(x, y+88, "Range: "..engine.math.range(data), t.text_primary)
end

function test_maths:draw_vec3(x, y)
    local t = self.theme
    local v1 = engine.math.vec3(3, 4, 0)
    local v2 = engine.math.vec3(1, 0, 0)
    
    self:text(x, y, "v1 = "..tostring(v1), t.text_primary)
    self:text(x, y+22, "v2 = "..tostring(v2), t.text_primary)
    self:text(x, y+44, "v1:length() = "..string.format("%.2f", v1:length()), t.text_primary)
    self:text(x, y+66, "v1:dot(v2) = "..string.format("%.2f", v1:dot(v2)), t.text_primary)
    self:text(x, y+88, "v1:normalize() = "..tostring(v1:normalize()), t.text_primary)
    self:text(x, y+110, "v1 + v2 = "..tostring(v1 + v2), t.text_primary)
end

function test_maths:unload()
    print("Maths test scene unloaded")
end

return test_maths