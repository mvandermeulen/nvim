--[[
-- Helpers: AI Chat
--
-- Author: Mark van der Meulen
-- Updated: 2025-01-12
--]]


-- chat.lua - Neovim chat script using Lua.

local uv = vim.loop
local server = nil
local clients = {}
local client_socket = nil
local server_started = false
local chat_buffer = nil  -- Buffer variable to store the chat buffer
local reconnect_attempts = 0
local max_reconnect_attempts = 5

-- Forward declarations of functions to ensure correct order
local start_chat, end_chat, connect_or_listen, start_server, connect_to_self, setup_client, send_message, create_chat_buffer, broadcast_message, handle_disconnect, setup_server_client

-- Function to create a dedicated chat buffer for displaying messages.
function create_chat_buffer()
    -- Create a new buffer and set it up as a chat log
    chat_buffer = vim.api.nvim_create_buf(false, true) -- (listed, scratch buffer)
    vim.api.nvim_buf_set_option(chat_buffer, 'bufhidden', 'wipe') -- Auto-delete buffer when hidden
    vim.api.nvim_set_current_buf(chat_buffer)  -- Optionally switch to the buffer on creation
    vim.api.nvim_buf_set_name(chat_buffer, "Chat Log") -- Name the buffer for easier identification
    print("Chat buffer created.")
end

-- Function to start the chat, trying to connect as a client first, then starting a server if needed.
function start_chat()
    create_chat_buffer()  -- Ensure the chat buffer is created before connecting
    connect_or_listen()
end

-- Function to end the chat, close all connections, and stop the server.
function end_chat()
    if server then
        for _, client in ipairs(clients) do
            client:shutdown()
            client:close()
        end
        server:close()
        server = nil
        server_started = false
        clients = {}
    end
    if client_socket then
        client_socket:shutdown()
        client_socket:close()
        client_socket = nil
    end
    if chat_buffer then
        vim.api.nvim_buf_delete(chat_buffer, {force = true})  -- Close the chat buffer
        chat_buffer = nil
    end
    reconnect_attempts = 0
    print("Chat ended.")
end

-- Function to handle the initial connection attempt or server start.
function connect_or_listen()
    local client = uv.new_tcp()
    client:connect("127.0.0.1", 8080, function(err)
        if err then
            print("Failed to connect as client, starting server...")
            start_server()
            connect_to_self()
        else
            print("Connected to chat server.")
            client_socket = client
            setup_client(client_socket)
        end
    end)
end

-- Function to start the embedded Lua server within Neovim.
function start_server()
    server = uv.new_tcp()
    server:bind("127.0.0.1", 8080)
    server:listen(128, function(err)
        assert(not err, err)
        local client = uv.new_tcp()
        server:accept(client)
        table.insert(clients, client)
        setup_server_client(client)  -- Set up incoming data handler for the client
        print("New client connected.")
    end)
    server_started = true
    print("Chat server started.")
end

-- Function to connect Neovim to the server running within itself.
function connect_to_self()
    local client = uv.new_tcp()
    client:connect("127.0.0.1", 8080, function(err)
        if err then
            print("Failed to connect to self-hosted server.")
        else
            print("Connected to self-hosted server.")
            client_socket = client
            setup_client(client_socket)
        end
    end)
end

-- Function to set up the client, handling incoming data and disconnection.
function setup_client(client)
    client:read_start(function(err, chunk)
        if err then
            print("Read error:", err)
        elseif chunk then
            -- Split the chunk into individual lines safely and append them
            local lines = vim.split(chunk, '\n', { plain = true, trimempty = true })
            -- Use vim.schedule to safely update the buffer outside the loop callback.
            vim.schedule(function()
                if chat_buffer then
                    vim.api.nvim_buf_set_lines(chat_buffer, -1, -1, false, lines)
                end
            end)
        else
            -- Handle client disconnection.
            handle_disconnect(client)
        end
    end)
end

-- Function to set up a client connection to the server with incoming data handling.
function setup_server_client(client)
    client:read_start(function(err, chunk)
        if err then
            print("Read error:", err)
        elseif chunk then
            -- Broadcast the received message to all clients
            broadcast_message(chunk)
        else
            -- Handle client disconnection.
            handle_disconnect(client)
        end
    end)
end

-- Function to handle client disconnection and attempt reconnect or server start.
function handle_disconnect(client)
    print("Client disconnected.")
    client:shutdown()
    client:close()
    for i, c in ipairs(clients) do
        if c == client then
            table.remove(clients, i)
            break
        end
    end

    if client == client_socket then
        client_socket = nil
        reconnect_attempts = reconnect_attempts + 1
        if reconnect_attempts <= max_reconnect_attempts then
            print("Attempting to reconnect...")
            connect_or_listen()
        else
            print("Max reconnect attempts reached. Trying to become the new server...")
            start_server()
            connect_to_self()
        end
    end
end

-- Function to broadcast a message to all clients, including the sender.
function broadcast_message(message)
    for _, client in ipairs(clients) do
        client:write(message)
    end
end

-- Function to send a message to the server.
function send_message(msg)
    if client_socket then
        local username = os.getenv("USER") or "User"
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        -- Updated message format: timestamp [username:pid] message text
        local message = string.format("%s [%s:%d] %s\n", timestamp, username, uv.os_getpid(), msg)

        -- Split the message into lines to avoid newline issues
        local lines = vim.split(message, '\n', { plain = true, trimempty = true })

        -- Display the message locally
        -- vim.schedule(function()
        --     if chat_buffer then
        --         vim.api.nvim_buf_set_lines(chat_buffer, -1, -1, false, lines)
        --     end
        -- end)

        client_socket:write(message)
    else
        print("Not connected to any chat server.")
    end
end

-- Define Neovim commands using nvim_command for compatibility.
vim.api.nvim_command('command! ChatStart lua require("chat").start_chat()')
vim.api.nvim_command('command! ChatEnd lua require("chat").end_chat()')
vim.api.nvim_command('command! -nargs=1 ChatMsg lua require("chat").send_message(<q-args>)')

-- Return a module for loading in init.lua
return {
    start_chat = start_chat,
    end_chat = end_chat,
    send_message = send_message,
}
