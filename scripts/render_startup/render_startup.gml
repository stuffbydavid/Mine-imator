/// render_startup()

function render_startup()
{
	globalvar render_view_current, render_width, render_height, render_ratio, render_camera, render_time, render_surface_time,
			  render_target, render_surface, render_prev_color, render_prev_alpha, render_click_box, render_list, render_lights,
			  render_fog, render_particles, render_hidden, render_background, render_watermark, 
			  proj_from, proj_matrix, view_matrix, view_proj_matrix, light_proj_matrix, light_view_matrix, light_view_proj_matrix,
			  spot_proj_matrix, spot_view_matrix, spot_view_proj_matrix, proj_depth_near, proj_depth_far, render_proj_from,
			  render_active;
	
	globalvar render_light_amount, render_light_from, render_light_to, render_light_near, render_light_far, render_light_fov,
			  render_light_color, render_light_strength, render_light_fade_size, render_light_spot_sharpness, render_shadow_matrix,
			  render_sun_matrix, render_sun_direction, render_sun_near, render_sun_far, render_light_offset, render_shadow_from,
			  render_spot_matrix;
	
	globalvar render_effects, render_effects_done, render_effects_list, render_effects_progress, render_camera_bloom, render_camera_dof,
			  render_glow, render_glow_falloff, render_camera_ca, render_camera_distort, render_camera_color_correction, render_camera_grain,
			  render_camera_vignette, render_aa, render_overlay, render_camera_lens_dirt, render_camera_lens_dirt_bloom, render_camera_lens_dirt_glow,
			  render_volumetric_fog, render_ssao, render_shadows, render_indirect, render_reflections, render_quality;
	
	globalvar render_shadows_buffer, render_shadows_size, render_shadows_matrix, render_samples;
	
	globalvar render_pass_surf;
	
	log("Render init")
	
	gpu_set_blendenable(true)
	gpu_set_blendmode(bm_normal)
	gpu_set_alphatestenable(true)
	gpu_set_alphatestref(0)
	gpu_set_texfilter(false)
	gpu_set_tex_mip_enable(mip_off)
	gpu_set_tex_mip_filter(tf_linear)
	gpu_set_texrepeat(true)
	gpu_set_ztestenable(false)
	gpu_set_zwriteenable(false)
	render_set_culling(true)
	gpu_set_tex_max_mip(4)
	
	render_view_current = null
	render_width = 1
	render_height = 1
	render_ratio = 1
	render_camera = null
	
	render_effects = false
	render_effects_done = false
	render_effects_list = ds_list_create()
	render_effects_progress = 0
	render_quality = e_view_mode.FLAT
	
	render_volumetric_fog = false
	render_camera_bloom = false
	render_camera_dof = false
	render_glow = false
	render_glow_falloff = false
	render_camera_ca = false
	render_camera_distort = false
	render_camera_color_correction = false
	render_camera_grain = false
	render_camera_vignette = false
	render_aa = false
	render_overlay = false
	render_camera_lens_dirt = true
	render_camera_lens_dirt_bloom = true
	render_camera_lens_dirt_glow = true
	render_ssao = false
	render_shadows = false
	render_indirect = false
	
	render_click_box = vbuffer_create_cube(view_3d_box_size / 2, point2D(0, 0), point2D(1, 1), 1, 1, false, false)
	render_list = ds_list_create()
	render_fog = true
	render_lights = true
	render_particles = true
	render_hidden = false
	render_background = true
	render_watermark = false
	
	render_time = 0
	render_surface_time = 0
	render_active = null
	
	render_target = null
	render_surface[0] = null
	render_surface[1] = null
	render_surface[2] = null
	render_surface[3] = null
	render_surface[4] = null
	render_surface[5] = null
	
	// Shadows
	globalvar render_shadowless_point_list, render_shadowless_point_data, render_shadowless_point_amount, render_surface_sun_buffer, render_surface_sun_color_buffer,
	render_surface_spot_buffer, render_surface_point_buffer;
	
	render_shadowless_point_amount = 0
	render_shadowless_point_list = ds_list_create()
	render_surface_sun_buffer = null
	render_surface_sun_color_buffer = null
	render_surface_spot_buffer = null
	for (var d = 0; d < 6; d++)
		render_surface_point_buffer[d] = null
	
	// SSAO
	globalvar render_ssao_kernel, render_ssao_noise;
	render_ssao_kernel = render_generate_sample_kernel(16)
	render_ssao_noise = null
	
	// DOF
	globalvar render_dof_blades, render_dof_rotation, render_dof_ratio, render_dof_quality, render_dof_samples, render_dof_weight_samples, render_dof_sample_amount;
	render_dof_blades = -1
	render_dof_rotation = -1
	render_dof_ratio = -1
	render_dof_quality = -1
	render_generate_dof_samples(0, 0, 0)
	
	// Grain
	globalvar render_grain_noise;
	render_grain_noise = null
	
	// Indirect lighting
	globalvar render_indirect_kernel, render_indirect_offset;
	render_indirect_kernel = render_generate_sample_kernel(16)
	render_indirect_offset = null
	
	// Volumetric fog
	globalvar render_volumetric_fog_offset;
	render_volumetric_fog_offset = 0
	
	// Effect surfaces
	globalvar render_surface_ssao, render_surface_shadows, render_surface_indirect, render_surface_indirect_expo, render_surface_indirect_dec,
		      render_surface_sun_shadows_expo, render_surface_sun_shadows_dec, render_surface_fog, render_surface_lens, render_surface_post,
			  render_post_index, render_surface_ssr, render_surface_ssr_expo, render_surface_ssr_dec, render_surface_sample_temp1, render_surface_sample_temp2;
	render_surface_ssao = null
	render_surface_shadows = null
	render_surface_sun_shadows_expo = null
	render_surface_sun_shadows_dec = null
	render_surface_fog = null
	render_surface_lens = null
	render_surface_indirect = null
	render_surface_indirect_expo = null
	render_surface_indirect_dec = null
	render_surface_ssr = null
	render_surface_ssr_expo = null
	render_surface_ssr_dec = null
	render_surface_sample_temp1 = null
	render_surface_sample_temp2 = null
	
	globalvar render_surface_sun_volume_expo, render_surface_sun_volume_dec, render_samples_clear;
	render_surface_sun_volume_expo = null
	render_surface_sun_volume_dec = null
	render_samples_clear = false
	
	render_surface_post[0] = null
	render_surface_post[1] = null
	
	render_post_index = 0
	
	// Shadow surf
	render_shadows_buffer = null
	render_samples = 0
	render_shadows_matrix = null
	
	// Render pass surf
	render_pass_surf = null
	
	// Render modes
	globalvar render_mode, render_mode_shader_map, render_shader_obj;
	render_mode_shader_map = ds_map_create()
	render_mode_shader_map[?e_render_mode.CLICK] = shader_replace
	render_mode_shader_map[?e_render_mode.SELECT] = shader_blend
	render_mode_shader_map[?e_render_mode.PREVIEW] = shader_color_fog
	render_mode_shader_map[?e_render_mode.COLOR] = shader_color_fog
	render_mode_shader_map[?e_render_mode.COLOR_FOG] = shader_color_fog
	render_mode_shader_map[?e_render_mode.COLOR_FOG_LIGHTS] = shader_color_fog_lights
	render_mode_shader_map[?e_render_mode.ALPHA_FIX] = shader_alpha_fix
	render_mode_shader_map[?e_render_mode.ALPHA_TEST] = shader_alpha_test
	render_mode_shader_map[?e_render_mode.HIGH_SSAO_DEPTH_NORMAL] = shader_high_ssao_depth_normal
	render_mode_shader_map[?e_render_mode.DEPTH] = shader_depth
	render_mode_shader_map[?e_render_mode.DEPTH_NO_SKY] = shader_depth
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SUN_DEPTH] = shader_depth_ortho
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SPOT_DEPTH] = shader_depth
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_POINT_DEPTH] = shader_depth_point
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SUN] = shader_high_light_sun
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SPOT] = shader_high_light_spot
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_POINT] = shader_high_light_point
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_POINT_SHADOWLESS] = shader_high_light_point_shadowless
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_NIGHT] = shader_high_light_night
	render_mode_shader_map[?e_render_mode.HIGH_FOG] = shader_high_fog
	render_mode_shader_map[?e_render_mode.COLOR_GLOW] = shader_color_glow
	render_mode_shader_map[?e_render_mode.SCENE_TEST] = shader_replace_alpha
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SUN_COLOR] = shader_high_light_color
	render_mode_shader_map[?e_render_mode.HIGH_INDIRECT_DEPTH_NORMAL] = shader_high_indirect_depth_normal
	render_mode_shader_map[?e_render_mode.HIGH_REFLECTIONS_DEPTH_NORMAL] = shader_high_indirect_depth_normal
	render_mode_shader_map[?e_render_mode.MATERIAL] = shader_high_material
}
