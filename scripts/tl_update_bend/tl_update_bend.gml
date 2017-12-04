/// tl_update_bend([force])
/// @arg [force]

var force;
if (argument_count > 0)
	force = argument[0]
else
	force = false
	
// No change
if (!force && bend_angle_last = value_inherit[e_value.BEND_ANGLE] && bend_model_part_last = model_part)
	return false

// Not a body part or no in-between mesh needed
if (type != e_tl_type.BODYPART || value_inherit[e_value.BEND_ANGLE] = 0)
	return false
	
// Invalid part, no bending or no shapes
if (model_part = null || model_part.bend_part = null || model_part.shape_list = null)
	return false
	
bend_angle_last = value_inherit[e_value.BEND_ANGLE]
bend_model_part_last = model_part

tl_update_model_shape_vbuffer_map()

return true