/// project_load_update()
/// @desc Update program after reading a file.

// Load resources
with (obj_resource)
	if (loaded)
		res_load()
		
with (mc_res)
	res_update_colors()

if (ds_priority_size(load_queue) > 0)
	load_start(ds_priority_find_max(load_queue), res_load_start)
else if (popup != null)
	popup_close()
	
// Update sky
if (background_loaded)
{
	background_sky_update_clouds()
	background_ground_update_texture()
}

// Update scenery parts
with (obj_timeline)
	if (loaded && part_of != null)
		tl_update_scenery_part()

// Update templates and timelines
with (obj_template)
{
	if (!loaded)
		continue
	
	temp_update()
	
	if (type = e_temp_type.CHARACTER || type = e_temp_type.SPECIAL_BLOCK || type = e_temp_type.MODEL || type = e_temp_type.BODYPART)
	{
		if (load_format >= e_project.FORMAT_110_PRE_1)
			temp_update_model_timeline_parts()
		else
			temp_update_model_timeline_tree()
	}
	
	if (model_name = "banner")
		array_add(banner_update, id)
}

with (obj_timeline)
{
	if (!loaded)
		continue
	
	// Convert legacy bending
	if (load_format < e_project.FORMAT_113 && model_part != null && model_part.bend_part != null)
	{
		var legacyaxis;
		for (legacyaxis = X; legacyaxis <= Z; legacyaxis++)
			if (model_part.bend_axis[legacyaxis])
				break
				
		for (var i = 0; i < ds_list_size(keyframe_list); i++)
		{
			with (keyframe_list[|i])
			{
				value[e_value.BEND_ANGLE_X + legacyaxis] = value[e_value.BEND_ANGLE_LEGACY]
				value[e_value.BEND_ANGLE_LEGACY] = 0
			}
		}
	}
	
	// Set item slot if item name is set
	if (type = e_tl_type.ITEM)
	{
		for (var i = 0; i < ds_list_size(keyframe_list); i++)
		{
			with (keyframe_list[|i])
			{
				if (value[e_value.ITEM_NAME] != "")
					value[e_value.ITEM_SLOT] = ds_list_find_index(mc_assets.item_texture_list, value[e_value.ITEM_NAME])
				
				if (value[e_value.ITEM_SLOT] < 0)
					value[e_value.ITEM_SLOT] = ds_list_find_index(mc_assets.item_texture_list, default_item)
			}
		}
	}
	
	// Update
	tl_update()
	tl_update_values()
	
	// Animate scenery
	if (type = e_tl_type.SCENERY && temp.scenery != null && load_format < e_project.FORMAT_110_PRE_1)
	{
		if (temp.scenery.ready)
			tl_animate_scenery()
		else
			scenery_animate = true
	}
	
	// Show position window
	if (model_part != null)
		value_type_show[e_value_type.POSITION] = model_part.show_position
	
	if (is_banner)
		array_add(banner_update, id)
}

with (obj_particle_type)
	if (loaded)
		ptype_update_sprite_vbuffers()
	
tl_update_length()
tl_update_list()
tl_update_matrix()