/// tests_apply_settings(settings)
/// @desc Applies a number of comma-separated settings (setting1=-1,setting2=false).

function tests_apply_settings(settings)
{
	var settingsarr = string_split_escaped(settings, ",");
	for (var s = 0; s < array_length(settingsarr); s++)
	{
		var setting, name, val;
		setting = string_split_escaped(settingsarr[s], "=")
		if (array_length(setting) < 2) {
			log("Malformed setting at " + string(timeline_marker), settingsarr[s])
			continue
		}
		
		name = string_replace(setting[0], "render_", "")
		if (setting[1] == "true")
			val = true
		else if (setting[1] == "false")
			val = false
		else
			val = eval(setting[1], 0)
		
		switch (name) {
			case "samples": project_render_samples = val break
			case "distance": project_render_distance = val break
			case "ssao": project_render_ssao = val break
			case "ssao_radius": project_render_ssao_radius = val break
			case "ssao_power": project_render_ssao_power = val break
			case "ssao_color": project_render_ssao_color = val break
			case "shadows": project_render_shadows = val break
			case "shadows_sun_size": project_render_shadows_sun_buffer_size = val break
			case "shadows_spot_size": project_render_shadows_spot_buffer_size = val break
			case "shadows_point_size": project_render_shadows_point_buffer_size = val break
			case "shadows_transparent": project_render_shadows_transparent = val break
			case "subsurface_samples": project_render_subsurface_samples = val break
			case "subsurface_highlight": project_render_subsurface_highlight = val break
			case "subsurface_highlight_strength": project_render_subsurface_highlight_strength = val break
			case "indirect": project_render_indirect = val break
			case "indirect_precision": project_render_indirect_precision = val break
			case "indirect_blur_radius": project_render_indirect_blur_radius = val break
			case "indirect_strength": project_render_indirect_strength = val break
			case "reflections": project_render_reflections = val break
			case "reflections_precision": project_render_reflections_precision = val break
			case "reflections_thickness": project_render_reflections_thickness = val break
			case "reflections_fade_amount": project_render_reflections_fade_amount = val break
			case "glow": project_render_glow = val break
			case "glow_radius": project_render_glow_radius = val break
			case "glow_intensity": project_render_glow_intensity = val break
			case "glow_falloff": project_render_glow_falloff = val break
			case "glow_falloff_radius": project_render_glow_falloff_radius = val break
			case "glow_falloff_intensity": project_render_glow_falloff_intensity = val break
			case "aa": project_render_aa = val break
			case "aa_power": project_render_aa_power = val break
			case "bend_style": project_bend_style = val break
			case "opaque_leaves": project_render_opaque_leaves = val break
			case "liquid_animation": project_render_liquid_animation = val break
			case "water_reflections": project_render_water_reflections = val break
			case "block_emissive": project_render_block_emissive = val break
			case "block_subsurface": project_render_block_subsurface = val break
			case "glint_speed": project_render_glint_speed = val break
			case "glint_strength": project_render_glint_strength = val break
			case "texture_filtering": project_render_texture_filtering = val break
			case "transparent_block_texture_filtering": project_render_transparent_block_texture_filtering = val break
			case "texture_filtering_level":
				project_render_texture_filtering_level = val
				texture_set_mipmap_level(val)
				break
			case "alpha_mode": project_render_alpha_mode = val break
			case "tonemapper": project_render_tonemapper = val break
			case "exposure": project_render_exposure = val break
			case "gamma": project_render_gamma = val break
			case "material_maps": project_render_material_maps = val break
			default: // Camera, or unknown
			{
				var camvaluename, camvalue;
				camvaluename = string_upper(name)
				if (string_pos("CAM_", camvaluename) != 1)
					camvaluename = "CAM_" + camvaluename
				camvalue = ds_list_find_index(value_name_list, camvaluename)
				if (timeline_camera && camvalue >= e_value.CAM_FOV && camvalue <= e_value.CAM_HEIGHT)
					timeline_camera.value[camvalue] = val
				else
					log("Unknown setting", name)
				break
			}
		}
	}
}
