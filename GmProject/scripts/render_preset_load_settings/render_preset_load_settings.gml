/// render_preset_load_settings(map)

function render_preset_load_settings(map)
{
	if (!ds_map_valid(map))
		return false
		
	var standardmap = map[?"standard"];
	if (ds_map_valid(standardmap))
	{
		has_standard = true
		standard_ssao = value_get_real(standardmap[?"ssao"], standard_ssao)
		standard_shadows = value_get_real(standardmap[?"shadows"], standard_shadows)
		standard_shadows_blur_quality = value_get_real(standardmap[?"shadows_blur_quality"], standard_shadows_blur_quality)
		standard_shadows_sun_buffer_size = value_get_real(standardmap[?"shadows_sun_buffer_size"], standard_shadows_sun_buffer_size)
		standard_shadows_spot_buffer_size = value_get_real(standardmap[?"shadows_spot_buffer_size"], standard_shadows_spot_buffer_size)
		standard_shadows_point_buffer_size = value_get_real(standardmap[?"shadows_point_buffer_size"], standard_shadows_point_buffer_size)
		standard_glow = value_get_real(standardmap[?"glow"], standard_glow)
		standard_aa = value_get_real(standardmap[?"aa"], standard_aa)
		standard_aa_power = value_get_real(standardmap[?"aa_power"], standard_aa_power)
	}
	
	var realisticmap = map[?"realistic"];
	if (ds_map_valid(realisticmap))
	{
		has_realistic = true
		realistic_samples = value_get_real(realisticmap[?"samples"], realistic_samples)
		realistic_ssao = value_get_real(realisticmap[?"ssao"], realistic_ssao)
		realistic_shadows = value_get_real(realisticmap[?"shadows"], realistic_shadows)
		realistic_shadows_sun_buffer_size = value_get_real(realisticmap[?"shadows_sun_buffer_size"], realistic_shadows_sun_buffer_size)
		realistic_shadows_spot_buffer_size = value_get_real(realisticmap[?"shadows_spot_buffer_size"], realistic_shadows_spot_buffer_size)
		realistic_shadows_point_buffer_size = value_get_real(realisticmap[?"shadows_point_buffer_size"], realistic_shadows_point_buffer_size)
		realistic_shadows_transparent = value_get_real(realisticmap[?"shadows_transparent"], realistic_shadows_transparent)
		realistic_subsurface_samples = value_get_real(realisticmap[?"subsurface_samples"], realistic_subsurface_samples)
		realistic_indirect = value_get_real(realisticmap[?"indirect"], realistic_indirect)
		realistic_indirect_precision = value_get_real(realisticmap[?"indirect_precision"], realistic_indirect_precision)
		realistic_reflections = value_get_real(realisticmap[?"reflections"], realistic_reflections)
		realistic_reflections_precision = value_get_real(realisticmap[?"reflections_precision"], realistic_reflections_precision)
		realistic_glow = value_get_real(realisticmap[?"glow"], realistic_glow)
		realistic_glow_falloff = value_get_real(realisticmap[?"glow_falloff"], realistic_glow_falloff)
		realistic_aa = value_get_real(realisticmap[?"aa"], realistic_aa)
		realistic_aa_power = value_get_real(realisticmap[?"aa_power"], realistic_aa_power)
	}
	
	var fxmap = map[?"specialeffects"];
	if (ds_map_valid(fxmap))
	{
		has_fx = true
		ssao_radius = value_get_real(fxmap[?"ssao_radius"], ssao_radius)
		ssao_power = value_get_real(fxmap[?"ssao_power"], ssao_power)
		ssao_color = value_get_color(fxmap[?"ssao_color"], ssao_color)
		ssao_always_visible = value_get_real(fxmap[?"ssao_always_visible"], ssao_always_visible)
		standard_shadows_blur_size = value_get_real(fxmap[?"shadows_blur_size"], standard_shadows_blur_size)
		realistic_subsurface_highlight = value_get_real(fxmap[?"subsurface_highlight"], realistic_subsurface_highlight)
		realistic_subsurface_highlight_strength = value_get_real(fxmap[?"subsurface_highlight_strength"], realistic_subsurface_highlight_strength)
		realistic_indirect_blur_radius = value_get_real(fxmap[?"indirect_blur_radius"], realistic_indirect_blur_radius)
		realistic_indirect_strength = value_get_real(fxmap[?"indirect_strength"], realistic_indirect_strength)
		realistic_reflections_fade_amount = value_get_real(fxmap[?"reflections_fade_amount"], realistic_reflections_fade_amount)
		realistic_reflections_thickness = value_get_real(fxmap[?"reflections_thickness"], realistic_reflections_thickness)
		glow_radius = value_get_real(fxmap[?"glow_radius"], glow_radius)
		glow_intensity = value_get_real(fxmap[?"glow_intensity"], glow_intensity)
		realistic_glow_falloff_radius = value_get_real(fxmap[?"glow_falloff_radius"], realistic_glow_falloff_radius)
		realistic_glow_falloff_intensity = value_get_real(fxmap[?"glow_falloff_intensity"], realistic_glow_falloff_intensity)
		glint_speed = value_get_real(fxmap[?"glint_speed"], glint_speed)
		glint_strength = value_get_real(fxmap[?"glint_strength"], glint_strength)
		tonemapper = value_get_real(fxmap[?"tonemapper"], tonemapper)
		exposure = value_get_real(fxmap[?"exposure"], exposure)
		gamma = value_get_real(fxmap[?"gamma"], gamma)
	}
			
	var graphicsmap = map[?"graphics"];
	if (ds_map_valid(graphicsmap))
	{
		has_graphics = true
		render_distance = value_get_real(graphicsmap[?"render_distance"], render_distance)
		texture_filtering = value_get_real(graphicsmap[?"texture_filtering"], texture_filtering)
		transparent_block_texture_filtering = value_get_real(graphicsmap[?"transparent_block_texture_filtering"], transparent_block_texture_filtering)
		texture_filtering_level = value_get_real(graphicsmap[?"texture_filtering_level"], texture_filtering_level)
		bend_style = value_get_string(graphicsmap[?"bend_style"], bend_style)
		opaque_leaves = value_get_real(graphicsmap[?"opaque_leaves"], opaque_leaves)
		liquid_animation = value_get_real(graphicsmap[?"liquid_animation"], liquid_animation)
		alpha_mode = value_get_real(graphicsmap[?"render_alpha_mode"], alpha_mode)
	}
			
	var materialsmap = map[?"materials"];
	if (ds_map_valid(materialsmap))
	{
		has_materials = true
		block_emissive = value_get_real(materialsmap[?"block_emissive"], block_emissive)
		block_subsurface = value_get_real(materialsmap[?"block_subsurface"], block_subsurface)
		water_reflections = value_get_real(materialsmap[?"water_reflections"], water_reflections)
		material_maps = value_get_real(materialsmap[?"material_maps"], material_maps)
	}
	
	return true
}
