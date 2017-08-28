/// project_load_find_save_ids()
/// @desc Updates the references to objects within the project.

// Set background references
if (background_loaded)
{
	background_image = save_id_find(background_image)
	if (background_image)
		background_image.count++
	background_sky_sun_tex = save_id_find(background_sky_sun_tex)
	background_sky_sun_tex.count++
	background_sky_moon_tex = save_id_find(background_sky_moon_tex)
	background_sky_moon_tex.count++
	background_sky_clouds_tex = save_id_find(background_sky_clouds_tex)
	background_sky_clouds_tex.count++
	background_ground_tex = save_id_find(background_ground_tex)
	background_ground_tex.count++
}

// Set template references
with (obj_template)
{
    if (!loaded)
        continue
		
    skin = save_id_find(skin)
    item_tex = save_id_find(item_tex)
    block_tex = save_id_find(block_tex)
    scenery = save_id_find(scenery)
    shape_tex = save_id_find(shape_tex)
    text_font = save_id_find(text_font)
	
	// Update counters if not loaded via the workbench particle preview
    if (temp_creator != app.bench_settings)
	{
        if (skin != null)
            skin.count++
		
        if (item_tex != null)
            item_tex.count++
		
        if (block_tex != null)
            block_tex.count++
		
        if (scenery != null)
            scenery.count++
		
        if (shape_tex != null && shape_tex.type != "camera")
            shape_tex.count++
		
        if (text_font != null)
            text_font.count++
    }
}

// Set particle type references
with (obj_particle_type)
{
    if (!loaded)
        continue
    
    temp = save_id_find(temp)
    sprite_tex = save_id_find(sprite_tex)
    ptype_update_sprite_vbuffers()
	
	// Update counters if not loaded via the workbench particle preview
    if (temp_creator != app.bench_settings)
        sprite_tex.count++
}

// Set timeline references
with (obj_timeline)
{
    if (!loaded)
        continue
		
    temp = save_id_find(temp)
		
	// Set part list
	if (part_list != null)
	{
		for (var i = 0; i < ds_list_size(part_list); i++)
		{
			part_list[|i] = save_id_find(part_list[|i])
			part_list[|i].part_of = id
		}
	}
	
	// Set parent
	parent = save_id_find(parent)
	parent.tree_array[parent_tree_index] = id
}

// Set keyframe references
with (obj_keyframe)
{
    if (!loaded)
        continue
	
    value[e_value.ATTRACTOR] = save_id_find(value[e_value.ATTRACTOR])
    value[e_value.TEXTURE_OBJ] = save_id_find(value[e_value.TEXTURE_OBJ])
    value[e_value.SOUND_OBJ] = save_id_find(value[e_value.SOUND_OBJ])
    if (value[e_value.SOUND_OBJ] != null)
        value[e_value.SOUND_OBJ].count++
}

// Add to root tree
for (var i = 0; i < array_length_1d(tree_array); i++)
	if (tree_array[i] > 0)
		ds_list_add(tree_list, tree_array[i])
		
// Add to timeline trees
with (obj_timeline)
	for (var i = 0; i < array_length_1d(tree_array); i++)
		if (tree_array[i] > 0)
			ds_list_add(tree_list, tree_array[i])

// Set pre-1.0.0 hide value
if (load_format < e_project.FORMAT_100_DEBUG)
    for (var t = 0; t < ds_list_size(tree_list); t++)
        with (tree_list[|t])
            tl_update_hide()