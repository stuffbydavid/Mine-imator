/// project_load_legacy_render(map)

function project_load_legacy_render(map)
{
	var custom = render_preset_map[?"custom"]
	with (custom)
	{
		var standardset = renderer[e_renderer.STANDARD]
		var realisticset = renderer[e_renderer.REALISTIC]

		// Legacy projects stored one flat set of render settings
		has_standard = true
		has_realistic = true
		has_fx = true
		has_graphics = true
		has_materials = true

		with (standardset)
		{
			ssao = value_get_real(map[?"render_ssao"], ssao)
			shadows = value_get_real(map[?"render_shadows"], shadows)
			shadows_sun_buffer_size = value_get_real(map[?"render_shadows_sun_buffer_size"], shadows_sun_buffer_size)
			shadows_spot_buffer_size = value_get_real(map[?"render_shadows_spot_buffer_size"], shadows_spot_buffer_size)
			shadows_point_buffer_size = value_get_real(map[?"render_shadows_point_buffer_size"], shadows_point_buffer_size)
			glow = value_get_real(map[?"render_glow"], glow)
			aa = value_get_real(map[?"render_aa"], aa)
			aa_power = value_get_real(map[?"render_aa_power"], aa_power)
		}

		with (realisticset)
		{
			samples = value_get_real(map[?"render_samples"], samples)
			ssao = standardset.ssao
			shadows = standardset.shadows
			shadows_sun_buffer_size = standardset.shadows_sun_buffer_size
			shadows_spot_buffer_size = standardset.shadows_spot_buffer_size
			shadows_point_buffer_size = standardset.shadows_point_buffer_size
			shadows_transparent = value_get_real(map[?"render_shadows_transparent"], shadows_transparent)
			subsurface_samples = value_get_real(map[?"render_subsurface_samples"], subsurface_samples)
			subsurface_highlight = value_get_real(map[?"render_subsurface_highlight"], subsurface_highlight)
			subsurface_highlight_strength = value_get_real(map[?"render_subsurface_highlight_strength"], subsurface_highlight_strength)
			indirect = value_get_real(map[?"render_indirect"], indirect)
			indirect_blur_radius = value_get_real(map[?"render_indirect_blur_radius"], indirect_blur_radius)
			indirect_precision = value_get_real(map[?"render_indirect_precision"], indirect_precision)
			indirect_strength = value_get_real(map[?"render_indirect_strength"], indirect_strength)
			reflections = value_get_real(map[?"render_reflections"], reflections)
			reflections_precision = value_get_real(map[?"render_reflections_precision"], reflections_precision)
			reflections_thickness = value_get_real(map[?"render_reflections_thickness"], reflections_thickness)
			reflections_fade_amount = value_get_real(map[?"render_reflections_fade_amount"], reflections_fade_amount)
			glow = standardset.glow
			glow_falloff = value_get_real(map[?"render_glow_falloff"], glow_falloff)
			glow_falloff_radius = value_get_real(map[?"render_glow_falloff_radius"], glow_falloff_radius)
			glow_falloff_intensity = value_get_real(map[?"render_glow_falloff_intensity"], glow_falloff_intensity)
			aa = standardset.aa
			aa_power = standardset.aa_power
		}

		ssao_radius = value_get_real(map[?"render_ssao_radius"], ssao_radius)
		ssao_power = value_get_real(map[?"render_ssao_power"], ssao_power)
		ssao_color = value_get_color(map[?"render_ssao_color"], ssao_color)
		ssao_always_visible = value_get_real(map[?"render_ssao_always_visible"], ssao_always_visible)
		glow_radius = value_get_real(map[?"render_glow_radius"], glow_radius)
		glow_intensity = value_get_real(map[?"render_glow_intensity"], glow_intensity)
		glint_speed = value_get_real(map[?"glint_speed"], glint_speed)
		glint_strength = value_get_real(map[?"glint_strength"], glint_strength)
		tonemapper = value_get_real(map[?"tonemapper"], tonemapper)
		exposure = value_get_real(map[?"exposure"], exposure)
		gamma = value_get_real(map[?"gamma"], gamma)

		render_distance = value_get_real(map[?"render_distance"], render_distance)
		texture_filtering = value_get_real(map[?"texture_filtering"], texture_filtering)
		transparent_block_texture_filtering = value_get_real(map[?"transparent_block_texture_filtering"], transparent_block_texture_filtering)
		texture_filtering_level = value_get_real(map[?"texture_filtering_level"], texture_filtering_level)
		bend_style = value_get_string(map[?"bend_style"], bend_style)
		opaque_leaves = value_get_real(map[?"opaque_leaves"], opaque_leaves)
		liquid_animation = value_get_real(map[?"liquid_animation"], liquid_animation)
		alpha_mode = value_get_real(map[?"render_alpha_mode"], alpha_mode)

		block_emissive = value_get_real(map[?"block_emissive"], block_emissive)
		block_subsurface = value_get_real(map[?"block_subsurface"], block_subsurface)
		water_reflections = value_get_real(map[?"water_reflections"], water_reflections)
		material_maps = value_get_real(map[?"material_maps"], material_maps)
	}
}
