#!/usr/bin/env luajit
-- Connect PUB socket to tcp://localhost:5813
-- Publish timestamped uuid's on heartbeat topic
require "sys"
require "zhelpers"
-- require lzmq module as local variable zmq
local zmq = require "lzmq"
-- socket.gettime() has higher precision than os.time()
local socket = require "socket"
local uuid = require "uuid"
local json = require "cjson"
-- see also example at uuid.seed()
uuid.randomseed(socket.gettime()*10000)
-- get ZeroMQ context
local context = zmq.context()
-- set ZeroMQ PUB socket
local publisher, err = context:socket{zmq.PUB, connect = "tcp://localhost:5813"}
zassert(publisher, err)
-- struct message
local message = {}
-- connect process loop
while true do
  -- time in seconds, relative to the origin of the universe. 
  message['timestamp'] = socket.gettime()
  -- set message uuid
  message['uuid'] = uuid()
  -- Send message to the subscriber
  message = "heartbeat " .. json.encode(message)
  -- socket send message
  publisher:send(message)
  -- process sleep
  sys.sleep(0.500)
end