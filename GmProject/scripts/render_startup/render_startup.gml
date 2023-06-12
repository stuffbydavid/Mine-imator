/// render_startup()

function render_startup()
{
	globalvar render_view_current, render_width, render_height, render_ratio, render_camera, render_time, render_surface_time,
			  render_prev_color, render_prev_alpha, render_click_box, render_list, render_lights, render_particles, render_hidden,
			  render_background, render_watermark, proj_from, proj_matrix, view_matrix, view_proj_matrix, light_proj_matrix, light_view_matrix,
			  light_view_proj_matrix, spot_proj_matrix, spot_view_matrix, spot_view_proj_matrix, proj_depth_near, proj_depth_far, render_proj_from,
			  render_active, render_repeat, render_world_count, point3D_project_error;
	
	globalvar render_light_from, render_light_to, render_light_near, render_light_far, render_light_fov,
			  render_light_color, render_light_strength, render_light_fade_size, render_light_spot_sharpness, render_shadow_matrix,
			  render_sun_matrix, render_sun_direction, render_sun_near, render_sun_far, render_light_offset, render_shadow_from,
			  render_spot_matrix, render_light_specular_strength, render_light_size;
	
	globalvar render_effects, render_effects_done, render_effects_list, render_effects_progress, render_camera_bloom, render_camera_dof,
			  render_glow, render_glow_falloff, render_camera_ca, render_camera_distort, render_camera_color_correction, render_camera_grain,
			  render_camera_vignette, render_overlay, render_camera_lens_dirt, render_camera_lens_dirt_bloom, render_camera_lens_dirt_glow,
			  render_ssao, render_shadows, render_indirect, render_reflections, render_quality, render_pass,
			  render_tonemapper, render_exposure, render_gamma, render_depth_normals;
	
	globalvar render_matrix, render_samples, render_sample_current, render_samples_done, render_target_size;
	
	globalvar render_blend_prev, render_alpha_prev;
	
	// Update shader_reset_uniforms()
	globalvar shader_uniform_color_ext, shader_uniform_rgb_add, shader_uniform_rgb_sub, shader_uniform_hsb_add,
			  shader_uniform_hsb_sub, shader_uniform_hsb_mul, shader_uniform_mix_color, shader_uniform_mix_percent,
			  shader_uniform_emissive, shader_uniform_metallic, shader_uniform_roughness, shader_uniform_wind,
			  shader_uniform_wind_terrain, shader_uniform_fog, shader_uniform_sss, shader_uniform_sss_red,
			  shader_uniform_sss_green, shader_uniform_sss_blue, shader_uniform_sss_color, shader_uniform_glow, shader_uniform_glow_texture,
			  shader_uniform_glow_color, shader_uniform_wind_strength;
	
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
	render_set_culling(true)
	gpu_set_tex_max_mip(4)
	shader_reset_uniforms()
	
	render_view_current = null
	render_width = 1
	render_height = 1
	render_ratio = 1
	render_camera = null
	
	render_light_specular_strength = 0
	
	render_effects = false
	render_effects_done = false
	render_effects_list = ds_list_create()
	render_effects_progress = 0
	render_quality = e_view_mode.FLAT
	
	render_camera_bloom = false
	render_camera_dof = false
	render_glow = false
	render_glow_falloff = false
	render_camera_ca = false
	render_camera_distort = false
	render_camera_color_correction = false
	render_camera_grain = false
	render_camera_vignette = false
	render_overlay = false
	render_camera_lens_dirt = true
	render_camera_lens_dirt_bloom = true
	render_camera_lens_dirt_glow = true
	render_ssao = false
	render_shadows = false
	render_indirect = false
	render_depth_normals = false
	
	render_click_box = vbuffer_create_cube(view_3d_box_size / 2, point2D(0, 0), point2D(1, 1), 1, 1, false, false)
	render_list = ds_list_create()
	render_lights = true
	render_particles = true
	render_hidden = false
	render_background = true
	render_watermark = false
	
	render_time = 0
	render_surface_time = 0
	render_active = null
	render_repeat = vec3(0)
	
	// Surfaces for rendering
	globalvar render_target, render_surface, render_surface_hdr, render_surface_depth, render_surface_normal, render_surface_emissive, 
			  render_surface_diffuse, render_surface_material, render_surface_shadows, render_surface_specular, render_surface_lens, 
			  render_surface_sample_expo, render_surface_sample_dec, render_surface_sample_alpha, depth_near, depth_far, render_post_index;
			
	render_target = null
	render_surface[0] = null
	render_surface[1] = null
	render_surface[2] = null
	
	render_surface_hdr[0] = null
	render_surface_hdr[1] = null
	render_surface_hdr[2] = null
	
	render_surface_depth = null
	render_surface_normal = null
	render_surface_material = null
	render_surface_emissive = null
	render_surface_diffuse = null
	
	render_surface_shadows = null
	render_surface_specular = null
	
	render_surface_lens = null
	
	render_surface_sample_expo = null
	render_surface_sample_dec = null
	render_surface_sample_alpha = null 
	
	depth_near = clip_near
	depth_far = 5000
	render_post_index = 0
	
	render_world_count = 0
	
	// "Temporal" anti-aliasing
	globalvar taa_matrix, taa_jitter_matrix;
	taa_matrix = MAT_IDENTITY
	taa_jitter_matrix = MAT_IDENTITY
	
	// Alpha hashsing
	globalvar render_alpha_hash, render_alpha_hash_force;
	render_alpha_hash = false
	render_alpha_hash_force = false // If enabled, forces scene objects to use hashing based on render_alpha_hash
	
	// Noise sampling
	globalvar render_sample_noise_texture, render_sample_noise_size, render_sample_noise_texture_array;
	render_sample_noise_texture = null
	render_sample_noise_size = 128
	render_sample_noise_texture_array = []
	
	// Shadows
	globalvar render_shadowless_point_list, render_shadowless_point_data, render_shadowless_point_amount, render_surface_sun_buffer, render_surface_spot_buffer, 
	render_surface_point_buffer, render_surface_point_atlas_buffer;
	
	render_shadowless_point_amount = 0
	render_shadowless_point_list = ds_list_create()
	render_surface_spot_buffer = null
	render_surface_point_buffer = null
	render_surface_point_atlas_buffer = null
	
	// SSAO
	globalvar render_ssao_kernel;
	render_ssao_kernel = render_generate_sample_kernel(12)
	
	// DOF
	globalvar render_dof_samples, render_dof_weight_samples, render_dof_sample_amount;
	
	// Grain
	globalvar render_grain_noise;
	render_grain_noise = null
	
	// Subsurface
	globalvar render_subsurface_size, render_subsurface_kernel, render_blur_kernel;
	render_subsurface_size = (16 * 2) + 1
	render_subsurface_kernel = render_generate_gaussian_kernel(render_subsurface_size)
	render_blur_kernel = render_generate_gaussian_kernel(19)
	
	globalvar render_samples_clear;
	render_samples_clear = false
	
	
	
	// Render samples
	render_samples = 0
	render_sample_current = 0
	render_samples_done = false
	render_matrix = []
	
	// Render pass surf
	render_pass_surf = null
	
	render_blend_prev = null
	render_alpha_prev = null
	
	// Cascades for sun
	globalvar render_cascades_count, render_cascade_ends, render_cascades, render_cascade_debug;
	render_cascades_count = 3
	render_cascade_ends = [0.0, 0.035, 0.15, 1.0]
	render_cascade_debug = 1
	
	for (var i = 0; i < render_cascades_count; i++)
	{
		render_cascades[i] = new frustum()
		render_surface_sun_buffer[i] = null
	}
	
	// Render modes
	globalvar render_mode, render_mode_shader_map, render_shader_obj;
	render_mode = null
	render_mode_shader_map = ds_map_create()
	render_mode_shader_map[?e_render_mode.CLICK] = shader_replace
	render_mode_shader_map[?e_render_mode.SELECT] = shader_blend
	render_mode_shader_map[?e_render_mode.PLACE] = shader_blend
	render_mode_shader_map[?e_render_mode.PREVIEW] = shader_color_fog
	render_mode_shader_map[?e_render_mode.COLOR] = shader_color_fog
	render_mode_shader_map[?e_render_mode.COLOR_FOG] = shader_color_fog
	render_mode_shader_map[?e_render_mode.COLOR_FOG_LIGHTS] = shader_color_fog_lights
	render_mode_shader_map[?e_render_mode.ALPHA_FIX] = shader_alpha_fix
	render_mode_shader_map[?e_render_mode.ALPHA_TEST] = shader_alpha_test
	render_mode_shader_map[?e_render_mode.DEPTH] = shader_depth
	render_mode_shader_map[?e_render_mode.DEPTH_NO_SKY] = shader_depth
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SUN_DEPTH] = shader_depth_ortho
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SPOT_DEPTH] = shader_depth
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_POINT_DEPTH] = shader_depth_point
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SUN] = shader_high_light_sun
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_SPOT] = shader_high_light_spot
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_POINT] = shader_high_light_point
	render_mode_shader_map[?e_render_mode.HIGH_LIGHT_POINT_SHADOWLESS] = shader_high_light_point_shadowless
	render_mode_shader_map[?e_render_mode.HIGH_FOG] = shader_high_fog
	render_mode_shader_map[?e_render_mode.COLOR_GLOW] = shader_color_glow
	render_mode_shader_map[?e_render_mode.SCENE_TEST] = shader_replace_alpha
	render_mode_shader_map[?e_render_mode.AO_MASK] = shader_replace_alpha
	render_mode_shader_map[?e_render_mode.HIGH_DEPTH_NORMAL] = shader_high_depth_normal
	render_mode_shader_map[?e_render_mode.MATERIAL] = shader_high_material
	render_mode_shader_map[?e_render_mode.SUBSURFACE] = shader_high_subsurface
	
	// Init settings
	project_reset_render()
	
	// Check for default render settings file
	if (!file_exists_lib(render_default_file))
	{
		if (!directory_exists_lib(render_directory))
			directory_create_lib(render_directory)
		
		project_save_start(render_default_file, false)
		project_save_render()
		project_save_done()
	
		log("Saved default render settings", render_default_file)
	}
}
