/// action_background_dimension(dim)
/// @arg dim

function action_background_dimension(dim)
{
	var hobj, groundname, biomeobj, timeline;
	timeline = false
	
	if (history_undo)
	{
		hobj = history_data
		if (hobj.dimension_timeline)
			tl_value_set()
		background_dimension = hobj.old_dimension
		background_sky_clouds_show = hobj.old_clouds_show
		background_sky_color = hobj.old_sky_color
		background_image_show = hobj.old_image_show
		background_ground_name = hobj.old_ground_name
		background_ground_slot = hobj.old_ground_slot
		background_biome = hobj.old_biome
		background_fog_show = hobj.old_fog_show
		background_fog_distance = hobj.old_fog_distance
		background_fog_size = hobj.old_fog_size
	}
	else
	{
		if (history_redo)
		{
			dim = history_data.new_dimension
			if (history_data.dimension_timeline)
				tl_value_set()
		}
		else
		{
			timeline = action_tl_select_single(null, e_tl_type.BACKGROUND)
			if (timeline)
			{
				tl_value_set_start(action_background_dimension, false)
				hobj = history_data
				hobj.script = action_background_dimension
			}
			else
				hobj = history_set(action_background_dimension)

			hobj.dimension_timeline = timeline
			hobj.old_dimension = background_dimension
			hobj.old_clouds_show = background_sky_clouds_show
			hobj.old_sky_color = background_sky_color
			hobj.old_image_show = background_image_show
			hobj.old_ground_name = background_ground_name
			hobj.old_ground_slot = background_ground_slot
			hobj.old_biome = background_biome
			hobj.old_fog_show = background_fog_show
			hobj.old_fog_distance = background_fog_distance
			hobj.old_fog_size = background_fog_size
			hobj.new_dimension = dim
		}

		background_dimension = dim
		background_fog_size = fog_size
		groundname = ""

		switch (dim)
		{
			case "overworld":
				background_sky_clouds_show = true
				background_sky_color = c_sky_overworld
				background_image_show = false
				background_fog_show = true
				background_fog_distance = fog_far
				background_biome = overworld_biome
				groundname = overworld_ground
				break

			case "the_nether":
				background_sky_clouds_show = false
				background_sky_color = c_sky_the_nether
				background_image_show = true
				background_fog_show = true
				background_fog_distance = fog_near
				background_biome = the_nether_biome
				groundname = the_nether_ground
				break

			case "the_end":
				background_sky_clouds_show = false
				background_sky_color = c_sky_the_end
				background_image_show = true
				background_fog_show = true
				background_fog_distance = fog_near
				background_biome = the_end_biome
				groundname = the_end_ground
				break
		}
		
		biomeobj = find_biome(background_biome)
		if (biomeobj != null)
			background_sky_color = biomeobj.sky_color

		if (background_ground_show)
		{
			background_ground_name = groundname
			background_ground_slot = minecraft_assets_block_texture_picker_slot_find(groundname)
		}

		if (timeline)
		{
			tl_value_set(e_value.BG_SKY_CLOUDS_SHOW, background_sky_clouds_show, false)
			tl_value_set(e_value.BG_SKY_COLOR, background_sky_color, false)
			tl_value_set(e_value.BG_IMAGE_SHOW, background_image_show, false)
			tl_value_set(e_value.BG_BIOME, background_biome, false)
			tl_value_set(e_value.BG_FOG_SHOW, background_fog_show, false)
			tl_value_set(e_value.BG_FOG_DISTANCE, background_fog_distance, false)
			tl_value_set(e_value.BG_FOG_SIZE, background_fog_size, false)
				
			if (background_ground_show)
				tl_value_set(e_value.BG_GROUND_SLOT, background_ground_slot, false)
			
			tl_value_set_done()
		}
	}

	background_ground_update_texture()
	background_ground_update_texture_material()
	background_ground_update_texture_normal()
	with (obj_resource)
		res_update_colors()
	
	properties.library.preview.update = true
}
