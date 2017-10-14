/// temp_update_display_name()
/// @desc Updates the display name of the template.

if (name = "")
{
	display_name = text_get("type" + temp_type_name_list[|type])
	
	switch (type)
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.SPECIAL_BLOCK:
			if (model_file != null)
				display_name = minecraft_asset_get_name("model", model_file.name)
			break
		
		case e_temp_type.SCENERY:
			if (scenery != null)
				display_name = scenery.display_name
			break
		
		case e_temp_type.BLOCK:
			display_name = minecraft_asset_get_name("block", mc_assets.block_name_map[?block_name].name)
			break
		
		case e_temp_type.BODYPART:
			if (model_part != null)
				display_name = text_get("librarybodypartof", minecraft_asset_get_name("modelpart", model_part.name), minecraft_asset_get_name("model", model_file.name))
			else
				display_name = text_get("librarybodypartunknown")
			break
	}
}
else
	display_name = name

with (obj_timeline)
{
	if (temp = other.id && part_of = null)
	{
		tl_update_type_name()
		tl_update_display_name()
	}
}
