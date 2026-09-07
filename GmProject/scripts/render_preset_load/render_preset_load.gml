/// render_preset_load(filename, setname)
/// @arg filename

function render_preset_load(fn, setname = true)
{
	if (!file_exists_lib(fn))
		return false
		
	log("Loading render preset", fn)
		
	// Decode
	var map = json_load(fn);
	if (!ds_map_valid(map))
		return false
		
	if (!is_real(map[?"format"]))
		return false
	
	// Format
	load_format = map[?"format"];
	if (load_format < e_render_settings.FORMAT_210 ||
		load_format > render_settings_format)
		return false
		
	log("load_format", load_format)
	
	// Optional name field
	if (setname)
	{
		if (!is_string(map[?"name"]))
			return false
		name = map[?"name"]
	}
		
	// Settings
	if (!render_preset_load_settings(map[?"render"]))
		return false
	
	return true
}