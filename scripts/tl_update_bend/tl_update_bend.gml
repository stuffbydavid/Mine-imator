/// tl_update_bend([force])
/// @arg [force]

var force = false;
if (argument_count > 0)
	force = argument[0]
	
// No change
if (!force && bend_angle_last = value_inherit[e_value.BEND_ANGLE] && bend_model_part_last = model_part)
	return 0
	
// Free old meshes
if (model_shape_vbuffer_map != null)
{
	var key = ds_map_find_first(model_shape_vbuffer_map);
	while (!is_undefined(key))
	{
		vbuffer_destroy(model_shape_vbuffer_map[?key])
		key = ds_map_find_next(model_shape_vbuffer_map, key)
	}
	ds_map_clear(model_shape_vbuffer_map)
}

// Not a body part or no in-between mesh needed
if (type != e_tl_type.BODYPART || value_inherit[e_value.BEND_ANGLE] = 0)
	return 0
	
// Invalid part, no bending or no shapes
if (model_part = null || model_part.bend_part = null || model_part.shape_list = null)
	return 0
	
bend_angle_last = value_inherit[e_value.BEND_ANGLE]
bend_model_part_last = model_part

if (model_shape_vbuffer_map = null)
	model_shape_vbuffer_map = ds_map_create()

// Re-generate meshes of each bent shape in this part
for (var s = 0; s < ds_list_size(model_part.shape_list); s++)
{
	with (model_part.shape_list[|s])
	{
		if (type = "block")
			other.model_shape_vbuffer_map[?id] = model_shape_generate_block(other.bend_angle_last)
		else
			other.model_shape_vbuffer_map[?id] = model_shape_generate_plane(null, other.bend_angle_last)
	}
}