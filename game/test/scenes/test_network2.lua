--[[
    Test file you can and should remove this :)
]]

local test_network2 = {}

function test_network2:load()
    local scene_data = self._scene_data or {}
    self.socket      = scene_data.socket
    self.is_host     = scene_data.is_host
    self.command     = scene_data.command

    self.theme = engine.ui.style.get_theme()

    self.local_player = { x = 100, y = 100, w = 50, h = 50 }
    self.local_player_id = nil
    self.remote_players = {}
    self.room_id = nil

    self.match_ready = false
    self.status = "Connecting..."
    self.send_timer = 0
    self.command_sent = false
    self.has_disconnected = false

    self.udp_init_sent = false
    self.udp_init_timer = 0
    self.has_received_any_pos = false

    self.speed = 200

    engine.actions.map_action("move_left",  {"a", "arrowleft"})
    engine.actions.map_action("move_right", {"d", "arrowright"})
    engine.actions.map_action("move_up",    {"w", "arrowup"})
    engine.actions.map_action("move_down",  {"s", "arrowdown"})

    print("[Scene2] Loaded - waiting for network")
end

function test_network2:update(dt)
    if not self.socket then return end

    if not self.command_sent and self.command then
        engine.network.send(self.socket, self.command)
        self.command_sent = true
    end

    local packets = engine.network.receive(self.socket)

    for _, line in ipairs(packets.tcp) do
        self:handle_message(line)
    end

    for _, packet in ipairs(packets.udp) do
        self:handle_message(packet)
    end

    if engine.actions.is_action_down("move_left") then self.local_player.x = self.local_player.x - self.speed * dt end
    if engine.actions.is_action_down("move_right") then self.local_player.x = self.local_player.x + self.speed * dt end
    if engine.actions.is_action_down("move_up")    then self.local_player.y = self.local_player.y - self.speed * dt end
    if engine.actions.is_action_down("move_down")  then self.local_player.y = self.local_player.y + self.speed * dt end

    if self.match_ready and self.local_player_id then
        self.send_timer = self.send_timer + dt
        if self.send_timer > 0.033 then
            local msg = string.format("POS:%s:%d,%d",
                self.local_player_id,
                math.floor(self.local_player.x),
                math.floor(self.local_player.y)
            )
            engine.network.send(self.socket, msg)
            self.send_timer = 0
        end
    end

    if self.local_player_id and self.match_ready and not self.has_received_any_pos then
        self.udp_init_timer = self.udp_init_timer + dt
        if self.udp_init_timer > 2.0 then
            local msg = string.format("UDP_INIT:%s:%s", self.room_id or "0000", self.local_player_id)
            engine.network.send(self.socket, msg, true)
            self.udp_init_timer = 0
        end
    end

    if engine.keyboard.is_pressed("escape") then
        engine.network.send(self.socket, "DISCONNECT")
        engine.scene.switch("test_network1")
    end
end

function test_network2:handle_message(line)
    if line == "DISCONNECTED" then
        if self.has_disconnected then return end
        self.has_disconnected = true
        self.remote_players = {}
        self.match_ready = false
        self.status = "Disconnected"
        return
    end

    local cmd, arg = line:match("^([^:]+):?(.*)$")
    if not cmd then return end

    local handlers = {

        HOST_OK = function(a)
            self.room_id = a
            self.status = "Room created: " .. a
        end,

        ROOM_ID = function(a)
            self.room_id = a
            self.status = "Joined room: " .. a
        end,

        MY_ID = function(a)
            self.local_player_id = a
            self.status = "ID: " .. a

            if not self.udp_init_sent then
                local msg = string.format("UDP_INIT:%s:%s", self.room_id or "0000", a)
                engine.network.send(self.socket, msg, true)
                self.udp_init_sent = true
                print("[UDP_INIT] Sent on MY_ID")
            end
        end,

        MATCH_READY = function()
            self.match_ready = true
            self.status = "Game started!"
        end,

        ERROR = function(a)
            self.status = "Error: " .. a
        end,

        POS = function(a)
            local pid, x, y = a:match("^(.+):(%d+),(%d+)$")
            if pid and pid ~= self.local_player_id then
                x = tonumber(x)
                y = tonumber(y)
                self.has_received_any_pos = true

                if not self.remote_players[pid] then
                    self.remote_players[pid] = {
                        id = pid,
                        x = x, y = y,
                        w = 50, h = 50,
                        colour = {math.random(100,255), math.random(100,255), math.random(100,255), 255}
                    }
                else
                    self.remote_players[pid].x = x
                    self.remote_players[pid].y = y
                end
            end
        end,

        PLAYER_LIST = function(a)
            local expected = {}

            for id in a:gmatch("([^,]+)") do
                id = id:gsub("^%s*(.-)%s*$", "%1")
                if id ~= "" and id ~= self.local_player_id then
                    expected[id] = true
                end
            end

            for id in pairs(self.remote_players) do
                if not expected[id] then
                    self.remote_players[id] = nil
                end
            end
        end,
    }

    if handlers[cmd] then
        handlers[cmd](arg)
    end
end

function test_network2:draw()
    engine.draw.clear({ colour = self.theme.bg_main })

    engine.draw.text({ text = self.status, x = 10, y = 10, size = 18, colour = self.theme.text_primary })

    if self.room_id then
        engine.draw.text({ text = "Room: " .. self.room_id, x = 10, y = 35, size = 16, colour = self.theme.text_primary })
    end

    engine.draw.rect({ x = self.local_player.x, y = self.local_player.y, w = self.local_player.w, h = self.local_player.h, colour = self.theme.accent })
    if self.local_player_id then
        engine.draw.text({ text = "YOU\n" .. self.local_player_id, x = self.local_player.x + 5, y = self.local_player.y + 10, size = 10, colour = {255,255,255,255} })
    end

    for _, p in pairs(self.remote_players) do
        engine.draw.rect({ x = p.x, y = p.y, w = p.w, h = p.h, colour = p.colour })
        engine.draw.text({ text = "THEM\n" .. p.id, x = p.x + 5, y = p.y + 10, size = 10, colour = {255,255,255,255} })
    end

    engine.draw.text({ text = "WASD/Arrows - move | ESC - leave", x = 10, y = 700, size = 12, colour = self.theme.text_secondary })
end

return test_network2