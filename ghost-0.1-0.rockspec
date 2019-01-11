package = "ghost"
version = "0.1-0"

source = {
  url = "git://github.com/spacebeam/ghost",
  tag = "0.1.0",
}

description = {
  summary = "Spawn over time and grow into other units",
  detailed = "Spawn multi-dimensional nodes of daemons — all operations run using the pkg command.",
  homepage = "https://spacebeam.io",
  license = "AGPL 3"
}

dependencies = {
  "lua == 5.1",
  "argparse",
  "luasocket",
  "uuid"
}

build = {
  type = 'builtin',
  modules = {
    ['ghost.macro'] = "include/lua/macro.lua",
    ['ghost.meta'] = "include/lua/meta.lua",
    ['ghost.micro'] = "include/lua/micro.lua",
    ['ghost.tools'] = "include/lua/tools.lua"
  }
}
