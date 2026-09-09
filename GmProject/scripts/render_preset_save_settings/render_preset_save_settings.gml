/// render_preset_save_settings(renderer)

function render_preset_save_settings(renderer)
{
	var set;
	if (renderer = e_renderer.STANDARD && has_standard)
	{
		set = self.renderer[renderer]
		json_save_object_start("standard")
			json_save_var_bool("ssao", set.ssao)
			json_save_var_bool("shadows", set.shadows)
			json_save_var("shadows_blur_quality", set.shadows_blur_quality)
			json_save_var("shadows_sun_buffer_size", set.shadows_sun_buffer_size)
			json_save_var("shadows_spot_buffer_size", set.shadows_spot_buffer_size)
			json_save_var("shadows_point_buffer_size", set.shadows_point_buffer_size)
			json_save_var_bool("glow", set.glow)
			json_save_var_bool("aa", set.aa)
			json_save_var("aa_power", set.aa_power)
		json_save_object_done()
	}

	if (renderer = e_renderer.REALISTIC && has_realistic)
	{
		set = self.renderer[renderer]
		json_save_object_start("realistic")
			json_save_var("samples", set.samples)
			json_save_var_bool("ssao", set.ssao)
			json_save_var_bool("shadows", set.shadows)
			json_save_var("shadows_sun_buffer_size", set.shadows_sun_buffer_size)
			json_save_var("shadows_spot_buffer_size", set.shadows_spot_buffer_size)
			json_save_var("shadows_point_buffer_size", set.shadows_point_buffer_size)
			json_save_var_bool("shadows_transparent", set.shadows_transparent)
			json_save_var("subsurface_samples", set.subsurface_samples)
			json_save_var_bool("indirect", set.indirect)
			json_save_var("indirect_precision", set.indirect_precision)
			json_save_var_bool("reflections", set.reflections)
			json_save_var("reflections_precision", set.reflections_precision)
			json_save_var_bool("glow", set.glow)
			json_save_var_bool("glow_falloff", set.glow_falloff)
			json_save_var_bool("aa", set.aa)
			json_save_var("aa_power", set.aa_power)
		json_save_object_done()
	}

	if (renderer = e_renderer.COMMON)
	{
		if (has_fx)
		{
			json_save_object_start("specialeffects")
				json_save_var("ssao_radius", ssao_radius)
				json_save_var("ssao_power", ssao_power)
				json_save_var_color("ssao_color", ssao_color)
				json_save_var_bool("ssao_always_visible", ssao_always_visible)
				json_save_var("glow_radius", glow_radius)
				json_save_var("glow_intensity", glow_intensity)
				json_save_var("glint_speed", glint_speed)
				json_save_var("glint_strength", glint_strength)
				json_save_var("tonemapper", tonemapper)
				json_save_var("exposure", exposure)
				json_save_var("gamma", gamma)

				set = self.renderer[e_renderer.STANDARD]
				json_save_var("shadows_blur_size", set.shadows_blur_size)

				set = self.renderer[e_renderer.REALISTIC]
				json_save_var("subsurface_highlight", set.subsurface_highlight)
				json_save_var("subsurface_highlight_strength", set.subsurface_highlight_strength)
				json_save_var("indirect_blur_radius", set.indirect_blur_radius)
				json_save_var("indirect_strength", set.indirect_strength)
				json_save_var("reflections_fade_amount", set.reflections_fade_amount)
				json_save_var("reflections_thickness", set.reflections_thickness)
				json_save_var("glow_falloff_radius", set.glow_falloff_radius)
				json_save_var("glow_falloff_intensity", set.glow_falloff_intensity)
			json_save_object_done()
		}

		if (has_graphics)
		{
			json_save_object_start("graphics")
				json_save_var("render_distance", render_distance)
				json_save_var_bool("texture_filtering", texture_filtering)
				json_save_var_bool("transparent_block_texture_filtering", transparent_block_texture_filtering)
				json_save_var("texture_filtering_level", texture_filtering_level)
				json_save_var("bend_style", bend_style)
				json_save_var_bool("opaque_leaves", opaque_leaves)
				json_save_var_bool("liquid_animation", liquid_animation)
				json_save_var("render_alpha_mode", alpha_mode)
			json_save_object_done()
		}

		if (has_materials)
		{
			json_save_object_start("materials")
				json_save_var("block_emissive", block_emissive)
				json_save_var("block_subsurface", block_subsurface)
				json_save_var_bool("water_reflections", water_reflections)
				json_save_var_bool("material_maps", material_maps)
			json_save_object_done()
		}
	}
}
