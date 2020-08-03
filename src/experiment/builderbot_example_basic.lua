assert(loadfile("/usr/local/include/argos3/plugins/robots/builderbot/lua_library.luac"))()


local rules = require("sample_rules")
--local data
local behavior

--robot.nodes.create_wall_following_node = require("wall_following")
robot.nodes.create_search_block_node = require("wall_following")
local function custom_external_condition()
   local front_and_back = robot.rangefinders['1'].illuminance +
                          robot.rangefinders['12'].illuminance +
                          robot.rangefinders['6'].illuminance +
                          robot.rangefinders['7'].illuminance

   local left_and_right = robot.rangefinders['3'].illuminance +
                          robot.rangefinders['4'].illuminance +
                          robot.rangefinders['9'].illuminance +
                          robot.rangefinders['10'].illuminance
   local error = front_and_back - left_and_right
   if error > 0 then 
      robot.utils.draw.arrow("yellow", vector3(0,0,0.02), vector3(0.2, 0, 0.02))
      robot.utils.draw.arrow("yellow", vector3(0,0,0.02), vector3(-0.2, 0, 0.02))
      return "lights_in_front_and_back"
   else
      robot.utils.draw.arrow("yellow", vector3(0,0,0.02), vector3(0, 0.2, 0.02))
      robot.utils.draw.arrow("yellow", vector3(0,0,0.02), vector3(0, -0.2, 0.02))
      return "lights_in_left_and_right"
   end
end

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
      external_condition = nil,
   }

   behavior = robot.utils.behavior_tree.create {
      type = "sequence*",
      children = {
         robot.nodes.create_search_block_node(data, 
            robot.nodes.create_process_rules_node(data, rules, "pickup")
         ),
         robot.nodes.create_curved_approach_block_node(data, 0.20),
         robot.nodes.create_pick_up_block_node(data, 0.20),
         function() robot.api.move.with_velocity(0,0) return true end,
      }
   }
end

function step()
   -- preprocessing
   robot.api.process_blocks(data.blocks)
   robot.api.process_leds(data.blocks)
   robot.api.process_obstacles(data.obstacles, data.blocks)
   data.external_condition = custom_external_condition()

   -- tick behavior tree
   behavior()
end

function destroy()
   -- disable the robot's camera system
   robot.camera_system.disable()
end
