/// render_preset_copy(to, all)
/// @arg to
/// @arg all
/// @desc Copies the selected settings into the given preset

function render_preset_copy(to, all = false)
{
	if (has_standard || all)
	{
		to.has_standard = has_standard
		to.standard_ssao = standard_ssao
		to.standard_shadows = standard_shadows
		to.standard_shadows_blur_quality = standard_shadows_blur_quality
		to.standard_shadows_sun_buffer_size = standard_shadows_sun_buffer_size
		to.standard_shadows_spot_buffer_size = standard_shadows_spot_buffer_size
		to.standard_shadows_point_buffer_size = standard_shadows_point_buffer_size
		to.standard_glow = standard_glow
		to.standard_aa = standard_aa
		to.standard_aa_power = standard_aa_power
	}
	
	if (has_realistic || all)
	{
		to.has_realistic = has_realistic
		to.realistic_samples = realistic_samples
		to.realistic_ssao = realistic_ssao
		to.realistic_shadows = realistic_shadows
		to.realistic_shadows_sun_buffer_size = realistic_shadows_sun_buffer_size
		to.realistic_shadows_spot_buffer_size = realistic_shadows_spot_buffer_size
		to.realistic_shadows_point_buffer_size = realistic_shadows_point_buffer_size
		to.realistic_shadows_transparent = realistic_shadows_transparent
		to.realistic_subsurface_samples = realistic_subsurface_samples
		to.realistic_indirect = realistic_indirect
		to.realistic_indirect_precision = realistic_indirect_precision
		to.realistic_reflections = realistic_reflections
		to.realistic_reflections_precision = realistic_reflections_precision
		to.realistic_glow = realistic_glow
		to.realistic_glow_falloff = realistic_glow_falloff
		to.realistic_aa = realistic_aa
		to.realistic_aa_power = realistic_aa_power
	}
	
	if (has_fx || all)
	{
		to.has_fx = has_fx
		to.ssao_radius = ssao_radius
		to.ssao_power = ssao_power
		to.ssao_color = ssao_color
		to.ssao_always_visible = ssao_always_visible
		to.standard_shadows_blur_size = standard_shadows_blur_size
		to.realistic_subsurface_highlight = realistic_subsurface_highlight
		to.realistic_subsurface_highlight_strength = realistic_subsurface_highlight_strength
		to.realistic_indirect_blur_radius = realistic_indirect_blur_radius
		to.realistic_indirect_strength = realistic_indirect_strength
		to.realistic_reflections_thickness = realistic_reflections_thickness
		to.realistic_reflections_fade_amount = realistic_reflections_fade_amount
		to.glow_radius = glow_radius
		to.glow_intensity = glow_intensity
		to.realistic_glow_falloff_radius = realistic_glow_falloff_radius
		to.realistic_glow_falloff_intensity = realistic_glow_falloff_intensity
		to.glint_speed = glint_speed
		to.glint_strength = glint_strength
		to.tonemapper = tonemapper
		to.exposure = exposure
		to.gamma = gamma
	}

	if (has_graphics || all)
	{
		to.has_graphics = has_graphics
		to.render_distance = render_distance
		to.texture_filtering = texture_filtering
		to.transparent_block_texture_filtering = transparent_block_texture_filtering
		to.texture_filtering_level = texture_filtering_level
		to.bend_style = bend_style
		to.opaque_leaves = opaque_leaves
		to.liquid_animation = liquid_animation
		to.alpha_mode = alpha_mode
	}

	if (has_materials || all)
	{
		to.has_materials = has_materials
		to.block_emissive = block_emissive
		to.block_subsurface = block_subsurface
		to.water_reflections = water_reflections
		to.material_maps = material_maps
	}
}
