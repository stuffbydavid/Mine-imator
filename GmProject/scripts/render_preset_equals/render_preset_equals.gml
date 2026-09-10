/// render_preset_equals(obj, renderer, allsettings)

function render_preset_equals(obj, renderer, allsettings)
{
	var match, set, objset;
	match = false

	if (renderer == e_renderer.STANDARD && has_standard)
	{
		set = self.renderer[renderer]
		objset = obj.renderer[renderer]
		match = (
			obj.has_standard &&
			set.ssao = objset.ssao &&
			set.shadows = objset.shadows &&
			set.shadows_blur_quality = objset.shadows_blur_quality &&
			set.shadows_sun_cascades = objset.shadows_sun_cascades &&
			set.shadows_sun_buffer_size = objset.shadows_sun_buffer_size &&
			set.shadows_spot_buffer_size = objset.shadows_spot_buffer_size &&
			set.shadows_point_buffer_size = objset.shadows_point_buffer_size &&
			set.glow = objset.glow &&
			set.aa = objset.aa &&
			set.aa_power = objset.aa_power
		)
	}

	if (renderer == e_renderer.REALISTIC && has_realistic)
	{
		set = self.renderer[renderer]
		objset = obj.renderer[renderer]
		match = (
			obj.has_realistic &&
			set.samples = objset.samples &&
			set.ssao = objset.ssao &&
			set.shadows = objset.shadows &&
			set.shadows_sun_cascades = objset.shadows_sun_cascades &&
			set.shadows_sun_buffer_size = objset.shadows_sun_buffer_size &&
			set.shadows_spot_buffer_size = objset.shadows_spot_buffer_size &&
			set.shadows_point_buffer_size = objset.shadows_point_buffer_size &&
			set.shadows_transparent = objset.shadows_transparent &&
			set.subsurface_samples = objset.subsurface_samples &&
			set.indirect = objset.indirect &&
			set.indirect_precision = objset.indirect_precision &&
			set.reflections = objset.reflections &&
			set.reflections_precision = objset.reflections_precision &&
			set.glow = objset.glow &&
			set.glow_falloff = objset.glow_falloff &&
			set.aa = objset.aa &&
			set.aa_power = objset.aa_power
		)
	}

	if (!allsettings)
		return match

	match = (
		match &&
		has_fx = obj.has_fx &&
		ssao_radius = obj.ssao_radius &&
		ssao_power = obj.ssao_power &&
		ssao_color = obj.ssao_color &&
		ssao_always_visible = obj.ssao_always_visible &&
		glow_radius = obj.glow_radius &&
		glow_intensity = obj.glow_intensity &&
		glint_speed = obj.glint_speed &&
		glint_strength = obj.glint_strength &&
		tonemapper = obj.tonemapper &&
		exposure = obj.exposure &&
		gamma = obj.gamma
	)

	set = self.renderer[e_renderer.STANDARD];
	objset = obj.renderer[e_renderer.STANDARD];
	match = (
		match &&
		set.shadows_blur_size = objset.shadows_blur_size
	)

	set = self.renderer[e_renderer.REALISTIC];
	objset = obj.renderer[e_renderer.REALISTIC];
	match = (
		match &&
		set.subsurface_highlight = objset.subsurface_highlight &&
		set.subsurface_highlight_strength = objset.subsurface_highlight_strength &&
		set.indirect_blur_radius = objset.indirect_blur_radius &&
		set.indirect_strength = objset.indirect_strength &&
		set.reflections_fade_amount = objset.reflections_fade_amount &&
		set.reflections_thickness = objset.reflections_thickness &&
		set.glow_falloff_radius = objset.glow_falloff_radius &&
		set.glow_falloff_intensity = objset.glow_falloff_intensity
	)

	match = (
		match &&
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

	match = (
		match &&
		has_materials = obj.has_materials &&
		block_emissive = obj.block_emissive &&
		block_subsurface = obj.block_subsurface &&
		water_reflections = obj.water_reflections &&
		material_maps = obj.material_maps
	)

	return match
}
