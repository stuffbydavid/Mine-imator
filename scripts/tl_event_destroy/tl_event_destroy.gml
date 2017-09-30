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
	
if (bend_vbuffer_list != null)
{
	for (var s = 0; s < ds_list_size(bend_vbuffer_list); s++)
		if (bend_vbuffer_list[|s] != null)
			vbuffer_destroy(bend_vbuffer_list[|s])
	ds_list_destroy(bend_vbuffer_list)
}

if (surface_exists(cam_surf))
	surface_free(cam_surf)
	
if (surface_exists(cam_surf_tmp))
	surface_free(cam_surf_tmp)
