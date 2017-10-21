/// minecraft_assets_create_block_previews()
/// @desc Creates block previews (single color for top-down and cross-section view) for the world importer.

var statecolormap = ds_map_create()

with (obj_block_load_state_file)
{
	// Continue if previously set or has no model objects
	if (!is_undefined(statecolormap[?name]) || is_undefined(state_id_map[?0]))
		continue
		
	// Choose first model object from multi-part
	var modelobj = state_id_map[?0];
	if (is_array(modelobj))
		modelobj = modelobj[0]
		
	// Continue if no models
	if (modelobj.model_amount = 0)
		continue
		
	// Pick the preview color from the first found render model of the default state
	with (modelobj.model[0])
		statecolormap[?other.name] = array(preview_color_zp, preview_color_yp) // Top-down color, cross-section color
}

log("Saving block previews", block_preview_file)

// Save to file
json_save_start(block_preview_file)
json_save_object_start()

var key = ds_map_find_first(statecolormap);
while (!is_undefined(key))
{
	var colors = statecolormap[?key];
	if (colors[0] != null || colors[1] != null)
	{
		json_save_object_start(key)
		if (colors[0] > null)
			json_save_var_color("Y", colors[0])
		if (colors[1] > null)
			json_save_var_color("Z", colors[1])
		json_save_object_done()
	}
	key = ds_map_find_next(statecolormap, key)
}

json_save_object_done()
json_save_done()