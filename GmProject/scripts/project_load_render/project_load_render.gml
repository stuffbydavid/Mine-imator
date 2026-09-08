/// project_load_render(map)

function project_load_render(map)
{
	if (!ds_map_valid(map))
		return 0

	var custom = render_preset_map[?"custom"];
	with (custom)
	{
		render_preset_clear()
		render_preset_load_settings(map)
	}
	
	// Match saved performance settings to a loaded preset for each renderer
	for (var renderer = e_renderer.STANDARD; renderer <= e_renderer.REALISTIC; renderer++)
	{
		var hassettings = (renderer = e_renderer.STANDARD) ? custom.has_standard : custom.has_realistic;
		if (!hassettings)
			continue

		var match = "";
		var presetlist = render_preset_list[renderer];
		
		// Exact preset match
		for (var i = 0; i < ds_list_size(presetlist); i++)
		{
			var file = presetlist[|i];
			if (file = "custom")
				continue

			with (render_preset_map[?file])
				if (render_preset_equals(custom, renderer, true))
					match = file

			if (match != "")
				break
		}
		
		// Loose preset match
		if (match = "")
		{
			for (var i = 0; i < ds_list_size(presetlist); i++)
			{
				var file = presetlist[|i];
				if (file = "custom")
					continue

				with (render_preset_map[?file])
					if (render_preset_equals(custom, renderer, false))
						match = file

				if (match != "")
					break
			}
		}

		project_render_preset[renderer] = (match = "" ? "custom" : match)
	}
	
	render_apply_settings(custom, e_renderer.COMMON)
	
	with (custom)
	{
		has_fx = false
		has_graphics = false
		has_materials = false
	}
}
