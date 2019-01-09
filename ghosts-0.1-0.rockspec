package = "ghosts"
version = "0.1-0"

source = {
  url = "git://github.com/spacebeam/ghosts",
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
    ['ghosts.macro'] = "include/lua/macro.lua",
    ['ghosts.meta'] = "include/lua/meta.lua",
    ['ghosts.micro'] = "include/lua/micro.lua",
    ['ghosts.tools'] = "include/lua/tools.lua"
  }
}
