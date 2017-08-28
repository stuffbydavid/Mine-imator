/// minecraft_startup()
/// @desc Loads the default Minecraft assets. Character/block/item data is
///		  stored in mc_version, while the textures are put in mc_res.

globalvar mc_version, mc_builder, res_def;
globalvar mc_block_state_file_map, mc_block_model_file_map;
mc_version = new(obj_minecraft_version)
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

if (!file_exists_lib(minecraft_version_file))
{
	missing_file(minecraft_version_file)
	return false
}

if (!minecraft_version_load(minecraft_version))
	return false
	
return true