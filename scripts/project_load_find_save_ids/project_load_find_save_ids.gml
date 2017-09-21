/// project_load_find_save_ids()
/// @desc Updates the references to objects within the project.

// Look for legacy (numeric) or duplicate save IDs and create new if necessary
var key = ds_map_find_first(save_id_map);
while (!is_undefined(key))
{
	if (save_id_map[?key] != "root" && save_id_map[?key] != "default") // Skip removed objects
	{
		var obj = save_id_find(save_id_map[?key]);
		if (is_real(save_id_map[?key]) || obj != null)
			save_id_map[?key] = save_id_create()
	}
	key = ds_map_find_next(save_id_map, key)
}

save_id_map[? null] = null
save_id_map[?"root"] = "root"
save_id_map[?"default"] = "default"

// Set resource IDs
with (obj_resource)
	if (loaded && !is_undefined(save_id_map[?load_id]))
		save_id = save_id_map[?load_id]

// Set background references
if (background_loaded)
{
	background_image = save_id_find(save_id_map[?background_image])
	if (background_image)
		background_image.count++
		
	background_ground_tex = save_id_find(save_id_map[?background_ground_tex])
	background_ground_tex.count++
	
	if (load_format >= e_project.FORMAT_100_DEMO_4)
	{
		background_sky_sun_tex = save_id_find(save_id_map[?background_sky_sun_tex])
		background_sky_sun_tex.count++
		background_sky_moon_tex = save_id_find(save_id_map[?background_sky_moon_tex])
		background_sky_moon_tex.count++
		background_sky_clouds_tex = save_id_find(save_id_map[?background_sky_clouds_tex])
		background_sky_clouds_tex.count++
	}
}

// Set timeline references
with (obj_timeline)
	if (loaded && !is_undefined(save_id_map[?load_id]))
		save_id = save_id_map[?load_id]

// Set template references
with (obj_template)
{
	if (!loaded)
		continue
		
	if (!is_undefined(save_id_map[?load_id]))
		save_id = save_id_map[?load_id]
		
	skin = save_id_find(save_id_map[?skin])
	item_tex = save_id_find(save_id_map[?item_tex])
	block_tex = save_id_find(save_id_map[?block_tex])
	scenery = save_id_find(save_id_map[?scenery])
	shape_tex = save_id_find(save_id_map[?shape_tex])
	text_font = save_id_find(save_id_map[?text_font])
	
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
	
	// Legacy "use a sheet" option conversion
	if (load_format < e_project.FORMAT_110 && type = "item" && item_tex != res_def && !legacy_item_sheet)
		item_tex.type = "texture"
}

with (obj_timeline)
{
	if (!loaded)
		continue
	
	temp = save_id_find(save_id_map[?temp])
		
	// Bodypart
	part_of = save_id_find(save_id_map[?part_of])
	if (part_of = null && temp != null)
		temp.count++
		
	// Set part list
	if (part_list != null)
		for (var i = 0; i < ds_list_size(part_list); i++)
			part_list[|i] = save_id_find(save_id_map[?part_list[|i]])
	
	// Set parent
	parent = save_id_find(save_id_map[?parent])
	
	if (parent_tree_index = null)
		parent.tree_array[array_length_1d(parent.tree_array)] = id
	else
		parent.tree_array[parent_tree_index] = id
}

// Set keyframe references
with (obj_keyframe)
{
	if (!loaded)
		continue
	
	value[e_value.ATTRACTOR] = save_id_find(save_id_map[?value[e_value.ATTRACTOR]])
	value[e_value.TEXTURE_OBJ] = save_id_find(save_id_map[?value[e_value.TEXTURE_OBJ]])
	value[e_value.SOUND_OBJ] = save_id_find(save_id_map[?value[e_value.SOUND_OBJ]])
	if (value[e_value.SOUND_OBJ] != null)
		value[e_value.SOUND_OBJ].count++
	value[e_value.TEXT_FONT] = save_id_find(save_id_map[?value[e_value.TEXT_FONT]])
}

// Set particle type references
with (obj_particle_type)
{
	if (!loaded)
		continue
	
	if (!is_undefined(save_id_map[?load_id]))
		save_id = save_id_map[?load_id]
	
	temp = save_id_find(save_id_map[?temp])
	sprite_tex = save_id_find(save_id_map[?sprite_tex])

	// Update counters if not loaded via the workbench particle preview
	if (temp_creator != app.bench_settings)
		sprite_tex.count++
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
