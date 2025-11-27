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

--- @module engine.network
--- @description Simple Windows networking module using LuaJIT FFI. Provides TCP and UDP sockets.

local ffi = require("ffi")

local ws2_32
local WSAEWOULDBLOCK = 10035
local WSAETIMEDOUT = 10060
local WSAEINPROGRESS = 10036
local WSAEALREADY = 10037

local SOL_SOCKET = 0xFFFF
local SO_NONBLOCK = 0x1006
local SO_ERROR = 0x1007

local AF_INET = 2
local SOCK_STREAM = 1
local SOCK_DGRAM = 2
local IPPROTO_TCP = 6
local IPPROTO_UDP = 17

if ffi.os ~= "Windows" then
    error("Windows only")
end

ffi.cdef[[
    typedef unsigned short WORD;
    typedef uintptr_t SOCKET;
    typedef long c_long;

    typedef struct {
        WORD wVersion;
        WORD wHighVersion;
        char szDescription[256];
        char szSystemStatus[128];
        unsigned short iMaxSockets;
        unsigned short iMaxUdpDg;
        char* lpVendorInfo;
    } WSAData;

    typedef struct {
        short sin_family;
        unsigned short sin_port;
        unsigned int sin_addr;
        char sin_zero[8];
    } sockaddr_in;

    int WSAStartup(WORD wVersionRequested, WSAData* lpWSAData);
    int WSACleanup(void);
    int WSAGetLastError(void);
    SOCKET socket(int af, int type, int protocol);
    int bind(SOCKET s, const void* name, int namelen);
    int connect(SOCKET s, const void* name, int namelen);
    int send(SOCKET s, const char* buf, int len, int flags);
    int sendto(SOCKET s, const char* buf, int len, int flags, const struct sockaddr* to, int tolen);
    int recv(SOCKET s, char* buf, int len, int flags);
    int recvfrom(SOCKET s, char* buf, int len, int flags, struct sockaddr* from, int* fromlen);
    int closesocket(SOCKET s);
    int setsockopt(SOCKET s, int level, int optname, const char* optval, int optlen);
    unsigned long htonl(unsigned long hostlong);
    unsigned short htons(unsigned short hostshort);
    unsigned long inet_addr(const char* cp);
    int getsockname(SOCKET s, struct sockaddr* name, int* namelen);
    unsigned short ntohs(unsigned short netshort);
]]

ws2_32 = ffi.load("ws2_32")
local wsa = ffi.new("WSAData")
if ws2_32.WSAStartup(0x0202, wsa) ~= 0 then
    error("WSAStartup failed")
end

--- @section Helpers

--- Create a sockaddr_in structure for the given IP and port
--- @param ip string IP address (e.g. "127.0.0.1")
--- @param port number Port number
--- @return sockaddr_in sa The resulting sockaddr_in
local function sockaddr(ip, port)
    local sa = ffi.new("sockaddr_in")
    sa.sin_family = AF_INET
    sa.sin_port   = ws2_32.htons(port)
    sa.sin_addr   = ws2_32.inet_addr(ip)
    return sa
end

--- Create a non-blocking socket
--- @param sock_type number Socket type (SOCK_STREAM or SOCK_DGRAM)
--- @param protocol number Protocol (IPPROTO_TCP or IPPROTO_UDP)
--- @return SOCKET|nil s The created socket or nil on failure
local function create_socket(sock_type, protocol)
    local s = ws2_32.socket(AF_INET, sock_type, protocol)
    if s == ffi.cast("SOCKET", -1) then
        return nil
    end
    local enabled = ffi.new("int[1]", 1)
    ws2_32.setsockopt(s, SOL_SOCKET, SO_NONBLOCK, ffi.cast("const char*", enabled), ffi.sizeof("int"))
    return s
end

--- @section Module

local network = {}

--- Connect to a remote host with both TCP and UDP sockets
--- @param ip string Remote IP address
--- @param port number Remote port
--- @return table conn Connection object containing tcp and udp sockets
function network.connect(ip, port)
    local conn = {
        ip = ip,
        port = port,
        mode = "mixed",
        tcp = nil,
        udp = nil,
        tcp_buffer = "",
        connected = false,
        has_received_data = false,
        has_reported_disconnect = false,
        udp_bound = false
    }

    local sa = sockaddr(ip, port)

    conn.tcp = create_socket(SOCK_STREAM, IPPROTO_TCP)
    if conn.tcp then
        ws2_32.connect(conn.tcp, sa, ffi.sizeof(sa))
    end

    conn.udp = create_socket(SOCK_DGRAM, IPPROTO_UDP)
    if conn.udp then
        local udp_sa = sockaddr("0.0.0.0", 0)
        local bind_result = ws2_32.bind(conn.udp, udp_sa, ffi.sizeof(udp_sa))
        conn.udp_bound = (bind_result == 0)
    end

    return conn
end

--- Send a message over TCP or UDP
--- @param conn table Connection object
--- @param msg string Message to send
--- @param force_udp boolean|nil Force sending via UDP
--- @return boolean success True if the message was sent
function network.send(conn, msg, force_udp)
    if not conn or not msg then return false end

    if (msg:find("^POS:") or msg:find("^UDP_INIT:")) and conn.udp and not force_udp ~= true then
        local sa = sockaddr(conn.ip, conn.port)
        return ws2_32.sendto(conn.udp, msg, #msg, 0, ffi.cast("const struct sockaddr*", sa), ffi.sizeof(sa)) > 0
    end

    if conn.tcp then
        local tcp_msg = msg .. "\n"
        return ws2_32.send(conn.tcp, tcp_msg, #tcp_msg, 0) > 0
    end

    return false
end

--- Receive messages from TCP and UDP sockets
--- @param conn table Connection object
--- @param size number|nil Maximum buffer size (default 4096)
--- @return table result Table with tcp and udp arrays containing received messages
function network.receive(conn, size)
    if not conn then return {tcp = {}, udp = {}} end
    size = size or 4096
    local result = { tcp = {}, udp = {} }
    local buf = ffi.new("char[?]", size)

    -- TCP receive logic
    if conn.tcp then
        local n = ws2_32.recv(conn.tcp, buf, size, 0)
        if n > 0 then
            conn.has_received_data = true
            conn.tcp_buffer = conn.tcp_buffer .. ffi.string(buf, n)
            while true do
                local nl = conn.tcp_buffer:find("\n")
                if not nl then break end
                local line = conn.tcp_buffer:sub(1, nl-1):gsub("\r", "")
                conn.tcp_buffer = conn.tcp_buffer:sub(nl + 1)
                if line ~= "" then table.insert(result.tcp, line) end
            end
        elseif n == 0 and not conn.has_reported_disconnect then
            conn.has_reported_disconnect = true
            table.insert(result.tcp, "DISCONNECTED")
        else
            local err = ws2_32.WSAGetLastError()
            if err ~= WSAEWOULDBLOCK and not conn.has_reported_disconnect then
                conn.has_reported_disconnect = true
                table.insert(result.tcp, "DISCONNECTED")
            end
        end
    end

    -- UDP receive logic
    if conn.udp then
        local from_addr = ffi.new("sockaddr_in")
        local from_len  = ffi.new("int[1]", ffi.sizeof("sockaddr_in"))
        pcall(function()
            while true do
                local n = ws2_32.recvfrom(conn.udp, buf, size, 0, ffi.cast("struct sockaddr*", from_addr), from_len)
                if n > 0 then
                    table.insert(result.udp, ffi.string(buf, n))
                else
                    local wserr = ws2_32.WSAGetLastError()
                    if wserr == WSAEWOULDBLOCK or wserr == WSAETIMEDOUT then break end
                    break
                end
            end
        end)
    end

    return result
end

--- Close TCP and UDP sockets
--- @param conn table Connection object
function network.close(conn)
    if not conn then return end
    if conn.tcp then ws2_32.closesocket(conn.tcp) end
    if conn.udp then ws2_32.closesocket(conn.udp) end
end

--- Cleanup Winsock resources
function network.cleanup()
    ws2_32.WSACleanup()
end

return network
