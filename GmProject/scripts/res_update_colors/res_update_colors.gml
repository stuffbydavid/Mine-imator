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
			color_biome_start_colors = res_biome_colors(biome, app.timeline_environment.keyframe_current_values)
			color_biome_end_colors = res_biome_colors(nextbiome, app.timeline_environment.keyframe_next_values)
			color_biome_start_name = biome
			color_biome_end_name = nextbiome
			color_biome_start_frame = startframe
			color_biome_end_frame = endframe
		}
		else
		{
			if (biome = "custom")
				color_biome_start_colors = res_biome_colors(biome, app.timeline_environment.keyframe_current_values)
			
			if (nextbiome = "custom")
				color_biome_end_colors = res_biome_colors(nextbiome, app.timeline_environment.keyframe_next_values)
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
}
