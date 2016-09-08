#!/usr/bin/env luajit

-- Turn it up, turn it up, turn it up, fucked up loud

-- Connect PUB socket to tcp://localhost:8135
-- Publishes random update messages on logging topic

require "sys"
require "zhelpers"

local zmq = require "lzmq"
local socket = require "socket"  -- gettime() has higher precision than os.time()
local uuid = require "uuid"
local json = require "cjson"

local struct = {}

-- time in seconds, relative to the origin of the universe. 
struct['timestamp'] = socket.gettime()

-- see also example at uuid.seed()
uuid.randomseed(socket.gettime()*10000)
struct['uuid'] = uuid()

local context = zmq.context()
local publisher, err = context:socket{zmq.PUB, connect = "tcp://localhost:8135"}
zassert(publisher, err)

while true do
  struct['timestamp'] = socket.gettime()
  -- Send message to the subscriber
  local message = "heartbeat " .. json.encode(struct)
  publisher:send(message)
  sys.sleep(0.500)
end