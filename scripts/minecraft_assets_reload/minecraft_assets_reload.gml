/// minecraft_assets_reload()
/// @desc Debug use only.

if (!minecraft_assets_load(minecraft_version, false))
	return false
	
with (obj_template)
{
	if (type = "char" || type = "spblock")
	{
		temp_update_model_state_map()
		temp_update_model()
	}
	else if (type = "block")
	{
		temp_update_block_state_map()
		temp_update_block()
	}
}

with (obj_timeline)
	tl_update_scenery_part()