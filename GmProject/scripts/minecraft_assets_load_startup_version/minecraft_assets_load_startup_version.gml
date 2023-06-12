/// minecraft_assets_load_startup_version()
/// @desc Starts loading the minecraft assets specified in the settings
/// Returns whether successful.

function minecraft_assets_load_startup_version()
{
	var version = app.setting_minecraft_assets_version;
	
	log("Loading Minecraft assets version", version)
	load_assets_file = minecraft_directory + version + ".midata"
	load_assets_zip_file = minecraft_directory + version + ".zip"
	
	if (!file_exists_lib(load_assets_file))
	{
		log("Could not find Minecraft assets file", load_assets_file)
		return false
	}
	
	if (!file_exists_lib(load_assets_zip_file))
	{
		log("Could not find Minecraft assets archive", load_assets_zip_file)
		return false
	}
	
	// Load specification
	load_assets_type_map = ds_int_map_create()
	load_assets_map = json_load(load_assets_file, load_assets_type_map)
	if (!ds_map_valid(load_assets_map))
	{
		log("Could not parse JSON", load_assets_file)
		ds_map_destroy(load_assets_type_map)
		return false
	}
	
	// Check format
	var format = load_assets_map[?"format"];
	if (!is_real(format))
		format = e_minecraft_assets.FORMAT_110_PRE_1
	
	if (format != minecraft_assets_format)
	{
		log("Unsupported archive, format", format)
		return false
	}
	
	// Check patch version
	var patch = load_assets_map[?"patch"];
	if (!is_real(patch))
		patch = 1
	
	load_assets_startup_dir = mc_file_directory + version + (patch > 1 ? "_" + string(patch) : "") + "/"
	load_assets_dir = load_assets_startup_dir
	load_assets_state_file_map = ds_map_create() // filename -> model
	load_assets_model_file_map = ds_map_create() // filename -> model
	
	return true
}
