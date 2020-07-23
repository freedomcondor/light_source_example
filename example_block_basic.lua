-- just as a reminder {black = 0, pink = 1, orange = 2, green = 3, blue = 4}

function init()
   reset()
end

function step()
end

function reset()
   robot.directional_leds.set_all_colors("blue")
   if robot.id == "block3" then
      robot.directional_leds.set_all_colors("black")
   end
end

function destroy()
end
