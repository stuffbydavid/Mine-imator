/// render_apply_settings(preset, renderer)

function render_apply_settings(preset, renderer)
{
	if (renderer == e_renderer.STANDARD && preset.has_standard)
	{
		project_render_ssao = preset.standard_ssao
		project_render_shadows = preset.standard_shadows
		project_render_shadows_blur_quality = preset.standard_shadows_blur_quality
		project_render_shadows_sun_buffer_size = preset.standard_shadows_sun_buffer_size
		project_render_shadows_spot_buffer_size = preset.standard_shadows_spot_buffer_size
		project_render_shadows_point_buffer_size = preset.standard_shadows_point_buffer_size
		project_render_glow = preset.standard_glow
		project_render_aa = preset.standard_aa
		project_render_aa_power = preset.standard_aa_power
	}
	
	if (renderer == e_renderer.REALISTIC && preset.has_realistic)
	{
		project_render_samples = preset.realistic_samples
		project_render_ssao = preset.realistic_ssao
		project_render_shadows = preset.realistic_shadows
		project_render_shadows_sun_buffer_size = preset.realistic_shadows_sun_buffer_size
		project_render_shadows_spot_buffer_size = preset.realistic_shadows_spot_buffer_size
		project_render_shadows_point_buffer_size = preset.realistic_shadows_point_buffer_size
		project_render_shadows_transparent = preset.realistic_shadows_transparent
		project_render_subsurface_samples = preset.realistic_subsurface_samples
		project_render_indirect = preset.realistic_indirect
		project_render_indirect_precision = preset.realistic_indirect_precision
		project_render_reflections = preset.realistic_reflections
		project_render_reflections_precision = preset.realistic_reflections_precision
		project_render_glow = preset.realistic_glow
		project_render_glow_falloff = preset.realistic_glow_falloff
		project_render_aa = preset.realistic_aa
		project_render_aa_power = preset.realistic_aa_power
	}
	
	if (renderer == e_renderer.COMMON)
	{
		if (preset.has_fx)
		{
			project_render_ssao_radius = preset.ssao_radius
			project_render_ssao_power = preset.ssao_power
			project_render_ssao_color = preset.ssao_color
			project_render_ssao_always_visible = preset.ssao_always_visible
			project_render_shadows_blur_size = preset.standard_shadows_blur_size
			project_render_subsurface_highlight = preset.realistic_subsurface_highlight
			project_render_subsurface_highlight_strength = preset.realistic_subsurface_highlight_strength
			project_render_indirect_blur_radius = preset.realistic_indirect_blur_radius
			project_render_indirect_strength = preset.realistic_indirect_strength
			project_render_reflections_thickness = preset.realistic_reflections_thickness
			project_render_reflections_fade_amount = preset.realistic_reflections_fade_amount
			project_render_glow_radius = preset.glow_radius
			project_render_glow_intensity = preset.glow_intensity
			project_render_glow_falloff_radius = preset.realistic_glow_falloff_radius
			project_render_glow_falloff_intensity = preset.realistic_glow_falloff_intensity
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