/// tl_update_bend([force])
/// @arg [force]

var force = false;
if (argument_count > 0)
	force = argument[0]
	
// Not a body part or no in-between mesh needed
if (type != e_tl_type.BODYPART || value_inherit[e_value.BEND_ANGLE] = 0)
	return 0
	
// Invalid part, no bending or no shapes
if (model_part = null || model_part.bend_part = null || model_part.shape_list = null)
	return 0
	
// No change
if (!force && bend_angle_last = value_inherit[e_value.BEND_ANGLE] && bend_model_part_last = model_part)
	return 0
	
bend_angle_last = value_inherit[e_value.BEND_ANGLE]
bend_model_part_last = model_part

// Free old
if (bend_vbuffer_list != null)
{
	for (var s = 0; s < ds_list_size(bend_vbuffer_list); s++)
		if (bend_vbuffer_list[|s] != null)
			vbuffer_destroy(bend_vbuffer_list[|s])
	ds_list_clear(bend_vbuffer_list)
}
else
	bend_vbuffer_list = ds_list_create()

// Create meshes of each shape in this part
for (var s = 0; s < ds_list_size(model_part.shape_list); s++)
	ds_list_add(bend_vbuffer_list, model_shape_get_bend_vbuffer(model_part.shape_list[|s], value_inherit[e_value.BEND_ANGLE], round_bending, model_plane_alpha_map))