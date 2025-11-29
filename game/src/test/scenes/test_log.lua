--[[
    Test file you can and should remove this :)
]]

local test_log = {}

local function strip_ansi(s)
    return s:gsub("\27%[[0-9;]*m", "")
end

function test_log:load()
    engine.log.info("Logger test scene loaded")
    
    self.theme = engine.ui.style.get_theme()
    local w, h = engine.window.get_size()
    self.width = w
    self.height = h
    
    self.log_view_start = 1
    self.selected_level = 1
    self.levels = {"debug", "info", "success", "warn", "error"}

    engine.log.debug("This is a debug message", {test = true, number = 42})
    engine.log.info("This is an info message")
    engine.log.success("This is a success message")
    engine.log.warn("This is a warning message", {status = "caution"})
    engine.log.error("This is an error message (not fatal)")
    
    engine.log.info("Test data:", {player = {x = 100, y = 200}, hp = 50})
end

function test_log:update(dt)
    if engine.keyboard.is_pressed("w") then
        self.selected_level = math.max(1, self.selected_level - 1)
    end
    if engine.keyboard.is_pressed("s") then
        self.selected_level = math.min(#self.levels, self.selected_level + 1)
    end
    
    if engine.keyboard.is_pressed("space") then
        local level = self.levels[self.selected_level]
        engine.log[level]("Manual test: "..level.." level", {timestamp = os.time()})
    end

    if engine.keyboard.is_pressed("arrowup") then
        self.log_view_start = math.max(1, self.log_view_start - 1)
    end
    if engine.keyboard.is_pressed("arrowdown") then
        local history = engine.log.get_history()
        local lines_per_page = 8
        local max_start = math.max(1, #history - lines_per_page + 1)
        self.log_view_start = math.min(self.log_view_start + 1, max_start)
    end
    
    if engine.keyboard.is_pressed("r") then
        local history = engine.log.get_history()
        local lines_per_page = 8
        self.log_view_start = math.max(1, #history - lines_per_page + 1)
    end
    
    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function test_log:draw()
    engine.draw.clear({colour = self.theme.bg_main})
    
    local theme = self.theme
    local x, y = 20, 30

    engine.draw.text({text = "LOG TEST", x = x, y = y, size = 18, colour = theme.accent})
    engine.draw.text({text = "W/S: Select | SPACE: Log | UP/DOWN: Scroll | R: Newest | ESC: Exit", x = x, y = y + 24, size = 11, colour = theme.text_secondary})

    y = y + 65
    engine.draw.text({text = "Test Log Levels:", x = x, y = y, size = 13, colour = theme.accent2})
    y = y + 25
    
    for i, level in ipairs(self.levels) do
        local selected = i == self.selected_level
        local col = selected and theme.accent2 or theme.text_secondary
        engine.draw.text({text = (selected and "> " or "  ")..level:upper(), x = x, y = y + (i-1)*20, size = 12, colour = col})
    end

    y = y + 130
    engine.draw.text({text = "Log History:", x = x, y = y, size = 13, colour = theme.accent2})
    
    local history = engine.log.get_history()
    local lines_per_page = 8
    local max_start = math.max(1, #history - lines_per_page + 1)
    self.log_view_start = math.min(self.log_view_start, max_start)
    
    y = y + 25
    for i = 1, lines_per_page do
        local idx = self.log_view_start + i - 1
        if idx <= #history then
            local log_line = strip_ansi(history[idx])
            engine.draw.text({text = log_line:sub(1, 110), x = x, y = y + (i-1)*18, size = 10, colour = theme.text_primary})
        end
    end

    local info_y = self.height - 80
    engine.draw.rect({x = x - 5, y = info_y, w = 400, h = 70, colour = theme.bg_panel})
    engine.draw.rect_lines({x = x - 5, y = info_y, w = 400, h = 70, colour = theme.border_light.colour, line_thick = 1})
    
    engine.draw.text({text = "Total logs: "..#history.." | View: "..self.log_view_start, x = x, y = info_y + 8, size = 11, colour = theme.text_primary})
    engine.draw.text({text = "Press SPACE to log: "..self.levels[self.selected_level], x = x, y = info_y + 28, size = 11, colour = theme.accent})
    engine.draw.text({text = "Press R to scroll to top", x = x, y = info_y + 48, size = 11, colour = theme.text_secondary})
end

function test_log:unload()
    engine.log.info("Logger test scene unloaded")
end

return test_log