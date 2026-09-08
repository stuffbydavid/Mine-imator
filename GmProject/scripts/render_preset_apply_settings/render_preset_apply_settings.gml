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
		
		var standard = (renderer = e_renderer.STANDARD);
		switch (name) {
			case "samples": realistic_samples = val break
			case "ssao": if (standard) standard_ssao = val else realistic_ssao = val break
			case "ssao_radius": ssao_radius = val break
			case "ssao_power": ssao_power = val break
			case "ssao_color": ssao_color = val break
			case "ssao_always_visible": ssao_always_visible = val break
			case "shadows": if (standard) standard_shadows = val else realistic_shadows = val break
			case "shadows_blur_quality": standard_shadows_blur_quality = val break
			case "shadows_blur_size": standard_shadows_blur_size = val break
			case "shadows_sun_buffer_size": if (standard) standard_shadows_sun_buffer_size = val else realistic_shadows_sun_buffer_size = val break
			case "shadows_spot_buffer_size": if (standard) standard_shadows_spot_buffer_size = val else realistic_shadows_spot_buffer_size = val break
			case "shadows_point_buffer_size": if (standard) standard_shadows_point_buffer_size = val else realistic_shadows_point_buffer_size = val break
			case "shadows_transparent": realistic_shadows_transparent = val break
			case "subsurface_samples": realistic_subsurface_samples = val break
			case "subsurface_highlight": realistic_subsurface_highlight = val break
			case "subsurface_highlight_strength": realistic_subsurface_highlight_strength = val break
			case "indirect": realistic_indirect = val break
			case "indirect_precision": realistic_indirect_precision = val break
			case "indirect_blur_radius": realistic_indirect_blur_radius = val break
			case "indirect_strength": realistic_indirect_strength = val break
			case "reflections": realistic_reflections = val break
			case "reflections_precision": realistic_reflections_precision = val break
			case "reflections_thickness": realistic_reflections_thickness = val break
			case "reflections_fade_amount": realistic_reflections_fade_amount = val break
			case "glow": if (standard) standard_glow = val else realistic_glow = val break
			case "glow_radius": glow_radius = val break
			case "glow_intensity": glow_intensity = val break
			case "glow_falloff": realistic_glow_falloff = val break
			case "glow_falloff_radius": realistic_glow_falloff_radius = val break
			case "glow_falloff_intensity": realistic_glow_falloff_intensity = val break
			case "aa": if (standard) standard_aa = val else realistic_aa = val break
			case "aa_power": if (standard) standard_aa_power = val else realistic_aa_power = val break
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
