/// render_preset_event_create()

function render_preset_event_create()
{
	file = ""
	name = ""
	locked = true
	
	render_preset_clear()
	
	// Standard performance settings
	standard_ssao = true
	standard_shadows = true
	standard_shadows_blur_quality = 20
	standard_shadows_sun_buffer_size = 2048
	standard_shadows_spot_buffer_size = 512
	standard_shadows_point_buffer_size = 256
	standard_glow = true
	standard_aa = true
	standard_aa_power = 1
	
	// Realistic performance settings
	realistic_samples = 24
	realistic_ssao = true
	realistic_shadows = true
	realistic_shadows_sun_buffer_size = 2048
	realistic_shadows_spot_buffer_size = 512
	realistic_shadows_point_buffer_size = 256
	realistic_shadows_transparent = false
	realistic_subsurface_samples = 7
	realistic_indirect = true
	realistic_indirect_precision = .3
	realistic_reflections = true
	realistic_reflections_precision = .3
	realistic_glow = true
	realistic_glow_falloff = false
	realistic_aa = true
	realistic_aa_power = 1
	
	// Special effects settings
	ssao_radius = 12
	ssao_power = 1
	ssao_color = c_black
	ssao_always_visible = false
	standard_shadows_blur_size = 1
	realistic_subsurface_highlight = .5
	realistic_subsurface_highlight_strength = 1
	realistic_indirect_blur_radius = 1
	realistic_indirect_strength = 1
	realistic_reflections_fade_amount = 1
	realistic_reflections_thickness = 1
	glow_radius = 1
	glow_intensity = 1
	realistic_glow_falloff_radius = 2
	realistic_glow_falloff_intensity = 1
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