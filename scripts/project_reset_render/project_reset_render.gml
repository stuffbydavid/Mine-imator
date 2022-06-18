/// project_reset_render()

function project_reset_render()
{
	project_render_samples = 16
	project_render_dof_quality = 3
	
	project_render_ssao = true
	project_render_ssao_radius = 12
	project_render_ssao_power = 1
	project_render_ssao_blur_passes = 2
	project_render_ssao_color = c_black
	
	project_render_shadows = true
	project_render_shadows_sun_buffer_size = 2048
	project_render_shadows_spot_buffer_size = 512
	project_render_shadows_point_buffer_size = 256
	
	project_render_subsurface_samples = 7
	
	project_render_indirect = true
	project_render_indirect_precision = .3
	project_render_indirect_blur_radius = 1
	project_render_indirect_strength = 1
	
	project_render_reflections = true
	project_render_reflections_precision = .3
	project_render_reflections_thickness = 1
	project_render_reflections_fade_amount = 1
	
	project_render_glow = true
	project_render_glow_radius = 1
	project_render_glow_intensity = 1
	project_render_glow_falloff = false
	project_render_glow_falloff_radius = 2
	project_render_glow_falloff_intensity = 1
	
	project_render_aa = true
	project_render_aa_power = 1
	
	project_render_texture_filtering = true
	project_render_transparent_block_texture_filtering = false
	project_render_texture_filtering_level = 1
	
	project_render_gamma_correct = true
	project_render_material_maps = false
	
	project_bend_style = "blocky"
	project_render_opaque_leaves = false
	project_render_liquid_animation = true
	project_render_block_brightness = 1
	project_render_block_subsurface = 2
	project_render_random_blocks = true
	
	texture_set_mipmap_level(project_render_texture_filtering_level)
	render_generate_dof_samples(0, 0, 0)
	render_samples = -1
	render_samples_clear = true
	
	// Update bend meshes
	with (obj_timeline)
	{
		bend_rot_last = vec3(0)
		tl_update_model_shape_bend()
	}
}