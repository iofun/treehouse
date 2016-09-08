#!/usr/bin/env luajit

-- Turn it up, turn it up, turn it up, fucked up loud

local turbo = require "turbo"
local lyaml = require "lyaml"
local argparse = require "argparse"

local parser = argparse("http_server.lua", "handles HTTP protocol requests")
    parser:option("-c --config", "configuration file.", "treehouse.conf")

local args = parser:parse()

-- join the treehouse, with moonlight.

function get_options(conf_file)
    local file = io.open(conf_file, "r")
    local content = file:read("*all")
    file:close()
    local options = lyaml.load(content)
    return options
end

local options = get_options(args['config'])

-- Handler of http protocol requests
local MoonHandler = class("MoonHandler", turbo.web.RequestHandler)

function MoonHandler:post()
    -- get a table from the raw json data
    local data = self:get_json(true)
    -- this is the fucking command and currently a fucking example!
    -- ... pretty please feel free to change it and stuff, thx!
    --local command = "turnadmin -a -e 'host=" .. options['dbhost'] .. 
    --                " dbname=turndb user=postgres password= ' -u " .. data['username'] .. 
    --                " -r " .. options['domain'] .. " -p " .. data['password']

    -- intended to be linux w command
    local command = "w" 
    os.execute(command)
end

local application = turbo.web.Application:new({
    {"/moon/", MoonHandler}
})

application:listen(options['dbport'])
turbo.ioloop.instance():start()