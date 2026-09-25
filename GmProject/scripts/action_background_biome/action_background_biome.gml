/// action_background_biome(biome)
/// @arg biome

function action_background_biome(biome)
{
	var biomeobj, hobj, groundname;
	if (history_undo)
	{
		background_biome = history_data.old_biome
		background_sky_color = history_data.old_sky_color
		background_ground_name = history_data.old_ground_name
		background_ground_slot = history_data.old_ground_slot
	}
	else
	{
		if (history_redo)
			biome = history_data.biome

		// Group object, select first biome in list instead
		biomeobj = find_biome(biome)
		if (biomeobj.group)
		{
			biomeobj = biomeobj.biome_variants[|0]
			biome = biomeobj.name
		}

		groundname = ""
		if (background_dimension = "overworld")
		{
			var oldbiomeobj = find_biome(background_biome)
			if (biomeobj.ground_name != "")
				groundname = biomeobj.ground_name
			else if (oldbiomeobj != null && oldbiomeobj.ground_name != "")
				groundname = overworld_ground
		}

		if (!history_redo)
		{
			if (action_tl_select_single(null, e_tl_type.BACKGROUND))
			{
				tl_value_set_start(action_background_biome, false)
				tl_value_set(e_value.BG_BIOME, biome, false)
				tl_value_set(e_value.BG_SKY_COLOR, biomeobj.sky_color, false)
				if (groundname != "")
					tl_value_set(e_value.BG_GROUND_SLOT, minecraft_assets_block_texture_picker_slot_find(groundname), false)
				tl_value_set_done()
				return 0
			}

			hobj = history_set(action_background_biome)
			hobj.old_biome = background_biome
			hobj.old_sky_color = background_sky_color
			hobj.old_ground_name = background_ground_name
			hobj.old_ground_slot = background_ground_slot
			hobj.biome = biome
		}

		background_biome = biome
		background_sky_color = biomeobj.sky_color
		if (groundname != "")
		{
			background_ground_name = groundname
			background_ground_slot = minecraft_assets_block_texture_picker_slot_find(groundname)
		}
	}

	background_ground_update_texture()
	background_ground_update_texture_material()
	background_ground_update_texture_normal()
	
	with (obj_resource)
		res_update_colors()
	
	properties.library.preview.update = true
}
