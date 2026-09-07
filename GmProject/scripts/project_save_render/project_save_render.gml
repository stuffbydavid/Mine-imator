/// project_save_render()

function project_save_render()
{
	json_save_object_start("render")
		
		// Standard renderer performance settings
		with (render_preset_map[?project_render_preset[e_renderer.STANDARD]])
			render_preset_save_settings(e_renderer.STANDARD)

		// Realistic renderer performance settings
		with (render_preset_map[?project_render_preset[e_renderer.REALISTIC]])
			render_preset_save_settings(e_renderer.REALISTIC)
		
		// Project settings
		project_save_render_specialeffects()
		project_save_render_graphics()
		project_save_render_materials()
		
	json_save_object_done()
}

function project_save_render_specialeffects()
{
	json_save_object_start("specialeffects")
		json_save_var("ssao_radius", project_render_ssao_radius)
		json_save_var("ssao_power", project_render_ssao_power)
		json_save_var_color("ssao_color", project_render_ssao_color)
		json_save_var_bool("ssao_always_visible", project_render_ssao_always_visible)
		json_save_var("shadows_blur_size", project_render_shadows_blur_size)
		json_save_var("subsurface_highlight", project_render_subsurface_highlight)
		json_save_var("subsurface_highlight_strength", project_render_subsurface_highlight_strength)
		json_save_var("indirect_blur_radius", project_render_indirect_blur_radius)
		json_save_var("indirect_strength", project_render_indirect_strength)
		json_save_var("reflections_thickness", project_render_reflections_thickness)
		json_save_var("reflections_fade_amount", project_render_reflections_fade_amount)
		json_save_var("glow_radius", project_render_glow_radius)
		json_save_var("glow_intensity", project_render_glow_intensity)
		json_save_var("glow_falloff_radius", project_render_glow_falloff_radius)
		json_save_var("glow_falloff_intensity", project_render_glow_falloff_intensity)
		json_save_var("glint_speed", project_render_glint_speed)
		json_save_var("glint_strength", project_render_glint_strength)
		json_save_var("tonemapper", project_render_tonemapper)
		json_save_var("exposure", project_render_exposure)
		json_save_var("gamma", project_render_gamma)
	json_save_object_done()
}

function project_save_render_graphics()
{
	json_save_object_start("graphics")
		json_save_var("render_distance", project_render_distance)
		json_save_var_bool("texture_filtering", project_render_texture_filtering)
		json_save_var_bool("transparent_block_texture_filtering", project_render_transparent_block_texture_filtering)
		json_save_var("texture_filtering_level", project_render_texture_filtering_level)
		json_save_var("bend_style", project_bend_style)
		json_save_var_bool("opaque_leaves", project_render_opaque_leaves)
		json_save_var_bool("liquid_animation", project_render_liquid_animation)
		json_save_var("render_alpha_mode", project_render_alpha_mode)
	json_save_object_done()
}

function project_save_render_materials()
{
	json_save_object_start("materials")
		json_save_var("block_emissive", project_render_block_emissive)
		json_save_var("block_subsurface", project_render_block_subsurface)
		json_save_var_bool("water_reflections", project_render_water_reflections)
		json_save_var_bool("material_maps", project_render_material_maps)
	json_save_object_done()
}