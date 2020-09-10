/// new_animation(name, [value])
/// @arg name
/// @arg [value]

var microanimation = new(obj_micro_animation)
ds_map_add(microanis, argument[0], microanimation)

if (argument_count > 1)
{
	with (microanimation)
	{
		value = argument[1]
		value_ani = argument[1]
		value_ani_ease = argument[1]
	}
}

microanimation.spd = 1

return microanimation