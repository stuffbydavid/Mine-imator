/// project_save_render()

function project_save_render()
{
	json_save_object_start("render")
		
		json_save_var("render_samples", project_render_samples)
		json_save_var("render_distance", project_render_distance)
		
		json_save_var_bool("render_ssao", project_render_ssao)
		json_save_var("render_ssao_radius", project_render_ssao_radius)
		json_save_var("render_ssao_power", project_render_ssao_power)
		json_save_var_color("render_ssao_color", project_render_ssao_color)
		
		json_save_var_bool("render_shadows", project_render_shadows)
		json_save_var("render_shadows_sun_buffer_size", project_render_shadows_sun_buffer_size)
		json_save_var("render_shadows_spot_buffer_size", project_render_shadows_spot_buffer_size)
		json_save_var("render_shadows_point_buffer_size", project_render_shadows_point_buffer_size)
		json_save_var("render_shadows_transparent", project_render_shadows_transparent)
		
		json_save_var("render_subsurface_samples", project_render_subsurface_samples)
		json_save_var("render_subsurface_highlight", project_render_subsurface_highlight)
		json_save_var("render_subsurface_highlight_strength", project_render_subsurface_highlight_strength)
		
		json_save_var_bool("render_indirect", project_render_indirect)
		json_save_var("render_indirect_precision", project_render_indirect_precision)
		json_save_var("render_indirect_blur_radius", project_render_indirect_blur_radius)
		json_save_var("render_indirect_strength", project_render_indirect_strength)
		
		json_save_var_bool("render_reflections", project_render_reflections)
		json_save_var("render_reflections_precision", project_render_reflections_precision)
		json_save_var("render_reflections_thickness", project_render_reflections_thickness)
		json_save_var("render_reflections_fade_amount", project_render_reflections_fade_amount)
		
		json_save_var_bool("render_glow", project_render_glow)
		json_save_var("render_glow_radius", project_render_glow_radius)
		json_save_var("render_glow_intensity", project_render_glow_intensity)
		json_save_var_bool("render_glow_falloff", project_render_glow_falloff)
		json_save_var("render_glow_falloff_radius", project_render_glow_falloff_radius)
		json_save_var("render_glow_falloff_intensity", project_render_glow_falloff_intensity)
		
		json_save_var_bool("render_aa", project_render_aa)
		json_save_var("render_aa_power", project_render_aa_power)
		
		json_save_var("bend_style", project_bend_style)
		json_save_var_bool("opaque_leaves", project_render_opaque_leaves)
		json_save_var_bool("liquid_animation", project_render_liquid_animation)
		json_save_var_bool("water_reflections", project_render_water_reflections)
		
		json_save_var("block_emissive", project_render_block_emissive)
		json_save_var("block_subsurface", project_render_block_subsurface)
		
		json_save_var("glint_speed", project_render_glint_speed)
		json_save_var("glint_strength", project_render_glint_strength)
		
		json_save_var_bool("texture_filtering", project_render_texture_filtering)
		json_save_var_bool("transparent_block_texture_filtering", project_render_transparent_block_texture_filtering)
		json_save_var("texture_filtering_level", project_render_texture_filtering_level)
		
		json_save_var("render_alpha_mode", project_render_alpha_mode)
		json_save_var("tonemapper", project_render_tonemapper)
		json_save_var("exposure", project_render_exposure)
		json_save_var("gamma", project_render_gamma)
		json_save_var_bool("material_maps", project_render_material_maps)
		
	json_save_object_done()
}