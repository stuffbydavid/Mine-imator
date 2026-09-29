/// @desc Update grass & foliage colors for a resource.
/// @arg [biome]
/// @arg [nextbiome]
/// @arg [mix]

function res_update_colors(biome = "", nextbiome = "", mix = 0)
{
	if (colormap_grass_texture = null)
		return 0
	
	if (biome = "")
		biome = app.background_biome
		
	mix = clamp(mix, 0, 1)
	
	var colors;
	if (nextbiome != "" && biome != nextbiome)
	{
		var startframe, endframe;
		startframe = app.background_tlactive.keyframe_current
		endframe = app.background_tlactive.keyframe_next
		
		// Resolve colormaps only when the keyframe pair changes
		if (color_biome_start_colors = null || color_biome_end_colors = null ||
			color_biome_start_name != biome || color_biome_end_name != nextbiome ||
			color_biome_start_frame != startframe || color_biome_end_frame != endframe)
		{
			color_biome_start_colors = res_biome_colors(biome, app.background_tlactive.keyframe_current_values)
			color_biome_end_colors = res_biome_colors(nextbiome, app.background_tlactive.keyframe_next_values)
			color_biome_start_name = biome
			color_biome_end_name = nextbiome
			color_biome_start_frame = startframe
			color_biome_end_frame = endframe
		}
		else
		{
			if (biome = "custom")
				color_biome_start_colors = res_biome_colors(biome, app.background_tlactive.keyframe_current_values)
			if (nextbiome = "custom")
				color_biome_end_colors = res_biome_colors(nextbiome, app.background_tlactive.keyframe_next_values)
		}
		
		if (color_biome_start_colors = null || color_biome_end_colors = null)
			return 0
		
		colors = array_create(e_biome_color.amount)
		for (var i = 0; i < e_biome_color.amount; i++)
			colors[i] = merge_color(color_biome_start_colors[i], color_biome_end_colors[i], mix)
	}
	else
	{
		color_biome_start_colors = null
		color_biome_end_colors = null
		colors = res_biome_colors(biome)
		if (colors = null)
			return 0
	}

	color_grass = colors[e_biome_color.GRASS]
	color_foliage = colors[e_biome_color.FOLIAGE]
	color_dry_foliage = colors[e_biome_color.DRY_FOLIAGE]
	color_water = colors[e_biome_color.WATER]
	color_leaves_oak = colors[e_biome_color.LEAVES_OAK]
	color_leaves_spruce = colors[e_biome_color.LEAVES_SPRUCE]
	color_leaves_birch = colors[e_biome_color.LEAVES_BIRCH]
	color_leaves_jungle = colors[e_biome_color.LEAVES_JUNGLE]
	color_leaves_acacia = colors[e_biome_color.LEAVES_ACACIA]
	color_leaves_dark_oak = colors[e_biome_color.LEAVES_DARK_OAK]
	color_leaves_mangrove = colors[e_biome_color.LEAVES_MANGROVE]
}
