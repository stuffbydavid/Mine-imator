/// tl_event_destroy()
/// @desc Destroy event of timelines.

// Remove from render list
ds_list_delete_value(render_list, id)

// Remove from parent
tl_parent_remove()

// Clear tree
while (tree_amount > 0)
    with (tree[0])
        instance_destroy()

// Clear references
if (part_of)
    part_of.part[bodypart] = null
else if (temp)
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

for (var k = 0; k < keyframe_amount; k++)
    with (keyframe[k])
        instance_destroy()

with (obj_particle)
    if (creator = other.id)
        instance_destroy()

if (particles)
    ds_list_destroy(particles)
    
if (bend_vbuffer)
    vbuffer_destroy(bend_vbuffer)

if (surface_exists(cam_surf))
    surface_free(cam_surf)
	
if (surface_exists(cam_surf_tmp))
    surface_free(cam_surf_tmp)
