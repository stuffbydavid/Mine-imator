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
ds_list_destroy(part_list)

// Clear references
if (part_of = null && temp != null)
	temp.count--
	
with (obj_template)
	if (shape_tex = other.id)
		shape_tex = 0

with (obj_timeline)
{
	if (value[TEXTUREOBJ] = other.id)
		value[TEXTUREOBJ] = null
		
	if (value[ATTRACTOR] = other.id)
		value[ATTRACTOR] = app
		
	if (value_inherit[ATTRACTOR] = other.id)
		update_matrix = true
		
	if (value_inherit[TEXTUREOBJ] = other.id) 
		update_matrix = true
}

with (obj_keyframe)
{
	if (value[ATTRACTOR] = other.id)
		value[ATTRACTOR] = app
		
	if (value[TEXTUREOBJ] = other.id)
		value[TEXTUREOBJ] = null
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
	
if (bend_vbuffer)
	vbuffer_destroy(bend_vbuffer)

if (surface_exists(cam_surf))
	surface_free(cam_surf)
	
if (surface_exists(cam_surf_tmp))
	surface_free(cam_surf_tmp)
