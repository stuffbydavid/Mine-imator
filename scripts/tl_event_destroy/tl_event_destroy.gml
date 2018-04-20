/// tl_event_destroy()
/// @desc Destroy event of timelines.

// Remove from render list
ds_list_delete_value(render_list, id)

// Remove from parent
ds_list_delete_value(parent.tree_list, id)
if (part_of != null)
	ds_list_delete_value(part_of.part_list, id)

// Clear tree
while (ds_list_size(tree_list) > 0)
	with (tree_list[|0])
		instance_destroy()
		
ds_list_destroy(tree_list)

if (part_list != null)
	ds_list_destroy(part_list)

// Clear references
if (part_of = null && temp != null)
	temp.count--
	
with (obj_template)
	if (shape_tex = other.id)
		shape_tex = 0

with (obj_timeline)
{
	if (value[e_value.TEXTURE_OBJ] = other.id)
		value[e_value.TEXTURE_OBJ] = null
		
	if (value[e_value.ATTRACTOR] = other.id)
		value[e_value.ATTRACTOR] = null
		
	if (value_inherit[e_value.ATTRACTOR] = other.id)
		update_matrix = true
		
	if (value_inherit[e_value.TEXTURE_OBJ] = other.id) 
		update_matrix = true
}

with (obj_keyframe)
{
	if (value[e_value.ATTRACTOR] = other.id)
		value[e_value.ATTRACTOR] = null
		
	if (value[e_value.TEXTURE_OBJ] = other.id)
		value[e_value.TEXTURE_OBJ] = null
}

if (app.timeline_camera = id)
	app.timeline_camera = null

while (ds_list_size(keyframe_list))
	with (keyframe_list[|0])
		instance_destroy()
	
ds_list_destroy(keyframe_list)

with (obj_particle)
	if (creator = other.id)
		instance_destroy()

if (particle_list)
	ds_list_destroy(particle_list)
	
if (temp = id)
{
	if (type = e_tl_type.SPECIAL_BLOCK)
	{
		if (model_texture_name_map != null)	
			ds_map_destroy(model_texture_name_map)
	
		if (model_hide_list != null)
			ds_list_destroy(model_hide_list)
	}
	else if (type = e_tl_type.BLOCK)
		block_vbuffer_destroy()
}

if (model_shape_vbuffer_map != null)
{
	var key = ds_map_find_first(model_shape_vbuffer_map);
	while (!is_undefined(key))
	{
		if (instance_exists(key) && key.vbuffer_default != model_shape_vbuffer_map[?key]) // Don't clear default buffers
			vbuffer_destroy(model_shape_vbuffer_map[?key])
		key = ds_map_find_next(model_shape_vbuffer_map, key)
	}
	ds_map_destroy(model_shape_vbuffer_map)
}

if (model_shape_alpha_map != null)
	ds_map_destroy(model_shape_alpha_map)

if (surface_exists(cam_surf))
	surface_free(cam_surf)
	
if (surface_exists(cam_surf_tmp))
	surface_free(cam_surf_tmp)
