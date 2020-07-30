robot.logger:register_module("wall_following")

local check_manipulator_height = 
   { type = "selector", children = {
      -- if lift reach position(0.07), return true, stop selector
      function()
         if (robot.lift_system.position >
             robot.api.constants.lift_system_upper_limit - 
             robot.api.parameters.lift_system_position_tolerance) and
            (robot.lift_system.position <
             robot.api.constants.lift_system_upper_limit +
             robot.api.parameters.lift_system_position_tolerance) then
               return false, true
         else
               return false, false
         end
      end,
      -- set position(0.07)
      function()
         robot.lift_system.set_position(robot.api.constants.lift_system_upper_limit)
         return true -- always running
      end,
   }}

return function(data, rule_node)
   return 
   { type = "sequence", children = {
      -- check height each time
      check_manipulator_height,
      -- manipulator in position, wall following
      { type = "sequence*", children = {
         -- approach wall
         function()
            local distance_threshold = robot.api.parameters.proximity_detect_tolerance -- 0.03
            if robot.rangefinders['1'].proximity < distance_threshold or
               robot.rangefinders['12'].proximity < distance_threshold then
               robot.api.move.with_velocity(0, 0)
               robot.logger:log_info("obstacle in front")
               return false, true
            else
               robot.api.move.with_bearing(robot.api.parameters.default_speed, 0)
               return true
            end
         end,
         -- turn to face the wall
         function()
            local distance_tolerance = 0.01
            local error_tolerance = 0.0005
            local distance = (robot.rangefinders['1'].proximity +
                              robot.rangefinders['12'].proximity) / 2
            local error = robot.rangefinders['1'].proximity -
                          robot.rangefinders['12'].proximity
            if math.abs(error) < error_tolerance and
               distance < distance_tolerance + error_tolerance and
               distance > distance_tolerance - error_tolerance then

               robot.api.move.with_bearing(0, 0)
               robot.logger:log_info("facing obstacle")
               return false, true
            elseif math.abs(error) >= error_tolerance then
               local speed = robot.api.parameters.default_turn_speed 
               if error < 0 then speed = -speed end
               robot.api.move.with_bearing(0, speed)
               return true
            elseif distance <= distance_tolerance - error_tolerance then
               robot.api.move.with_bearing(-robot.api.parameters.default_speed, 0)
               return true
            elseif distance >= distance_tolerance + error_tolerance then
               robot.api.move.with_bearing(robot.api.parameters.default_speed, 0)
               return true
            end
         end,
         -- backup with tilt
         robot.nodes.create_timer_node(
            function() 
               robot.logger:log_info("back up")
               robot.api.move.with_bearing(-robot.api.parameters.default_speed, 
                                           -robot.api.parameters.default_turn_speed)
               return 0.040 / robot.api.parameters.default_speed
            end
         ),
         -- backup
         robot.nodes.create_timer_node(
            function() 
               robot.api.move.with_bearing(-robot.api.parameters.default_speed, 0)
               return 0.020 / robot.api.parameters.default_speed
            end
         ),
         -- turn 210 or align with wall
         robot.nodes.create_timer_node(
            function() 
               robot.api.move.with_bearing(0, robot.api.parameters.default_turn_speed)
               return 210 / robot.api.parameters.default_turn_speed
            end,
            function()
               distance_threshold = 0.04
               if robot.rangefinders['3'].proximity < distance_threshold and
                  robot.rangefinders['4'].proximity < distance_threshold then
                  robot.api.move.with_bearing(0, 0)
                  robot.logger:log_info("align with wall")
                  return false, true
               else
                  robot.api.move.with_bearing(0, robot.api.parameters.default_turn_speed)
                  return true
               end
            end
         ),
         -- follow the wall
         { type = "selector", children = {
            -- check light condition
            function()
               local front = robot.rangefinders['1'].illuminance +
                             robot.rangefinders['12'].illuminance
               local back = robot.rangefinders['6'].illuminance +
                            robot.rangefinders['7'].illuminance
               local error = math.abs(front - back)
               local tolerance = 0.002
               if error < tolerance then
                  robot.logger:log_info("center of the wall")
                  return false, true
               else
                  return false, false
               end
            end,
            -- light condition not good, keep following the wall
            { type = "selector", children = {
               -- if nothing in front, forward along the wall
               { type = "sequence", children = {
                  -- something in front? return false to end sequence, if yes.
                  function()
                     local distance_threshold = robot.api.parameters.proximity_detect_tolerance -- 0.03
                     if robot.rangefinders['1'].proximity < distance_threshold or
                        robot.rangefinders['12'].proximity < distance_threshold then
                           robot.logger:log_info("something in front")
                           return false, false
                     else
                           return false, true
                     end
                  end,
                  -- clear to move forward
                  function()
                     local distance = (robot.rangefinders['3'].proximity +
                                       robot.rangefinders['4'].proximity) / 2
                     local rangefinder_error = robot.rangefinders['3'].proximity -
                                               robot.rangefinders['4'].proximity
                     local tolerance = 0.002
                     local required_dist = 0.04

                     local dis_error = distance - required_dist
                     local adjust = -(dis_error + rangefinder_error * 5) * 10 *
                                    robot.api.parameters.default_turn_speed
                     if dis_error > tolerance then
                        robot.api.move.with_bearing(robot.api.parameters.default_speed, adjust)
                     elseif dis_error < -tolerance then
                        robot.api.move.with_bearing(robot.api.parameters.default_speed, adjust)
                     else
                        robot.api.move.with_bearing(robot.api.parameters.default_speed, 0)
                     end
                     return true
                  end,
               }},
               -- detect something in front, turn
               -- don't need to do anything, just approach wall again will do
               function() return false, false end,
            }},
         }},
         -- turn left and move to center
         robot.nodes.create_timer_node(
            function() 
               robot.api.move.with_bearing(-robot.api.parameters.default_speed, 0)
               return 0.03 / robot.api.parameters.default_speed
            end
         ),
         robot.nodes.create_timer_node(
            function() 
               robot.api.move.with_bearing(robot.api.parameters.default_speed, robot.api.parameters.default_turn_speed)
               return 90 / robot.api.parameters.default_turn_speed
            end
         ),
         -- move forward and check rules
         function()
            robot.api.move.with_bearing(robot.api.parameters.default_speed, 0)
            return false, true 
         end,
         -- check front and rules
         { type = "sequence", children = {
            -- if something is in front, turn 180, return false and restart everything
            { type = "selector*", children = {
               function()
                  local distance_threshold = robot.api.parameters.proximity_detect_tolerance -- 0.03
                  if robot.rangefinders['1'].proximity < distance_threshold or
                     robot.rangefinders['2'].proximity < distance_threshold or
                     robot.rangefinders['12'].proximity < distance_threshold or
                     robot.rangefinders['11'].proximity < distance_threshold then
                     return false, false
                  else
                     return false, true
                  end
               end,
               { type = "sequence*", children = {
                  -- backup
                  robot.nodes.create_timer_node(
                     function() 
                        robot.api.move.with_bearing(-robot.api.parameters.default_speed, 0)
                        return 0.05 / robot.api.parameters.default_speed
                     end
                  ),
                  --turn 180
                  robot.nodes.create_timer_node(
                     function() 
                        robot.api.move.with_bearing(0, robot.api.parameters.default_turn_speed)
                        return 180 / robot.api.parameters.default_turn_speed
                     end
                  ),
                  -- return false
                  function() return false, false end,
               }},
            }},
            -- everything ok. clear to check rules
            { type = "selector", children = {
               --function() robot.logger:log_info("checking") return false, false end,
               rule_node, -- return true or false
               --function() robot.logger:log_info("checking false") return false, false end,
               function() return true end, -- if rule-node doesn't find a match, return running
            }},
         }}
      }},
   }}
end