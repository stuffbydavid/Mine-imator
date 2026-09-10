/// render_preset_apply_settings(settings, renderer)
/// @arg settings
/// @arg renderer
/// @desc Applies a number of comma-separated settings to the render preset (setting1=-1,setting2=false).

function render_preset_apply_settings(settings, renderer)
{
	var settingsarr = string_split_escaped(settings, ",");
	for (var s = 0; s < array_length(settingsarr); s++)
	{
		var setting, name, val;
		setting = string_split_escaped(settingsarr[s], "=")
		if (array_length(setting) < 2) {
			log("Malformed setting", settingsarr[s])
			continue
		}
		
		name = string_replace(setting[0], "render_", "")
		if (setting[1] == "true")
			val = true
		else if (setting[1] == "false")
			val = false
		else
			val = eval(setting[1], 0)
		
		var set, standardset, realisticset;
		set = self.renderer[renderer]
		standardset = self.renderer[e_renderer.STANDARD]
		realisticset = self.renderer[e_renderer.REALISTIC]
		switch (name)
		{
			case "samples": set.samples = val break
			case "ssao": set.ssao = val break
			case "ssao_radius": ssao_radius = val break
			case "ssao_power": ssao_power = val break
			case "ssao_color": ssao_color = val break
			case "ssao_always_visible": ssao_always_visible = val break
			case "shadows": set.shadows = val break
			case "shadows_blur_quality": set.shadows_blur_quality = val break
			case "shadows_blur_size": standardset.shadows_blur_size = val break
			case "shadows_sun_cascades": set.shadows_sun_cascades = val break
			case "shadows_sun_buffer_size": set.shadows_sun_buffer_size = val break
			case "shadows_spot_buffer_size": set.shadows_spot_buffer_size = val break
			case "shadows_point_buffer_size": set.shadows_point_buffer_size = val break
			case "shadows_transparent": set.shadows_transparent = val break
			case "subsurface_samples": set.subsurface_samples = val break
			case "subsurface_highlight": realisticset.subsurface_highlight = val break
			case "subsurface_highlight_strength": realisticset.subsurface_highlight_strength = val break
			case "indirect": set.indirect = val break
			case "indirect_precision": set.indirect_precision = val break
			case "indirect_blur_radius": realisticset.indirect_blur_radius = val break
			case "indirect_strength": realisticset.indirect_strength = val break
			case "reflections": set.reflections = val break
			case "reflections_precision": set.reflections_precision = val break
			case "reflections_thickness": realisticset.reflections_thickness = val break
			case "reflections_fade_amount": realisticset.reflections_fade_amount = val break
			case "glow": set.glow = val break
			case "glow_radius": glow_radius = val break
			case "glow_intensity": glow_intensity = val break
			case "glow_falloff": set.glow_falloff = val break
			case "glow_falloff_radius": realisticset.glow_falloff_radius = val break
			case "glow_falloff_intensity": realisticset.glow_falloff_intensity = val break
			case "aa": set.aa = val break
			case "aa_power": set.aa_power = val break
			case "distance": render_distance = val break
			case "bend_style": bend_style = val break
			case "opaque_leaves": opaque_leaves = val break
			case "liquid_animation": liquid_animation = val break
			case "water_reflections": water_reflections = val break
			case "block_emissive": block_emissive = val break
			case "block_subsurface": block_subsurface = val break
			case "glint_speed": glint_speed = val break
			case "glint_strength": glint_strength = val break
			case "texture_filtering": texture_filtering = val break
			case "transparent_block_texture_filtering": transparent_block_texture_filtering = val break
			case "texture_filtering_level": texture_filtering_level = val break
			case "alpha_mode": alpha_mode = val break
			case "tonemapper": tonemapper = val break
			case "exposure": exposure = val break
			case "gamma": gamma = val break
			case "material_maps": material_maps = val break
			default: // Camera, or unknown
			{
				var camvaluename, camvalue;
				camvaluename = string_upper(name)
				if (string_pos("CAM_", camvaluename) != 1)
					camvaluename = "CAM_" + camvaluename
				camvalue = ds_list_find_index(value_name_list, camvaluename)
				if (app.timeline_camera && camvalue >= e_value.CAM_FOV && camvalue <= e_value.CAM_HEIGHT)
					app.timeline_camera.value[camvalue] = val
				else
					log("Unknown setting", name)
				break
			}
		}
	}

}
