/// render_preset_equals(obj, renderer, all)

function render_preset_equals(obj, renderer, all)
{
	var renderermatch, effectsmatch, graphicsmatch, materialsmatch;
	renderermatch = false
	
	if (renderer == e_renderer.STANDARD && has_standard)
		renderermatch = (
			obj.has_standard &&
			standard_ssao = obj.standard_ssao &&
			standard_shadows = obj.standard_shadows &&
			standard_shadows_blur_quality = obj.standard_shadows_blur_quality &&
			standard_shadows_sun_buffer_size = obj.standard_shadows_sun_buffer_size &&
			standard_shadows_spot_buffer_size = obj.standard_shadows_spot_buffer_size &&
			standard_shadows_point_buffer_size = obj.standard_shadows_point_buffer_size &&
			standard_glow = obj.standard_glow &&
			standard_aa = obj.standard_aa &&
			standard_aa_power = obj.standard_aa_power
		)
	
	if (renderer == e_renderer.REALISTIC && has_realistic)
		renderermatch = (
			obj.has_realistic &&
			realistic_samples = obj.realistic_samples &&
			realistic_ssao = obj.realistic_ssao &&
			realistic_shadows = obj.realistic_shadows &&
			realistic_shadows_sun_buffer_size = obj.realistic_shadows_sun_buffer_size &&
			realistic_shadows_spot_buffer_size = obj.realistic_shadows_spot_buffer_size &&
			realistic_shadows_point_buffer_size = obj.realistic_shadows_point_buffer_size &&
			realistic_shadows_transparent = obj.realistic_shadows_transparent &&
			realistic_subsurface_samples = obj.realistic_subsurface_samples &&
			realistic_indirect = obj.realistic_indirect &&
			realistic_indirect_precision = obj.realistic_indirect_precision &&
			realistic_reflections = obj.realistic_reflections &&
			realistic_reflections_precision = obj.realistic_reflections_precision &&
			realistic_glow = obj.realistic_glow &&
			realistic_glow_falloff = obj.realistic_glow_falloff &&
			realistic_aa = obj.realistic_aa &&
			realistic_aa_power = obj.realistic_aa_power
		)
	
	if (!all)
		return renderermatch
		
	effectsmatch = (
		has_fx = obj.has_fx &&
		ssao_radius = obj.ssao_radius &&
		ssao_power = obj.ssao_power &&
		ssao_color = obj.ssao_color &&
		ssao_always_visible = obj.ssao_always_visible &&
		standard_shadows_blur_size = obj.standard_shadows_blur_size &&
		realistic_subsurface_highlight = obj.realistic_subsurface_highlight &&
		realistic_subsurface_highlight_strength = obj.realistic_subsurface_highlight_strength &&
		realistic_indirect_blur_radius = obj.realistic_indirect_blur_radius &&
		realistic_indirect_strength = obj.realistic_indirect_strength &&
		realistic_reflections_fade_amount = obj.realistic_reflections_fade_amount &&
		realistic_reflections_thickness = obj.realistic_reflections_thickness &&
		glow_radius = obj.glow_radius &&
		glow_intensity = obj.glow_intensity &&
		realistic_glow_falloff_radius = obj.realistic_glow_falloff_radius &&
		realistic_glow_falloff_intensity = obj.realistic_glow_falloff_intensity &&
		glint_speed = obj.glint_speed &&
		glint_strength = obj.glint_strength &&
		tonemapper = obj.tonemapper &&
		exposure = obj.exposure &&
		gamma = obj.gamma
	)

	graphicsmatch = (
		has_graphics = obj.has_graphics &&
		render_distance = obj.render_distance &&
		texture_filtering = obj.texture_filtering &&
		transparent_block_texture_filtering = obj.transparent_block_texture_filtering &&
		texture_filtering_level = obj.texture_filtering_level &&
		bend_style = obj.bend_style &&
		opaque_leaves = obj.opaque_leaves &&
		liquid_animation = obj.liquid_animation &&
		alpha_mode = obj.alpha_mode
	)
	
	materialsmatch = (
		has_materials = obj.has_materials &&
		block_emissive = obj.block_emissive &&
		block_subsurface = obj.block_subsurface &&
		water_reflections = obj.water_reflections &&
		material_maps = obj.material_maps
	)
	
	return (renderermatch && effectsmatch && graphicsmatch && materialsmatch)
}