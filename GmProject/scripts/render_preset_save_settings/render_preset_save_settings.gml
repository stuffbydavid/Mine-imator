/// render_preset_save_settings(renderer)

function render_preset_save_settings(renderer)
{
	if (renderer = e_renderer.STANDARD && has_standard)
	{
		json_save_object_start("standard")
			json_save_var_bool("ssao", standard_ssao)
			json_save_var_bool("shadows", standard_shadows)
			json_save_var("shadows_blur_quality", standard_shadows_blur_quality)
			json_save_var("shadows_sun_buffer_size", standard_shadows_sun_buffer_size)
			json_save_var("shadows_spot_buffer_size", standard_shadows_spot_buffer_size)
			json_save_var("shadows_point_buffer_size", standard_shadows_point_buffer_size)
			json_save_var_bool("glow", standard_glow)
			json_save_var_bool("aa", standard_aa)
			json_save_var("aa_power", standard_aa_power)
		json_save_object_done()
	}

	if (renderer = e_renderer.REALISTIC && has_realistic)
	{
		json_save_object_start("realistic")
			json_save_var("samples", realistic_samples)
			json_save_var_bool("ssao", realistic_ssao)
			json_save_var_bool("shadows", realistic_shadows)
			json_save_var("shadows_sun_buffer_size", realistic_shadows_sun_buffer_size)
			json_save_var("shadows_spot_buffer_size", realistic_shadows_spot_buffer_size)
			json_save_var("shadows_point_buffer_size", realistic_shadows_point_buffer_size)
			json_save_var_bool("shadows_transparent", realistic_shadows_transparent)
			json_save_var("subsurface_samples", realistic_subsurface_samples)
			json_save_var_bool("indirect", realistic_indirect)
			json_save_var("indirect_precision", realistic_indirect_precision)
			json_save_var_bool("reflections", realistic_reflections)
			json_save_var("reflections_precision", realistic_reflections_precision)
			json_save_var_bool("glow", realistic_glow)
			json_save_var_bool("glow_falloff", realistic_glow_falloff)
			json_save_var_bool("aa", realistic_aa)
			json_save_var("aa_power", realistic_aa_power)
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
				json_save_var("shadows_blur_size", standard_shadows_blur_size)
				json_save_var("subsurface_highlight", realistic_subsurface_highlight)
				json_save_var("subsurface_highlight_strength", realistic_subsurface_highlight_strength)
				json_save_var("indirect_blur_radius", realistic_indirect_blur_radius)
				json_save_var("indirect_strength", realistic_indirect_strength)
				json_save_var("reflections_fade_amount", realistic_reflections_fade_amount)
				json_save_var("reflections_thickness", realistic_reflections_thickness)
				json_save_var("glow_radius", glow_radius)
				json_save_var("glow_intensity", glow_intensity)
				json_save_var("glow_falloff_radius", realistic_glow_falloff_radius)
				json_save_var("glow_falloff_intensity", realistic_glow_falloff_intensity)
				json_save_var("glint_speed", glint_speed)
				json_save_var("glint_strength", glint_strength)
				json_save_var("tonemapper", tonemapper)
				json_save_var("exposure", exposure)
				json_save_var("gamma", gamma)
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
