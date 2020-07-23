-- create an example scenario for Majd

-- all the builderbot lua library is installed into this .luac in your /usr/local when installing argos-srocs
assert(loadfile("/usr/local/include/argos3/plugins/robots/builderbot/lua_library.luac"))()


local rules
--local data
local behavior

local custom_light_type
-- in process_leds, user can custom the block type by providing a custom type function
-- by default the type of a block is 0 1 2 3 4 for black, pink, orange, green, blue
-- the following custom_block_type function defines a type 5 block, whose up face is pink and front face is orange
-- this function is feed to process_leds(), see the beginning of step()
-- process_leds() will first calculate default color 01234, and then run the custom function to overwrite the type
local function custom_block_type(block)
   if block.tags.up ~= nil and block.tags.up.type == 1 and 
      block.tags.front ~= nil and block.tags.front.type == 2 then
      return 5
   end
end

-- this function factory creates a custom type function, which checks the light condition,
--  and tag the block with type = "perpendicular-light" or "parallel-light"
local function create_light_condition_custom_block_type_definer(data)
   return function(block)
      if block.type == 0 then return end
      if data.light == "Y" then
         return "perpendicular_light"
      elseif data.light == "X" then
         return "parallel_light"
      end
   end
end

--- argos functions
function init()  
   -- logger for print information
      -- use robot.logger:log_info("hello world") to print hello world in terminal
      --  table = {aa = 3, bb = "hi"}
      -- use robot.logger:log_info(a) to print a table in terminal
      -- use robot.logger:log_warn("I am a warnning") to print a warning message
   robot.logger:register_module("controller")
   robot.logger:set_verbosity(2) 

   -- enable the robot's camera system  
   robot.camera_system.enable()
   reset()
end

function reset()
   rules = require("sample_rules")
   -- data the basic data field for builderbot library
   data = {
      target = {},
      blocks = {},
      obstacles = {},
   }
   custom_light_type = create_light_condition_custom_block_type_definer(data)

   behavior = robot.utils.behavior_tree.create {
      type = "sequence*",
      children = {
         -- pick_up_behavior includes search - approach - pickup
         robot.nodes.create_pick_up_behavior_node(data, rules),
         -- place_behavior includes search - approach - place
         robot.nodes.create_place_behavior_node(data, rules),
      }
   }
end

function step()
   -- light condition
   if robot.id == "builderbot1" then data.light = "X" end
   if robot.id == "builderbot2" then data.light = "Y" end

   -- preprocessing
   robot.api.process_blocks(data.blocks)
   robot.api.process_leds(data.blocks, custom_light_type)
   robot.api.process_obstacles(data.obstacles, data.blocks)

   -- tick behavior tree
   behavior()
end

function destroy()
   -- disable the robot's camera system
   robot.camera_system.disable()
end
