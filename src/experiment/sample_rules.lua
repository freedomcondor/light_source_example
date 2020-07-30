-- just as a reminder {black = 0, pink = 1, orange = 2, green = 3, blue = 4}

local rules = {}
rules.list = {
   {
      rule_type = 'pickup',
      safe_zone = {up_margin = 0.3},
      external_condition = "lights_in_left_and_right",
      structure = {
         {
            index = vector3(0, 0, 0),
         },
      },
      target = {
         reference_index = vector3(0, 0, 0),
         offset_from_reference = vector3(0, 0, 0),
      },
   },
}
rules.selection_method = 'nearest_win'
return rules
