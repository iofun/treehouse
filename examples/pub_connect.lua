#!/usr/bin/env luajit

-- Turn it up, turn it up, turn it up, fucked up loud

-- Connect PUB socket to tcp://localhost:8135
-- Publishes random update messages on logging topic

require "sys"
require "zhelpers"

local zmq = require "lzmq"
local context = zmq.context()
local publisher, err = context:socket{zmq.PUB, connect = "tcp://localhost:8135"}
zassert(publisher, err)

while true do
  -- Get values that will fool the boss
  local zipcode     = randof(100000)
  local temperature = randof(215) - 80
  local relhumidity = randof(50) + 10

  -- Send message to all subscribers
  local message = sprintf("logging %05d %d %d", zipcode, temperature, relhumidity)
  publisher:send(message)
  sys.sleep(0.1)
  print(message)
end