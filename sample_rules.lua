-- just as a reminder {black = 0, pink = 1, orange = 2, green = 3, blue = 4}

local rules = {}
rules.list = {
   {
      rule_type = 'pickup',
      structure = {
         {
            index = vector3(0, 0, 0),
            type = "parallel_light"
         },
      },
      target = {
         reference_index = vector3(0, 0, 0),
         offset_from_reference = vector3(0, 0, 0),
      },
   },
   {
      rule_type = 'pickup',
      structure = {
         {
            index = vector3(0, 0, 0),
            type = 0
         },
      },
      target = {
         reference_index = vector3(0, 0, 0),
         offset_from_reference = vector3(0, 0, 0),
      },
   },

   {
      rule_type = 'place',
      structure = {
         {
            index = vector3(0, 0, 0),
            type = "perpendicular_light"
         },
      },
      target = {
         reference_index = vector3(0, 0, 0),
         offset_from_reference = vector3(1, 0, 0),
         type = 3
      },
   }
}
rules.selection_method = 'nearest_win'
return rules
