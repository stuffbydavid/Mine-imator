/// render_apply_settings(preset, renderer)

function render_apply_settings(preset, renderer)
{
	if (renderer == e_renderer.STANDARD && preset.has_standard)
	{
		var settings = preset.renderer[e_renderer.STANDARD];
		project_render_ssao = settings.ssao
		project_render_shadows = settings.shadows
		project_render_shadows_blur_quality = settings.shadows_blur_quality
		project_render_shadows_sun_buffer_size = settings.shadows_sun_buffer_size
		project_render_shadows_spot_buffer_size = settings.shadows_spot_buffer_size
		project_render_shadows_point_buffer_size = settings.shadows_point_buffer_size
		project_render_glow = settings.glow
		project_render_aa = settings.aa
		project_render_aa_power = settings.aa_power
	}
	
	if (renderer == e_renderer.REALISTIC && preset.has_realistic)
	{
		var settings = preset.renderer[e_renderer.REALISTIC];
		project_render_samples = settings.samples
		project_render_ssao = settings.ssao
		project_render_shadows = settings.shadows
		project_render_shadows_sun_buffer_size = settings.shadows_sun_buffer_size
		project_render_shadows_spot_buffer_size = settings.shadows_spot_buffer_size
		project_render_shadows_point_buffer_size = settings.shadows_point_buffer_size
		project_render_shadows_transparent = settings.shadows_transparent
		project_render_subsurface_samples = settings.subsurface_samples
		project_render_indirect = settings.indirect
		project_render_indirect_precision = settings.indirect_precision
		project_render_reflections = settings.reflections
		project_render_reflections_precision = settings.reflections_precision
		project_render_glow = settings.glow
		project_render_glow_falloff = settings.glow_falloff
		project_render_aa = settings.aa
		project_render_aa_power = settings.aa_power
	}
	
	if (renderer == e_renderer.COMMON)
	{
		if (preset.has_fx)
		{
			project_render_ssao_radius = preset.ssao_radius
			project_render_ssao_power = preset.ssao_power
			project_render_ssao_color = preset.ssao_color
			project_render_ssao_always_visible = preset.ssao_always_visible
			project_render_shadows_blur_size = preset.renderer[e_renderer.STANDARD].shadows_blur_size
			project_render_subsurface_highlight = preset.renderer[e_renderer.REALISTIC].subsurface_highlight
			project_render_subsurface_highlight_strength = preset.renderer[e_renderer.REALISTIC].subsurface_highlight_strength
			project_render_indirect_blur_radius = preset.renderer[e_renderer.REALISTIC].indirect_blur_radius
			project_render_indirect_strength = preset.renderer[e_renderer.REALISTIC].indirect_strength
			project_render_reflections_thickness = preset.renderer[e_renderer.REALISTIC].reflections_thickness
			project_render_reflections_fade_amount = preset.renderer[e_renderer.REALISTIC].reflections_fade_amount
			project_render_glow_radius = preset.glow_radius
			project_render_glow_intensity = preset.glow_intensity
			project_render_glow_falloff_radius = preset.renderer[e_renderer.REALISTIC].glow_falloff_radius
			project_render_glow_falloff_intensity = preset.renderer[e_renderer.REALISTIC].glow_falloff_intensity
			project_render_glint_speed = preset.glint_speed
			project_render_glint_strength = preset.glint_strength
			project_render_tonemapper = preset.tonemapper
			project_render_exposure = preset.exposure
			project_render_gamma = preset.gamma
		}
	
		if (preset.has_graphics)
		{
			project_render_distance = preset.render_distance
			project_render_texture_filtering = preset.texture_filtering
			project_render_transparent_block_texture_filtering = preset.transparent_block_texture_filtering
			project_render_texture_filtering_level = preset.texture_filtering_level
			texture_set_mipmap_level(project_render_texture_filtering_level)
	
			project_bend_style = preset.bend_style
			project_render_opaque_leaves = preset.opaque_leaves
			project_render_liquid_animation = preset.liquid_animation
			project_render_alpha_mode = preset.alpha_mode
			
			// Update bend meshes
			with (obj_timeline)
			{
				bend_rot_last = vec3(0)
				tl_update_model_shape_bend()
			}
		}
	
		if (preset.has_materials)
		{
			project_render_block_emissive = preset.block_emissive
			project_render_block_subsurface = preset.block_subsurface
			project_render_water_reflections = preset.water_reflections
			project_render_material_maps = preset.material_maps
		}
	}
}
