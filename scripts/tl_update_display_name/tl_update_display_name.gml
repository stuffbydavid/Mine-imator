/// tl_update_display_name()
/// @desc Sets the display name of a timeline (shown in timeline).

if (name = "")
{
	display_name = text_get("type" + tl_type_name_list[|type])
	
	if (part_of != null)
	{
		if (type = e_tl_type.BODYPART)
		{
			if (model_part != null)
				display_name = minecraft_asset_get_name("modelpart", model_part.name)
			else
				display_name = text_get("timelineunusedbodypart")
		}
		else if (type = e_tl_type.SPECIAL_BLOCK)
		{
			if (model_file != null)
				display_name = minecraft_asset_get_name("model", model_file.name)
		}
		else if (type = e_tl_type.BLOCK)
		{
			display_name = minecraft_asset_get_name("block", mc_assets.block_name_map[?block_name].name)
		}
	}
	else if (temp != null)
		display_name = temp.display_name
}
else
	display_name = name

if (part_list != null)
{
	for (var p = 0; p < ds_list_size(part_list); p++)
	{
		with (part_list[|p])
		{
			tl_update_type_name()
			tl_update_display_name()
		}
	}
}