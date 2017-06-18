/// minecraft_startup()
/// @desc Loads the default Minecraft assets. Character/block/item data is
///		  stored in mc_version, while the textures are put in mc_res.

globalvar mc_version, mc_builder, mc_res;
globalvar mc_block_states_map, mc_block_models_map;
mc_version = new(obj_minecraft_version)
mc_builder = new(obj_builder)
//mc_res = new(obj_resource) // TODO: Replace res_def

if (!file_exists_lib(minecraft_version_file))
{
	missing_file(minecraft_version_file)
	return false
}

if (!minecraft_version_load(minecraft_version))
	return false
	
return true