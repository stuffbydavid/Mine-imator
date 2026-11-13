/// @arg dimension

function action_env_dimension(dim)
{
	var hobj;
	
	if (history_undo)
	{
		hobj = history_data
		if (hobj.dimension_timeline)
			tl_value_set()
		
		env_dimension = hobj.old_dimension
		env_sky_clouds_show = hobj.old_clouds_show
		env_sky_color = hobj.old_sky_color
		env_background_image_show = hobj.old_image_show
		env_ground_name = hobj.old_ground_name
		env_ground_slot = hobj.old_ground_slot
		env_biome = hobj.old_biome
		env_fog_show = hobj.old_fog_show
		env_fog_distance = hobj.old_fog_distance
		env_fog_size = hobj.old_fog_size
	}
	else
	{
		var timeline = false;
		
		if (history_redo)
		{
			dim = history_data.new_dimension
			if (history_data.dimension_timeline)
				tl_value_set()
		}
		else
		{
			timeline = action_tl_select_single_type(e_tl_type.ENVIRONMENT)
			if (timeline)
			{
				tl_value_set_start(action_env_dimension, false)
				hobj = history_data
				hobj.script = action_env_dimension
			}
			else
				hobj = history_set(action_env_dimension)

			hobj.dimension_timeline = timeline
			hobj.old_dimension = env_dimension
			hobj.old_clouds_show = env_sky_clouds_show
			hobj.old_sky_color = env_sky_color
			hobj.old_image_show = env_background_image_show
			hobj.old_ground_name = env_ground_name
			hobj.old_ground_slot = env_ground_slot
			hobj.old_biome = env_biome
			hobj.old_fog_show = env_fog_show
			hobj.old_fog_distance = env_fog_distance
			hobj.old_fog_size = env_fog_size
			hobj.new_dimension = dim
		}

		env_dimension = dim
		env_fog_size = fog_size
		
		var groundname = "";

		switch (dim)
		{
			case "overworld":
			{
				env_sky_clouds_show = true
				env_sky_color = c_sky_overworld
				env_background_image_show = false
				env_fog_show = true
				env_fog_distance = fog_far
				env_biome = overworld_biome
				groundname = overworld_ground
				
				break
			}
			
			case "the_nether":
			{
				env_sky_clouds_show = false
				env_sky_color = c_sky_the_nether
				env_background_image_show = true
				env_fog_show = true
				env_fog_distance = fog_near
				env_biome = the_nether_biome
				groundname = the_nether_ground
				
				break
			}
			
			case "the_end":
			{
				env_sky_clouds_show = false
				env_sky_color = c_sky_the_end
				env_background_image_show = true
				env_fog_show = true
				env_fog_distance = fog_near
				env_biome = the_end_biome
				groundname = the_end_ground
				
				break
			}
		}
		
		var biomeobj = find_biome(env_biome);
		if (biomeobj != null)
			env_sky_color = biomeobj.sky_color

		if (env_ground_show)
		{
			env_ground_name = groundname
			env_ground_slot = minecraft_assets_block_texture_picker_slot_find(groundname)
		}

		if (timeline)
		{
			tl_value_set(e_value.ENV_SKY_CLOUDS_SHOW, env_sky_clouds_show, false)
			tl_value_set(e_value.ENV_SKY_COLOR, env_sky_color, false)
			tl_value_set(e_value.ENV_IMAGE_SHOW, env_background_image_show, false)
			tl_value_set(e_value.ENV_BIOME, env_biome, false)
			tl_value_set(e_value.ENV_FOG_SHOW, env_fog_show, false)
			tl_value_set(e_value.ENV_FOG_DISTANCE, env_fog_distance, false)
			tl_value_set(e_value.ENV_FOG_SIZE, env_fog_size, false)
				
			if (env_ground_show)
				tl_value_set(e_value.ENV_GROUND_SLOT, env_ground_slot, false)
			
			tl_value_set_done()
		}
	}

	env_ground_update_texture()
	env_ground_update_texture_material()
	env_ground_update_texture_normal()
	
	with (obj_resource)
		res_update_colors()
	
	properties.library.preview.update = true
}
