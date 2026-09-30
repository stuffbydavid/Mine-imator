function shader_startup()
{
	globalvar shader_map, shader_texture_surface, shader_texture_filter_linear, shader_texture_filter_mipmap, shader_check_uniform;
	globalvar shader_texture_width, shader_texture_height, shader_texture_binding, shader_texture_binding_res, shader_texture_binding_pack, shader_texture_binding_surface;
	globalvar shader_blend_color, shader_blend_alpha;
	globalvar shader_clip_x, shader_clip_y, shader_clip_width, shader_clip_height, shader_clip_active;
	
	// Clip
	shader_clip_x = 0
	shader_clip_y = 0
	shader_clip_width = 0
	shader_clip_height = 0
	shader_clip_active = false
	
	// Texture drawing
	globalvar shader_mask;
	shader_mask = false
	
	// Init shaders
	log("Shader init")
	log("shaders_are_supported", string_yes_no(shaders_are_supported()))
	
	var err = false;
	if (!shaders_are_supported())
		err = true
	
	shader_check_uniform = false
	
	// Initialize sampler and uniform list
	shader_startup_samplers()
	shader_startup_uniforms()

	// Compiled?
	if (!err)
	{
		shader_map = ds_map_create()
		
		new_shader("shader_alpha_fix")
		new_shader("shader_alpha_test")
		new_shader("shader_blend")
		new_shader("shader_build_box")
		new_shader("shader_border")
		new_shader("shader_outline")
		new_shader("shader_palette")
		new_shader("shader_color_camera")
		new_shader("shader_color_fog")
		new_shader("shader_color_fog_lights")
		new_shader("shader_depth")
		new_shader("shader_depth_ortho")
		new_shader("shader_depth_point")
		new_shader("shader_draw_texture")
		new_shader("shader_render_pass")
		new_shader("shader_replace")
		new_shader("shader_replace_alpha")
		new_shader("shader_unpremultiply")
		new_shader("shader_high_dof")
		new_shader("shader_high_dof_coc")
		new_shader("shader_high_dof_coc_blur")
		new_shader("shader_high_fog")
		new_shader("shader_high_fog_apply")
		new_shader("shader_high_light_point")
		new_shader("shader_high_light_point_shadowless")
		new_shader("shader_high_light_spot")
		new_shader("shader_high_light_sun")
		new_shader("shader_high_ssao")
		new_shader("shader_high_ssao_blur")
		new_shader("shader_high_bloom_threshold")
		new_shader("shader_add")
		new_shader("shader_blur")
		new_shader("shader_color_correction")
		new_shader("shader_vignette")
		new_shader("shader_noise")
		new_shader("shader_ca")
		new_shader("shader_distort")
		new_shader("shader_high_aa")
		new_shader("shader_high_lighting_apply")
		new_shader("shader_high_samples_unpack")
		new_shader("shader_high_gbuffers")
		
		if (is_cpp())
		{
			new_shader("shader_high_gbuffers_sun")
			new_shader("shader_high_gbuffers_color")
		}
			
		new_shader("shader_high_auxiliary")
		new_shader("shader_high_auxiliary_standard")
		new_shader("shader_place")
		new_shader("shader_high_subsurface_scatter")
		new_shader("shader_high_indirect_blur")
		new_shader("shader_high_reflections_hit")
		new_shader("shader_high_reflections_resolve")
		new_shader("shader_high_indirect_hit")
		new_shader("shader_high_indirect_source")
		new_shader("shader_high_indirect_resolve")
		new_shader("shader_tonemap")
		new_shader("shader_clip")
		
		shader_texture_surface = false
		shader_texture_filter_linear = false
		shader_texture_filter_mipmap = false
		
		shader_texture_width = 0
		shader_texture_height = 0
		shader_texture_binding = null
		shader_texture_binding_res = null
		shader_texture_binding_pack = null
		shader_texture_binding_surface = false
		
		with (obj_shader)
		{
			log(name + " compiled", string_yes_no(shader_is_compiled(shader)))
			
			if (!shader_is_compiled(shader))
			{
				err = true
				break
			}
		}
	}
	
	if (err)
	{
		log("Shader compilation failed")
		log("Try updating your graphics drivers", drivers_url_get())
		if (show_question("Some shaders failed to compile.\nCheck that your graphics drivers are up-to-date and restart Mine-imator.\n\nOpen support article about updating graphics drivers?"))
			open_url(drivers_url_get())
		
		game_end()
		
		return false
	}
	
	// Set special uniforms
	with (shader_map[?shader_border])
	{
		new_shader_uniform(e_uniform.TEX_SIZE)
		new_shader_uniform(e_uniform.COLOR)
	}
	
	with (shader_map[?shader_outline])
	{
		new_shader_uniform(e_uniform.TEX_SIZE)
		new_shader_uniform(e_uniform.OUTLINE_SIZE)
	}
	
	with (shader_map[?shader_palette])
	{
		new_shader_sampler(e_sampler.PALETTE)
		new_shader_sampler(e_sampler.PALETTE_KEY)
		
		new_shader_uniform(e_uniform.PALETTE_SIZE)
	}
	
	with (shader_map[?shader_color_camera])
	{
		shader_color_uniforms()
		
		new_shader_uniform(e_uniform.BRIGHTNESS)
	}
	
	with (shader_map[?shader_color_fog])
	{
		shader_color_uniforms()
		
		new_shader_uniform(e_uniform.FOG_PASS)
		new_shader_uniform(e_uniform.REPLACE_COLOR)
		new_shader_uniform(e_uniform.TONEMAPPER)
		new_shader_uniform(e_uniform.EXPOSURE)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_color_fog_lights])
	{
		shader_material_uniforms()
		
		new_shader_sampler(e_sampler.GLINT_TEXTURE)
		
		new_shader_uniform(e_uniform.GLINT_OFFSET)
		new_shader_uniform(e_uniform.GLINT_SIZE)
		new_shader_uniform(e_uniform.GLINT_ENABLED)
		new_shader_uniform(e_uniform.GLINT_STRENGTH)
		new_shader_uniform(e_uniform.IS_GROUND)
		new_shader_uniform(e_uniform.IS_SKY)
		new_shader_uniform(e_uniform.LIGHT_AMOUNT)
		new_shader_uniform(e_uniform.SUN_DIRECTION)
		new_shader_uniform(e_uniform.LIGHT_DATA)
		new_shader_uniform(e_uniform.AMBIENT_COLOR)
		new_shader_uniform(e_uniform.FALLBACK_COLOR)
		new_shader_uniform(e_uniform.TONEMAPPER)
		new_shader_uniform(e_uniform.EXPOSURE)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_depth])
	{
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.CAMERA_DEPTH)
	}
	
	with (shader_map[?shader_depth_point])
	{
		new_shader_uniform(e_uniform.EYE)
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
	}
	
	with (shader_map[?shader_draw_texture])
	{
		new_shader_uniform(e_uniform.MASK)
		new_shader_uniform(e_uniform.CLIP_ENABLED)
		new_shader_uniform(e_uniform.CLIP_BOX)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
	}
	
	with (shader_map[?shader_render_pass])
		new_shader_uniform(e_uniform.CHANNEL)
	
	with (shader_map[?shader_replace])
		new_shader_uniform(e_uniform.REPLACE_COLOR)
	
	with (shader_map[?shader_replace_alpha])
		new_shader_uniform(e_uniform.REPLACE_COLOR)

	with (shader_map[?shader_place])
	{
		new_shader_uniform(e_uniform.REPLACE_COLOR)
		new_shader_uniform(e_uniform.GM_DEPTH)
		new_shader_uniform(e_uniform.IS_BLOCK)
	}
	
	with (shader_map[?shader_high_dof])
	{
		new_shader_sampler(e_sampler.BLUR_BUFFER)
		new_shader_sampler(e_sampler.NOISE_BUFFER)
		
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.BLUR_SIZE)
		new_shader_uniform(e_uniform.BIAS)
		new_shader_uniform(e_uniform.THRESHOLD)
		new_shader_uniform(e_uniform.GAIN)
		new_shader_uniform(e_uniform.FRINGE)
		new_shader_uniform(e_uniform.FRINGE_OFFSET_RED)
		new_shader_uniform(e_uniform.FRINGE_OFFSET_GREEN)
		new_shader_uniform(e_uniform.FRINGE_OFFSET_BLUE)
		new_shader_uniform(e_uniform.SAMPLE_AMOUNT)
		new_shader_uniform(e_uniform.SAMPLES)
		new_shader_uniform(e_uniform.WEIGHT_SAMPLES)
		new_shader_uniform(e_uniform.AREA_SAMPLES)
		new_shader_uniform(e_uniform.BLADE_AMOUNT)
		new_shader_uniform(e_uniform.BLADE_ROTATION)
		new_shader_uniform(e_uniform.BLUR_RATIO)
		new_shader_uniform(e_uniform.BLADE_ROUNDING)
		new_shader_uniform(e_uniform.BLADE_STRETCH)
		new_shader_uniform(e_uniform.PIXEL_ROTATION)
		new_shader_uniform(e_uniform.NOISE_SIZE)
	}
	
	with (shader_map[?shader_high_dof_coc])
	{
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		
		new_shader_uniform(e_uniform.DEPTH)
		new_shader_uniform(e_uniform.RANGE)
		new_shader_uniform(e_uniform.FADE_SIZE)
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
	}
	
	with (shader_map[?shader_high_dof_coc_blur])
	{
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.PIXEL_CHECK)
	}
	
	with (shader_map[?shader_high_fog])
	{
		new_shader_uniform(e_uniform.CAMERA_POS)
	}
	
	with (shader_map[?shader_high_fog_apply])
	{
		new_shader_sampler(e_sampler.FOG_BUFFER)
		
		new_shader_uniform(e_uniform.FOG_COLOR)
		new_shader_uniform(e_uniform.BACKGROUND_BRIGHTNESS)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_high_light_point])
	{
		shader_material_uniforms()
		
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		
		new_shader_uniform(e_uniform.IS_SKY)
		new_shader_uniform(e_uniform.LIGHT_POSITION)
		new_shader_uniform(e_uniform.LIGHT_COLOR)
		new_shader_uniform(e_uniform.LIGHT_STRENGTH)
		new_shader_uniform(e_uniform.LIGHT_NEAR)
		new_shader_uniform(e_uniform.LIGHT_FAR)
		new_shader_uniform(e_uniform.LIGHT_FADE_SIZE)
		new_shader_uniform(e_uniform.LIGHT_REALISTIC_FALLOFF)
		new_shader_uniform(e_uniform.DEPTH_BUFFER_SIZE)
		new_shader_uniform(e_uniform.SHADOW_POSITION)
		new_shader_uniform(e_uniform.LIGHT_SPECULAR)
		new_shader_uniform(e_uniform.LIGHT_SIZE)
		new_shader_uniform(e_uniform.SHADOW_RADIUS)
		new_shader_uniform(e_uniform.SHADOW_BLUR_QUALITY)
		new_shader_uniform(e_uniform.PCSS_KERNEL)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_high_light_point_shadowless])
	{
		shader_material_uniforms()
		
		new_shader_uniform(e_uniform.IS_SKY)
		new_shader_uniform(e_uniform.LIGHT_AMOUNT)
		new_shader_uniform(e_uniform.LIGHT_DATA)
		new_shader_uniform(e_uniform.LIGHT_SPECULAR)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_high_light_spot])
	{
		shader_material_uniforms()
		
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		
		new_shader_uniform(e_uniform.IS_SKY)
		new_shader_uniform(e_uniform.LIGHT_MATRIX)
		new_shader_uniform(e_uniform.SHADOW_MATRIX)
		new_shader_uniform(e_uniform.DEPTH_BUFFER_SIZE)
		new_shader_uniform(e_uniform.LIGHT_POSITION)
		new_shader_uniform(e_uniform.LIGHT_COLOR)
		new_shader_uniform(e_uniform.LIGHT_STRENGTH)
		new_shader_uniform(e_uniform.LIGHT_NEAR)
		new_shader_uniform(e_uniform.LIGHT_FAR)
		new_shader_uniform(e_uniform.LIGHT_FADE_SIZE)
		new_shader_uniform(e_uniform.LIGHT_REALISTIC_FALLOFF)
		new_shader_uniform(e_uniform.LIGHT_SPOT_SHARPNESS)
		new_shader_uniform(e_uniform.LIGHT_SPECULAR)
		new_shader_uniform(e_uniform.LIGHT_SIZE)
		new_shader_uniform(e_uniform.SHADOW_RADIUS)
		new_shader_uniform(e_uniform.SHADOW_BLUR_QUALITY)
		new_shader_uniform(e_uniform.PCSS_KERNEL)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.GAMMA)
	}

	with (shader_map[?shader_high_ssao])
	{
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		new_shader_sampler(e_sampler.NORMAL_BUFFER)
		new_shader_sampler(e_sampler.MATERIAL_BUFFER)
		new_shader_sampler(e_sampler.NOISE_BUFFER)
		
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.PROJ_MATRIX)
		new_shader_uniform(e_uniform.PROJ_MATRIX_INV)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.NOISE_SIZE)
		new_shader_uniform(e_uniform.KERNEL)
		new_shader_uniform(e_uniform.RADIUS)
		new_shader_uniform(e_uniform.POWER)
		new_shader_uniform(e_uniform.COLOR)
	}
	
	with (shader_map[?shader_high_ssao_blur])
	{
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		new_shader_sampler(e_sampler.NORMAL_BUFFER)
		
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.PROJ_MATRIX_INV)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.PIXEL_CHECK)
	}

	with (shader_map[?shader_high_bloom_threshold])
	{
		new_shader_uniform(e_uniform.THRESHOLD)
		new_shader_uniform(e_uniform.TRANSITION)
	}
	
	with (shader_map[?shader_add])
	{
		new_shader_sampler(e_sampler.ADD_TEXTURE)
		
		new_shader_uniform(e_uniform.AMOUNT)
		new_shader_uniform(e_uniform.POWER)
		new_shader_uniform(e_uniform.ADD_TEXEL_SIZE)
		new_shader_uniform(e_uniform.TENT_FILTER)
		new_shader_uniform(e_uniform.AFFECT_ALPHA)
	}
	
	with (shader_map[?shader_blur])
	{
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.RADIUS)
		new_shader_uniform(e_uniform.DIRECTION)
		new_shader_uniform(e_uniform.CLAMP_EDGES)
		new_shader_uniform(e_uniform.KERNEL)
		new_shader_uniform(e_uniform.SAMPLES)
	}
	
	with (shader_map[?shader_color_correction])
	{
		new_shader_uniform(e_uniform.CONTRAST)
		new_shader_uniform(e_uniform.BRIGHTNESS)
		new_shader_uniform(e_uniform.SATURATION)
		new_shader_uniform(e_uniform.VIBRANCE)
		new_shader_uniform(e_uniform.COLOR_BURN)
	}
	
	with (shader_map[?shader_vignette])
	{
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.RADIUS)
		new_shader_uniform(e_uniform.SOFTNESS)
		new_shader_uniform(e_uniform.STRENGTH)
		new_shader_uniform(e_uniform.COLOR)
	}
	
	with (shader_map[?shader_noise])
	{
		new_shader_sampler(e_sampler.NOISE_BUFFER)
		
		new_shader_uniform(e_uniform.NOISE_SIZE)
		new_shader_uniform(e_uniform.STRENGTH)
		new_shader_uniform(e_uniform.SATURATION)
		new_shader_uniform(e_uniform.SIZE)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
	}
	
	with (shader_map[?shader_ca])
	{
		new_shader_uniform(e_uniform.BLUR_AMOUNT)
		new_shader_uniform(e_uniform.COLOR_OFFSET)
		new_shader_uniform(e_uniform.DISTORT_CHANNELS)
	}
	
	with (shader_map[?shader_high_aa])
	{
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.POWER)
	}
	
	with (shader_map[?shader_distort])
	{
		new_shader_uniform(e_uniform.DISTORT_AMOUNT)
		new_shader_uniform(e_uniform.REPEAT_IMAGE)
		new_shader_uniform(e_uniform.ZOOM_AMOUNT)
	}
	
	with (shader_map[?shader_high_lighting_apply])
	{
		new_shader_sampler(e_sampler.SHADOWS)
		new_shader_sampler(e_sampler.SSAO)
		new_shader_sampler(e_sampler.SPECULAR)
		new_shader_sampler(e_sampler.MASK)
		new_shader_sampler(e_sampler.EMISSIVE)
		new_shader_sampler(e_sampler.MATERIAL_BUFFER)
		new_shader_sampler(e_sampler.DIFFUSE_BUFFER)
		new_shader_sampler(e_sampler.FOG_BUFFER)
		
		new_shader_uniform(e_uniform.SHADOWS_ENABLED)
		new_shader_uniform(e_uniform.SSAO_ENABLED)
		new_shader_uniform(e_uniform.SSAO_ALWAYS_VISIBLE)
		new_shader_uniform(e_uniform.SPECULAR_ENABLED)
		new_shader_uniform(e_uniform.AMBIENT_COLOR)
		new_shader_uniform(e_uniform.REFLECTIONS_ENABLED)
		new_shader_uniform(e_uniform.FALLBACK_COLOR)
		new_shader_uniform(e_uniform.FOG_COLOR)
		new_shader_uniform(e_uniform.FOG_APPLY)
		new_shader_uniform(e_uniform.FALLBACK_ONLY)
		new_shader_uniform(e_uniform.GAMMA)
		new_shader_uniform(e_uniform.BACKGROUND_BRIGHTNESS)
		new_shader_uniform(e_uniform.PROJ_MATRIX_INV)
		new_shader_uniform(e_uniform.VIEW_MATRIX_INV)
		new_shader_uniform(e_uniform.FOG)
		new_shader_uniform(e_uniform.FOG_ENABLED)
	}
	
	with (shader_map[?shader_high_samples_unpack])
	{
		new_shader_sampler(e_sampler.SAMPLES)
		
		new_shader_uniform(e_uniform.SAMPLES_STRENGTH)
		new_shader_uniform(e_uniform.RENDER_BACKGROUND)
	}
	
	var common1 = [ shader_high_gbuffers ];
	var common2 = [ shader_high_light_sun ];
	
	if (is_cpp())
	{
		array_add(common1, shader_high_gbuffers_sun)
		array_add(common2, shader_high_gbuffers_sun)
		array_add(common1, shader_high_gbuffers_color)
		array_add(common2, shader_high_gbuffers_color)
	}
	
	for (var i = 0; i < array_length(common1); i++)
	{
		with (shader_map[?common1[i]])
		{
			shader_material_uniforms()

			new_shader_sampler(e_sampler.GLINT_TEXTURE)

			new_shader_uniform(e_uniform.GLINT_PASS)
			new_shader_uniform(e_uniform.GAMMA)
			new_shader_uniform(e_uniform.GLINT_OFFSET)
			new_shader_uniform(e_uniform.GLINT_SIZE)
			new_shader_uniform(e_uniform.GLINT_ENABLED)
			new_shader_uniform(e_uniform.GLINT_STRENGTH)

			new_shader_uniform(e_uniform.IS_SKY)
			new_shader_uniform(e_uniform.SSAO)
			new_shader_uniform(e_uniform.NEAR)
			new_shader_uniform(e_uniform.FAR)
			
			if (common1[i] = shader_high_gbuffers_color)
				new_shader_uniform(e_uniform.REPLACE_COLOR)
		}
		
		with (shader_map[?common2[i]])
		{
			if (common2[i] = shader_high_light_sun)
				shader_material_uniforms()

			new_shader_sampler(e_sampler.DEPTH_BUFFER0)
			new_shader_sampler(e_sampler.DEPTH_BUFFER1)
			new_shader_sampler(e_sampler.DEPTH_BUFFER2)

			new_shader_uniform(e_uniform.IS_SKY)
			new_shader_uniform(e_uniform.LIGHT_DIRECTION)
			new_shader_uniform(e_uniform.LIGHT_COLOR)
			new_shader_uniform(e_uniform.LIGHT_STRENGTH)
			new_shader_uniform(e_uniform.SUN_NEAR)
			new_shader_uniform(e_uniform.SUN_FAR)
			new_shader_uniform(e_uniform.CASCADE_WORLD_SIZE)
			new_shader_uniform(e_uniform.LIGHT_SPECULAR)
			new_shader_uniform(e_uniform.SUN_ANGULAR_RADIUS)
			new_shader_uniform(e_uniform.LIGHT_MAT_BIAS_MVP)
			new_shader_uniform(e_uniform.CASCADE_END_CLIP_SPACE)
			new_shader_uniform(e_uniform.CASCADE_COUNT)
			new_shader_uniform(e_uniform.SHADOW_BLUR_QUALITY)
			new_shader_uniform(e_uniform.PCSS_KERNEL)
			new_shader_uniform(e_uniform.SUN_SHADOW_DISTANCE)
			new_shader_uniform(e_uniform.SUN_SHADOW_SCALE)
			new_shader_uniform(e_uniform.DEPTH_BUFFER_SIZE)
			new_shader_uniform(e_uniform.SCREEN_SIZE)
			new_shader_uniform(e_uniform.GAMMA)
		}
	}

	with (shader_map[?shader_high_auxiliary])
	{
		shader_material_uniforms()

		new_shader_uniform(e_uniform.GLOW)
		new_shader_uniform(e_uniform.GLOW_TEXTURE)
		new_shader_uniform(e_uniform.GLOW_COLOR)
		new_shader_uniform(e_uniform.ONLY_RENDER_GLOW)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_high_auxiliary_standard])
	{
		shader_color_uniforms()
		
		new_shader_uniform(e_uniform.GLOW_PASS)
		new_shader_uniform(e_uniform.GLOW_TEXTURE)
		new_shader_uniform(e_uniform.GLOW_COLOR)
		new_shader_uniform(e_uniform.ONLY_RENDER_GLOW)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_high_subsurface_scatter])
	{
		new_shader_sampler(e_sampler.SSS_BUFFER)
		new_shader_sampler(e_sampler.SSS_RANGE_BUFFER)
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		new_shader_sampler(e_sampler.DIRECT)
		new_shader_sampler(e_sampler.NOISE_BUFFER)
		
		new_shader_uniform(e_uniform.PROJ_MATRIX)
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.SAMPLES)
		new_shader_uniform(e_uniform.KERNEL)
		new_shader_uniform(e_uniform.NOISE_SIZE)
	}
	
	with (shader_map[?shader_high_indirect_hit])
	{
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		new_shader_sampler(e_sampler.NORMAL_BUFFER)
		new_shader_sampler(e_sampler.NOISE_BUFFER)
		new_shader_sampler(e_sampler.MATERIAL_BUFFER)
		
		new_shader_uniform(e_uniform.NOISE_SIZE)
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.PROJ_MATRIX)
		new_shader_uniform(e_uniform.PROJ_MATRIX_INV)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.PRECISION)
		new_shader_uniform(e_uniform.THICKNESS)
		
		new_shader_uniform(e_uniform.RAY_DIRECTION)
		new_shader_uniform(e_uniform.RAY_DISTANCE)
	}
	
	with (shader_map[?shader_high_reflections_hit])
	{
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		new_shader_sampler(e_sampler.NORMAL_BUFFER)
		new_shader_sampler(e_sampler.NOISE_BUFFER)
		new_shader_sampler(e_sampler.MATERIAL_BUFFER)
		
		new_shader_uniform(e_uniform.NOISE_SIZE)
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.PROJ_MATRIX)
		new_shader_uniform(e_uniform.PROJ_MATRIX_INV)
		new_shader_uniform(e_uniform.VIEW_MATRIX_INV)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.FOG)
		new_shader_uniform(e_uniform.FOG_ENABLED)
		new_shader_uniform(e_uniform.PRECISION)
		new_shader_uniform(e_uniform.THICKNESS)
		
		new_shader_uniform(e_uniform.RAY_DIRECTION)
		new_shader_uniform(e_uniform.RAY_DISTANCE)
	}
	
	with (shader_map[?shader_high_reflections_resolve])
	{
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		new_shader_sampler(e_sampler.NORMAL_BUFFER)
		new_shader_sampler(e_sampler.MATERIAL_BUFFER)
		new_shader_sampler(e_sampler.SCENE_BUFFER)
		new_shader_sampler(e_sampler.METALLIC_BUFFER)
		
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.PROJ_MATRIX_INV)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.RAY_DATA_SIZE)
		new_shader_uniform(e_uniform.SKY_COLOR)
		new_shader_uniform(e_uniform.FOG_COLOR)
		new_shader_uniform(e_uniform.FADE_AMOUNT)
		new_shader_uniform(e_uniform.GAMMA)
		new_shader_uniform(e_uniform.RAY_DISTANCE)
		new_shader_uniform(e_uniform.BACKGROUND_BRIGHTNESS)
		new_shader_uniform(e_uniform.SAMPLE_AMOUNT)
		new_shader_uniform(e_uniform.SAMPLES)
	}
	
	with (shader_map[?shader_high_indirect_resolve])
	{
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		new_shader_sampler(e_sampler.NORMAL_BUFFER)
		new_shader_sampler(e_sampler.MATERIAL_BUFFER)
		new_shader_sampler(e_sampler.SOURCE_BUFFER)
		
		new_shader_uniform(e_uniform.RAY_DATA_SIZE)
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.PROJ_MATRIX_INV)
		new_shader_uniform(e_uniform.STRENGTH)
		new_shader_uniform(e_uniform.SAMPLE_AMOUNT)
		new_shader_uniform(e_uniform.SAMPLES)
	}
	
	with (shader_map[?shader_high_indirect_source])
	{
		new_shader_sampler(e_sampler.NORMAL_BUFFER)
		new_shader_sampler(e_sampler.LIGHT_BUFFER)
		new_shader_sampler(e_sampler.PREVIOUS_BUFFER)
		
		new_shader_uniform(e_uniform.PREVIOUS_AMOUNT)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_high_indirect_blur])
	{
		new_shader_sampler(e_sampler.DEPTH_BUFFER)
		new_shader_sampler(e_sampler.NORMAL_BUFFER)
		new_shader_sampler(e_sampler.NOISE_BUFFER)
		new_shader_sampler(e_sampler.MATERIAL_BUFFER)
		
		new_shader_uniform(e_uniform.SCREEN_SIZE)
		new_shader_uniform(e_uniform.NOISE_SIZE)
		new_shader_uniform(e_uniform.NEAR)
		new_shader_uniform(e_uniform.FAR)
		new_shader_uniform(e_uniform.PROJ_MATRIX_INV)
		new_shader_uniform(e_uniform.SAMPLES)
		new_shader_uniform(e_uniform.BLUR_SIZE)
	}
	
	with (shader_map[?shader_tonemap])
	{
		new_shader_uniform(e_uniform.TONEMAPPER)
		new_shader_uniform(e_uniform.EXPOSURE)
		new_shader_uniform(e_uniform.GAMMA)
	}
	
	with (shader_map[?shader_clip])
	{
		new_shader_uniform(e_uniform.BOX)
		new_shader_uniform(e_uniform.SCREEN_SIZE)
	}
	
	return true
}
