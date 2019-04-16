--
--
--

local utils = require("torchcraft.utils")

local tools = {}

function tools.this_is()
    print("this is only a test")
end

function tools.get_closest(position, units)
    local min_d = 1E30
    local closest_uid = nil
    for uid, ut in pairs(units) do
        local tmp_d = utils.distance(position, ut['position'])
        if tmp_d < min_d then
            min_d = tmp_d
            closest_uid = uid
        end
    end
    return closest_uid
end

return tools
