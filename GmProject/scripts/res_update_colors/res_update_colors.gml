/// @desc Update grass & foliage colors for a resource.
/// @arg [biome]
/// @arg [nextbiome]
/// @arg [mix]

function res_update_colors(biome = "", nextbiome = "", mix = 0)
{
	if (colormap_grass_texture = null)
		return 0
	
	if (biome = "")
		biome = app.env_biome
		
	mix = clamp(mix, 0, 1)
	
	if (nextbiome != "" && biome != nextbiome)
	{
		var startframe, endframe;
		startframe = app.timeline_environment.keyframe_current
		endframe = app.timeline_environment.keyframe_next
		
		// Resolve colormaps only when the keyframe pair changes
		if (color_biome_start_colors = null || color_biome_end_colors = null ||
			color_biome_start_name != biome || color_biome_end_name != nextbiome ||
			color_biome_start_frame != startframe || color_biome_end_frame != endframe)
		{
			color_biome_start_colors = res_biome_colors(biome, startframe)
			color_biome_end_colors = res_biome_colors(nextbiome, endframe)
			color_biome_start_name = biome
			color_biome_end_name = nextbiome
			color_biome_start_frame = startframe
			color_biome_end_frame = endframe
		}
		else
		{
			if (biome = "custom")
				color_biome_start_colors = res_biome_colors(biome, startframe)
			
			if (nextbiome = "custom")
				color_biome_end_colors = res_biome_colors(nextbiome, endframe)
		}
		
		if (color_biome_start_colors = null || color_biome_end_colors = null)
			return 0
		
		color_list = array_create(e_biome_color.amount)
		for (var i = 0; i < e_biome_color.amount; i++)
			color_list[i] = merge_color(color_biome_start_colors[i], color_biome_end_colors[i], mix)
	}
	else
	{
		color_biome_start_colors = null
		color_biome_end_colors = null
		
		if (find_biome(biome) = null)
			return 0
		
		color_list = res_biome_colors(biome)
	}

	// Create the shader palette
	block_colors = []
	block_colors_fast = []
	
	for (var i = 0; i < e_color_palette.amount + ds_list_size(mc_assets.block_texture_color_list); i++)
	{
		var tint, alpha, offset;
		alpha = 1

		if (i < e_biome_color.amount)
			tint = color_list[@i]
		
		else if (i < e_color_palette.REDSTONE)
		{
			switch (i)
			{
				case e_color_palette.PUMPKIN_STEM:	tint = c_pumpkin_stem; break
				case e_color_palette.MELON_STEM:	tint = c_melon_stem; break
				case e_color_palette.LILY_PAD:		tint = c_lily_pad; break
			}
		}
		else if (i < e_color_palette.CLOUDS_TOP)
		{
			var pow, brightness;
			pow = i - e_color_palette.REDSTONE
			brightness = (pow = 0 ? 0.3 : 0.6 * pow / 15 + 0.4)
			tint = make_color_rgb(
				color_get_red(c_redstone) * brightness,
				color_get_green(c_redstone) * brightness,
				color_get_blue(c_redstone) * brightness
			)
		}
		else if (i < e_color_palette.amount)
		{
			switch (i)
			{
				case e_color_palette.CLOUDS_TOP:			tint = c_clouds_top; break
				case e_color_palette.CLOUDS_SIDES_DARK:		tint = c_clouds_sidesdark; break
				case e_color_palette.CLOUDS_SIDES_LIGHT:	tint = c_clouds_sideslight; break
				case e_color_palette.CLOUDS_BOTTOM:			tint = c_clouds_bottom; break
				case e_color_palette.CLOUDS_FADED:			tint = c_white; alpha = 0; break
			}
		}
		else
			tint = mc_assets.block_texture_color_list[|i - e_color_palette.amount]

		offset = i * 4
		block_colors[@offset] = color_get_red(tint) / 255
		block_colors[@offset + 1] = color_get_green(tint) / 255
		block_colors[@offset + 2] = color_get_blue(tint) / 255
		block_colors[@offset + 3] = alpha

		for (var channel = 0; channel < 4; channel++)
			block_colors_fast[@offset + channel] = (i < e_biome_color.amount ? 1 : block_colors[@offset + channel])
	}
}
