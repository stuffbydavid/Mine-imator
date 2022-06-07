/// minecraft_assets_load_startup()
/// @desc Starts to load the Minecraft assets. Character/block/item data is
///		  stored in mc_assets, while the textures are put in the mc_res resource.

function minecraft_assets_load_startup()
{
	globalvar mc_assets, mc_builder, mc_res;
	globalvar load_assets_stage, load_assets_progress, load_assets_block_index, load_assets_block_name, load_assets_splash;
	globalvar load_assets_startup_dir, load_assets_dir, load_assets_file, load_assets_zip_file, load_assets_state_file_map, load_assets_model_file_map, load_assets_map, load_assets_type_map;
	globalvar load_assets_block_preview_buffer, load_assets_block_preview_ani_buffer;
	globalvar banner_update;
	
	mc_assets = new_obj(obj_minecraft_assets)
	mc_builder = new_obj(obj_builder)
	mc_res = new_obj(obj_resource)
	
	window_state = "load_assets"
	load_assets_stage = "unzip"
	load_assets_progress = 0
	load_assets_map = null
	load_assets_type_map = null
	load_assets_block_index = 0
	load_assets_block_name = ""
	window_set_size(740, 450)
	alarm[0] = 1
	
	banner_update = array()
	
	// Create default resource
	with (mc_res)
	{
		save_id = "default"
		type = e_res_type.PACK
		display_name = "Minecraft"
		font_minecraft = true
		font = new_minecraft_font()
		font_preview = font
		font_no_aa = font
	}
	
	// Load assets from version in settings, if it fails, reset to default
	if (!minecraft_assets_load_startup_version())
	{
		log("Could not load " + string(app.setting_minecraft_assets_version) + " assets. Resetting to default", minecraft_version)
		app.setting_minecraft_assets_version = minecraft_version
		if (!minecraft_assets_load_startup_version())
			return false
	}
	
	// Load splash from folder
	load_assets_splash = null
	var files = file_find(splash_directory, ".png");
	
	if (array_length(files) > 0)
		load_assets_splash = sprite_add(files[irandom(array_length(files) - 1)], 0, 0, 0, 0, 0)
	
	return true
}
