/// minecraft_assets_startup()
/// @desc Loads the default Minecraft assets. Character/block/item data is
///		  stored in mc_assets, while the textures are put in mc_res.

globalvar mc_assets, mc_builder, mc_res;
globalvar load_assets_stage, load_assets_progress, load_assets_block_index;
globalvar load_assets_dir, load_assets_file, load_assets_zip_file, load_assets_model_file_map, load_assets_map, load_assets_type_map;

mc_assets = new(obj_minecraft_assets)
mc_builder = new(obj_builder)
mc_res = new(obj_resource)

window_busy = "load_assets"
load_assets_stage = "unzip"
load_assets_progress = 0
load_assets_map = null
load_assets_type_map = null
load_assets_block_index = 0

// Create default resource
with (mc_res)
{
	save_id = "default"
	type = e_res_type.PACK
	display_name = "Minecraft"
	font_minecraft = true
	font = new_minecraft_font()
	font_preview = font
}

log("Loading Minecraft assets version", app.setting_minecraft_version)

load_assets_file = minecraft_directory + app.setting_minecraft_version + ".midata"
load_assets_zip_file = minecraft_directory + app.setting_minecraft_version + ".zip"

if (!file_exists_lib(load_assets_file) || !file_exists_lib(load_assets_zip_file))
{
	log("Could not find Minecraft assets file/archive " + string(app.setting_minecraft_version) + ". Resetting to default", minecraft_version)
	app.setting_minecraft_version = minecraft_version
	load_assets_file = minecraft_directory + app.setting_minecraft_version + ".midata"
	load_assets_zip_file = minecraft_directory + app.setting_minecraft_version + ".zip"
}

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
load_assets_type_map = ds_map_create()
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

if (format > minecraft_assets_format)
{
	log("Too new archive, format", format)
	return false
}

load_assets_dir = mc_unzip_directory + app.setting_minecraft_version + "\\"
load_assets_model_file_map = ds_map_create() // filename -> model

return true