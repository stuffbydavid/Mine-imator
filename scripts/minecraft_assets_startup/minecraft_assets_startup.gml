/// minecraft_assets_startup()
/// @desc Loads the default Minecraft assets. Character/block/item data is
///		  stored in mc_assets, while the textures are put in mc_res.

globalvar mc_assets, mc_builder, res_def;
globalvar mc_block_state_file_map, mc_block_model_file_map;
mc_assets = new(obj_minecraft_assets)
mc_builder = new(obj_builder)
res_def = new(obj_resource)

with (res_def)
{
	save_id = "default"
	type = "pack"
	display_name = "Minecraft"
	font_minecraft = true
	font = new_minecraft_font()
	font_preview = font
}

if (!file_exists_lib(minecraft_assets_file))
{
	missing_file(minecraft_assets_file)
	return false
}

if (!minecraft_assets_load(minecraft_version))
	return false
	
return true