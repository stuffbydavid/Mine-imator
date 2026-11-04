function value_animation() constructor
{
	self.init(0)
	
	static init = function(val)
	{
		value = val
		value_prev = val
		value_ani_linear = val
		value_ani_ease = val
		
		value_base = val
		value_offset = val
		value_ani_offset = val
		value_ani_offset_ease = val
		
		value_goal = val
	}
	
	static update = function(spd)
	{
		// Don't update
		if (value_ani_linear = value)
			return 0
		
		if (app.setting_reduced_motion)
		{
			value_ani_linear = value
			value_ani_ease = value
			
			value_base = value_ani_linear
			value_prev = value
			
			value_offset = 0.0
			value_ani_offset = 0.0
		}
		else
		{
			if (value != value_prev)
			{
				value_base = value_ani_linear
				value_prev = value
				value_ani_offset = 0.0
				
				value_goal = value
				
				if (!value)
					value_offset = -value_base
				else
					value_offset = 1.0 - value_base
			}
			
			value_ani_offset += spd * delta
			value_ani_offset_ease = ease("easeoutcirc", value_ani_offset)
			value_ani_offset = clamp(value_ani_offset, 0, 1)
			
			value_ani_linear = value_base + (value_offset * value_ani_offset)
			value_ani_linear = clamp(value_ani_linear, 0, 1)
			
			value_ani_ease = value_base + (value_offset * value_ani_offset_ease)
			value_ani_ease = clamp(value_ani_ease, 0, 1)
		}
	}
}
