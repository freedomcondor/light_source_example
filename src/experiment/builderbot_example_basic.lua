assert(loadfile("/usr/local/include/argos3/plugins/robots/builderbot/lua_library.luac"))()


local rules
--local data
local behavior

robot.nodes.create_wall_following_node = require("wall_following")

--- argos functions
function init()  
   robot.logger:register_module("controller")
   robot.logger:set_verbosity(2) 

   -- enable the robot's camera system  
   robot.camera_system.enable()
   reset()
end

function reset()
   -- data the basic data field for builderbot library
   data = {
      target = {},
      blocks = {},
      obstacles = {},
      sensor_condition = nil,
   }

   behavior = robot.utils.behavior_tree.create {
      type = "sequence*",
      children = {
         robot.nodes.create_wall_following_node(data, rules),
         function() robot.api.move.with_velocity(0,0) return true end,
      }
   }
end

function step()
   -- preprocessing
   robot.api.process_blocks(data.blocks)
   robot.api.process_leds(data.blocks)
   robot.api.process_obstacles(data.obstacles, data.blocks)

   -- tick behavior tree
   --behavior()
end

function destroy()
   -- disable the robot's camera system
   robot.camera_system.disable()
end
