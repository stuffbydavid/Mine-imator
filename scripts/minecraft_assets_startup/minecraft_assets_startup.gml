/// minecraft_assets_startup()
/// @desc Loads the default Minecraft assets. Character/block/item data is
///		  stored in mc_assets, while the textures are put in mc_res.

globalvar mc_assets, mc_builder, mc_res;
globalvar mc_block_state_file_map, mc_block_model_file_map;
globalvar load_assets_stage, load_assets_progress, load_assets_map, load_assets_type_map, load_assets_zip_file, load_assets_block_index;

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
	type = "pack"
	display_name = "Minecraft"
	font_minecraft = true
	font = new_minecraft_font()
	font_preview = font
}

log("Loading Minecraft assets version", minecraft_version)

// Open assets specification
var fname = minecraft_directory + minecraft_version + ".midata"
if (!file_exists_lib(fname))
{
	log("Could not find Minecraft assets file", fname)
	return false
}

// Locate zip file
load_assets_zip_file = minecraft_directory + minecraft_version + ".zip"
if (!file_exists_lib(load_assets_zip_file))
{
	log("Could not find Minecraft assets archive", load_assets_zip_file)
	return false
}

// Load specification
load_assets_type_map = ds_map_create()
load_assets_map = json_load(fname, load_assets_type_map)
if (!ds_map_valid(load_assets_map))
{
	log("Could not parse JSON", fname)
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

mc_block_state_file_map = ds_map_create() // filename -> states
mc_block_model_file_map = ds_map_create() // filename -> model

return true