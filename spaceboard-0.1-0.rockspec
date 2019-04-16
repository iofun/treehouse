package = "spaceboard"
version = "0.1-0"

source = {
  url = "git://github.com/spacebeam/spaceboard",
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
    ['spaceboard.macro'] = "include/macro.lua",
    ['spaceboard.meta'] = "include/meta.lua",
    ['spaceboard.micro'] = "include/micro.lua",
    ['spaceboard.tools'] = "include/tools.lua"
  }
}
