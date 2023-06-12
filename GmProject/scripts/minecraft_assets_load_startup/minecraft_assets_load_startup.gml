/// minecraft_assets_load_startup()
/// @desc Starts to load the Minecraft assets. Character/block/item data is
/// stored in mc_assets, while the textures are put in the mc_res resource.

function minecraft_assets_load_startup()
{
	globalvar mc_assets, mc_builder, mc_res;
	globalvar load_assets_stage, load_assets_progress, load_assets_block_index, load_assets_splash, load_assets_credits;
	globalvar load_assets_startup_dir, load_assets_dir, load_assets_file, load_assets_zip_file, load_assets_state_file_map, load_assets_model_file_map, load_assets_map, load_assets_type_map;
	globalvar load_assets_block_preview_buffer, load_assets_block_preview_ani_buffer;
	globalvar pattern_update;
	
	mc_assets = new_obj(obj_minecraft_assets)
	mc_builder = new_obj(obj_builder)
	mc_res = new_obj(obj_resource)
	
	window_state = "load_assets"
	load_assets_stage = "unzip"
	load_assets_progress = 0
	load_assets_map = null
	load_assets_type_map = null
	load_assets_block_index = 0
	window_set_size(740, 450)
	alarm[0] = 1
	
	pattern_update = array()
	
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
		material_format = e_material.FORMAT_NONE
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
	load_assets_credits = ""
	
	if (file_exists_lib(splash_directory + "splashes.json"))
	{
		var map, splashlist, splash, splashfile;
		map = json_load(splash_directory + "splashes.json")
		splashlist = map[?"splashes"]
		splash = splashlist[|irandom(ds_list_size(splashlist) - 1)]
		splashfile = splash_directory + splash[?"file"]
		
		if (file_exists_lib(splashfile))
		{
			load_assets_splash = sprite_add(splashfile, 0, 0, 0, 0, 0)
			load_assets_credits = splash[?"credits"]
		}
	}
	
	return true
}
