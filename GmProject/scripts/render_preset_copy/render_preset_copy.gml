/// render_preset_copy(to, allsettings)
/// @arg to
/// @arg allsettings
/// @desc Copies the selected settings into the given preset

function render_preset_copy(to, allsettings = false)
{
	var fromset, toset;

	if (has_standard || allsettings)
	{
		fromset = renderer[e_renderer.STANDARD]
		toset = to.renderer[e_renderer.STANDARD]
		to.has_standard = has_standard
		toset.ssao = fromset.ssao
		toset.shadows = fromset.shadows
		toset.shadows_blur_quality = fromset.shadows_blur_quality
		toset.shadows_sun_cascades = fromset.shadows_sun_cascades
		toset.shadows_sun_buffer_size = fromset.shadows_sun_buffer_size
		toset.shadows_spot_buffer_size = fromset.shadows_spot_buffer_size
		toset.shadows_point_buffer_size = fromset.shadows_point_buffer_size
		toset.glow = fromset.glow
		toset.aa = fromset.aa
		toset.aa_power = fromset.aa_power
	}
	
	if (has_realistic || allsettings)
	{
		fromset = renderer[e_renderer.REALISTIC]
		toset = to.renderer[e_renderer.REALISTIC]
		to.has_realistic = has_realistic
		toset.samples = fromset.samples
		toset.ssao = fromset.ssao
		toset.shadows = fromset.shadows
		toset.shadows_sun_cascades = fromset.shadows_sun_cascades
		toset.shadows_sun_buffer_size = fromset.shadows_sun_buffer_size
		toset.shadows_spot_buffer_size = fromset.shadows_spot_buffer_size
		toset.shadows_point_buffer_size = fromset.shadows_point_buffer_size
		toset.shadows_transparent = fromset.shadows_transparent
		toset.subsurface_samples = fromset.subsurface_samples
		toset.indirect = fromset.indirect
		toset.indirect_precision = fromset.indirect_precision
		toset.reflections = fromset.reflections
		toset.reflections_precision = fromset.reflections_precision
		toset.glow = fromset.glow
		toset.glow_falloff = fromset.glow_falloff
		toset.aa = fromset.aa
		toset.aa_power = fromset.aa_power
	}
	
	if (has_fx || allsettings)
	{
		to.has_fx = has_fx
		to.ssao_radius = ssao_radius
		to.ssao_power = ssao_power
		to.ssao_color = ssao_color
		to.ssao_always_visible = ssao_always_visible
		to.glow_radius = glow_radius
		to.glow_intensity = glow_intensity
		to.glint_speed = glint_speed
		to.glint_strength = glint_strength
		to.tonemapper = tonemapper
		to.exposure = exposure
		to.gamma = gamma

		fromset = renderer[e_renderer.STANDARD]
		toset = to.renderer[e_renderer.STANDARD]
		toset.shadows_blur_size = fromset.shadows_blur_size

		fromset = renderer[e_renderer.REALISTIC]
		toset = to.renderer[e_renderer.REALISTIC]
		toset.subsurface_highlight = fromset.subsurface_highlight
		toset.subsurface_highlight_strength = fromset.subsurface_highlight_strength
		toset.indirect_blur_radius = fromset.indirect_blur_radius
		toset.indirect_strength = fromset.indirect_strength
		toset.reflections_thickness = fromset.reflections_thickness
		toset.reflections_fade_amount = fromset.reflections_fade_amount
		toset.glow_falloff_radius = fromset.glow_falloff_radius
		toset.glow_falloff_intensity = fromset.glow_falloff_intensity
	}

	if (has_graphics || allsettings)
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

	if (has_materials || allsettings)
	{
		to.has_materials = has_materials
		to.block_emissive = block_emissive
		to.block_subsurface = block_subsurface
		to.water_reflections = water_reflections
		to.material_maps = material_maps
	}
}
