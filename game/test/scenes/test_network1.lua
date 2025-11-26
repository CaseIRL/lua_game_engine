--[[
    Test file you can and should remove this :)
]]

local test_network1 = {}

function test_network1:load()
    print("Network menu loaded")

    local w, h = engine.window.get_size()
    self.theme = engine.ui.style.get_theme()

    self.socket = nil
    self.status = "Enter Room ID to join, or Host"
    self.room_input = ""
    self.connecting = false
    self.is_joining = false

    local btn_w, btn_h = 200, 50
    local cx = (w / 2) - (btn_w / 2)
    local cy = (h / 2) - 50

    self.host_btn = engine.ui.button.new({
        x = cx,
        y = cy,
        w = btn_w,
        h = btn_h,
        text = "Host Room",
        roundness = 0.2,
        on_click = function()
            if not self.connecting then
                self.connecting = true
                self.status = "Connecting..."
                self.is_joining = false
                self.socket = engine.network.connect(engine.config.network.ip, engine.config.network.port)
            end
        end
    })

    self.join_btn = engine.ui.button.new({
        x = cx,
        y = cy + 70,
        w = btn_w,
        h = btn_h,
        text = "Join Room",
        roundness = 0.2,
        on_click = function()
            if #self.room_input == 4 and not self.connecting then
                self.connecting = true
                self.status = "Connecting..."
                self.room_to_join = self.room_input
                self.is_joining = true

                self.socket = engine.network.connect(engine.config.network.ip, engine.config.network.port )
            end
        end
    })    
end

function test_network1:update(dt)
    for i = 0, 9 do
        local key = tostring(i)
        if engine.keyboard.is_pressed(key) and #self.room_input < 4 then
            self.room_input = self.room_input .. key
        end
    end

    if engine.keyboard.is_pressed("backspace") and #self.room_input > 0 then
        self.room_input = self.room_input:sub(1, -2)
    end

    if self.connecting and self.socket then
        local cmd
        if self.is_joining then
            cmd = "JOIN:" .. self.room_to_join
        else
            cmd = "HOST"
        end

        engine.scene.switch("test_network2", { socket = self.socket, command = cmd, is_host = not self.is_joining })
        self.connecting = false
    end

    local mx, my = engine.mouse.get_pos()
    local pressed = engine.mouse.is_pressed(0)

    self.host_btn:update(mx, my, pressed)
    self.join_btn:update(mx, my, pressed)

    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function test_network1:draw()
    local w, h = engine.window.get_size()
    engine.draw.clear({ colour = self.theme.bg_main })

    engine.draw.text({ text = "NETWORK TEST", x = w/2 - 100, y = 50, size = 24, colour = self.theme.accent })
    engine.draw.text({ text = "Room ID: " .. (self.room_input ~= "" and self.room_input or "____"), x = w/2 - 80, y = 150, size = 18, colour = self.theme.text_primary })
    engine.draw.text({ text = "Type 4 digits to join", x = w/2 - 80, y = 180, size = 12, colour = self.theme.text_secondary })

    self.host_btn:draw()
    self.join_btn:draw()

    engine.draw.text({ text = self.status, x = w/2 - 100, y = h - 80, size = 14, colour = self.theme.text_primary })
    engine.draw.text({ text = "ESC - Return", x = 10, y = h - 30, size = 12, colour = self.theme.text_secondary })
end

return test_network1