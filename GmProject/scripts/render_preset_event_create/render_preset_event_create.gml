/// render_preset_event_create()

function render_preset_event_create()
{
	file = ""
	name = ""
	locked = true

	renderer[e_renderer.QUICK] = new_obj(obj_render_preset_renderer)
	renderer[e_renderer.STANDARD] = new_obj(obj_render_preset_renderer)
	renderer[e_renderer.REALISTIC] = new_obj(obj_render_preset_renderer)

	render_preset_clear()

	// Standard renderer settings
	with (renderer[e_renderer.STANDARD])
	{
		ssao = true
		shadows = true
		shadows_blur_quality = 20
		shadows_sun_cascades = 2
		shadows_sun_buffer_size = 2048
		shadows_spot_buffer_size = 512
		shadows_point_buffer_size = 256
		glow = true
		// Standard should support glow_falloff if it's fast enough
		aa = true
		aa_power = 1

		shadows_blur_size = 1
	}

	// Realistic renderer settings
	with (renderer[e_renderer.REALISTIC])
	{
		samples = 24
		ssao = true
		shadows = true
		shadows_sun_cascades = 2
		shadows_sun_buffer_size = 2048
		shadows_spot_buffer_size = 512
		shadows_point_buffer_size = 256
		shadows_transparent = false
		subsurface_samples = 7
		indirect = true
		indirect_precision = .3
		reflections = true
		reflections_precision = .3
		glow = true
		glow_falloff = false
		aa = true
		aa_power = 1

		subsurface_highlight = .5
		subsurface_highlight_strength = 1
		indirect_blur_radius = 1
		indirect_strength = 1
		reflections_fade_amount = 1
		reflections_thickness = 1
		glow_falloff_radius = 2 // Move to common if Standard gets glow falloff
		glow_falloff_intensity = 1
	}

	// Common special effects settings
	ssao_radius = 12
	ssao_power = 1
	ssao_color = c_black
	ssao_always_visible = false
	glow_radius = 1
	glow_intensity = 1
	glint_speed = 1
	glint_strength = 1
	tonemapper = e_tonemapper.NONE
	exposure = 1
	gamma = 2.2

	// Graphics settings
	render_distance = clip_far
	texture_filtering = true
	transparent_block_texture_filtering = false
	texture_filtering_level = 1
	bend_style = "blocky"
	opaque_leaves = false
	liquid_animation = true
	alpha_mode = e_alpha_mode.BLEND

	// Materials settings
	block_emissive = 1
	block_subsurface = 8
	water_reflections = true
	material_maps = false
}
