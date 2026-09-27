/// render_preset_load_settings(map)

function render_preset_load_settings(map)
{
	var set;
	if (!ds_map_valid(map))
		return false

	var standardmap = map[?"standard"];
	if (ds_map_valid(standardmap))
	{
		has_standard = true
		set = renderer[e_renderer.STANDARD]
		set.ssao = value_get_real(standardmap[?"ssao"], set.ssao)
		set.shadows = value_get_real(standardmap[?"shadows"], set.shadows)
		set.dof_quality = clamp(round(value_get_real(standardmap[?"dof_quality"], set.dof_quality)), 8, 64)
		set.dof_realistic_blur = value_get_real(standardmap[?"dof_realistic_blur"], set.dof_realistic_blur)
		set.shadows_blur_quality = value_get_real(standardmap[?"shadows_blur_quality"], set.shadows_blur_quality)
		set.shadows_sun_cascades = clamp(round(value_get_real(standardmap[?"shadows_sun_cascades"], set.shadows_sun_cascades)), 1, 3)
		set.shadows_sun_buffer_size = value_get_real(standardmap[?"shadows_sun_buffer_size"], set.shadows_sun_buffer_size)
		set.shadows_spot_buffer_size = value_get_real(standardmap[?"shadows_spot_buffer_size"], set.shadows_spot_buffer_size)
		set.shadows_point_buffer_size = value_get_real(standardmap[?"shadows_point_buffer_size"], set.shadows_point_buffer_size)
		set.glow = value_get_real(standardmap[?"glow"], set.glow)
		set.aa = value_get_real(standardmap[?"aa"], set.aa)
		set.aa_power = value_get_real(standardmap[?"aa_power"], set.aa_power)
	}

	var realisticmap = map[?"realistic"];
	if (ds_map_valid(realisticmap))
	{
		has_realistic = true
		set = renderer[e_renderer.REALISTIC]
		set.samples = value_get_real(realisticmap[?"samples"], set.samples)
		set.ssao = value_get_real(realisticmap[?"ssao"], set.ssao)
		set.shadows = value_get_real(realisticmap[?"shadows"], set.shadows)
		set.dof_quality = clamp(round(value_get_real(realisticmap[?"dof_quality"], set.dof_quality)), 8, 64)
		set.shadows_blur_quality = value_get_real(realisticmap[?"shadows_blur_quality"], set.shadows_blur_quality)
		set.shadows_sun_cascades = clamp(round(value_get_real(realisticmap[?"shadows_sun_cascades"], set.shadows_sun_cascades)), 1, 3)
		set.shadows_sun_buffer_size = value_get_real(realisticmap[?"shadows_sun_buffer_size"], set.shadows_sun_buffer_size)
		set.shadows_spot_buffer_size = value_get_real(realisticmap[?"shadows_spot_buffer_size"], set.shadows_spot_buffer_size)
		set.shadows_point_buffer_size = value_get_real(realisticmap[?"shadows_point_buffer_size"], set.shadows_point_buffer_size)
		set.shadows_jittered = value_get_real(realisticmap[?"shadows_jittered"], set.shadows_jittered)
		set.shadows_transparent = value_get_real(realisticmap[?"shadows_transparent"], set.shadows_transparent)
		set.subsurface_samples = value_get_real(realisticmap[?"subsurface_samples"], set.subsurface_samples)
		set.indirect = value_get_real(realisticmap[?"indirect"], set.indirect)
		set.indirect_precision = value_get_real(realisticmap[?"indirect_precision"], set.indirect_precision)
		var resolution = value_get_real(realisticmap[?"indirect_resolution"], set.indirect_resolution)
		if (resolution = 1 || resolution = .5 || resolution = .25 || resolution = .125)
			set.indirect_resolution = resolution
		set.indirect_bounces = clamp(round(value_get_real(realisticmap[?"indirect_bounces"], set.indirect_bounces)), 1, 8)
		set.reflections = value_get_real(realisticmap[?"reflections"], set.reflections)
		set.reflections_precision = value_get_real(realisticmap[?"reflections_precision"], set.reflections_precision)
		resolution = value_get_real(realisticmap[?"reflections_resolution"], set.reflections_resolution)
		if (resolution = 1 || resolution = .5 || resolution = .25 || resolution = .125)
			set.reflections_resolution = resolution
		set.reflections_bounces = clamp(round(value_get_real(realisticmap[?"reflections_bounces"], set.reflections_bounces)), 1, 8)
		set.glow = value_get_real(realisticmap[?"glow"], set.glow)
		set.aa = value_get_real(realisticmap[?"aa"], set.aa)
		set.aa_mode = value_get_real(realisticmap[?"aa_mode"], set.aa_mode)
		set.aa_power = value_get_real(realisticmap[?"aa_power"], set.aa_power)
	}

	var fxmap = map[?"specialeffects"];
	if (ds_map_valid(fxmap))
	{
		has_fx = true
		ssao_radius = value_get_real(fxmap[?"ssao_radius"], ssao_radius)
		ssao_power = value_get_real(fxmap[?"ssao_power"], ssao_power)
		ssao_blur_passes = clamp(round(value_get_real(fxmap[?"ssao_blur_passes"], ssao_blur_passes)), 0, 8)
		ssao_color = value_get_color(fxmap[?"ssao_color"], ssao_color)
		ssao_always_visible = value_get_real(fxmap[?"ssao_always_visible"], ssao_always_visible)
		glow_radius = value_get_real(fxmap[?"glow_radius"], glow_radius)
		glow_intensity = value_get_real(fxmap[?"glow_intensity"], glow_intensity)
		glint_speed = value_get_real(fxmap[?"glint_speed"], glint_speed)
		glint_strength = value_get_real(fxmap[?"glint_strength"], glint_strength)
		tonemapper = value_get_real(fxmap[?"tonemapper"], tonemapper)
		exposure = value_get_real(fxmap[?"exposure"], exposure)
		gamma = value_get_real(fxmap[?"gamma"], gamma)

		set = renderer[e_renderer.STANDARD]
		set.shadows_blur_size = value_get_real(fxmap[?"shadows_blur_size"], set.shadows_blur_size)

		set = renderer[e_renderer.REALISTIC]
		set.subsurface_backlight_spread = value_get_real(fxmap[?"subsurface_backlight_spread"], set.subsurface_backlight_spread)
		set.subsurface_backlight_strength = value_get_real(fxmap[?"subsurface_backlight_strength"], set.subsurface_backlight_strength)
		set.subsurface_bright_backlight = value_get_real(fxmap[?"subsurface_bright_backlight"], set.subsurface_bright_backlight)
		set.indirect_blur_radius = value_get_real(fxmap[?"indirect_blur_radius"], set.indirect_blur_radius)
		set.indirect_strength = value_get_real(fxmap[?"indirect_strength"], set.indirect_strength)
		set.reflections_fade_amount = value_get_real(fxmap[?"reflections_fade_amount"], set.reflections_fade_amount)
		set.reflections_thickness = value_get_real(fxmap[?"reflections_thickness"], set.reflections_thickness)
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
		water_roughness = value_get_real(materialsmap[?"water_roughness"], water_roughness)
		water_wave_strength = value_get_real(materialsmap[?"water_wave_strength"], water_wave_strength)
		water_wave_speed = value_get_real(materialsmap[?"water_wave_speed"], water_wave_speed)
		water_wave_scale = value_get_real(materialsmap[?"water_wave_scale"], water_wave_scale)
		water_wave_detail = value_get_real(materialsmap[?"water_wave_detail"], water_wave_detail)
		material_maps = value_get_real(materialsmap[?"material_maps"], material_maps)
	}

	return true
}
