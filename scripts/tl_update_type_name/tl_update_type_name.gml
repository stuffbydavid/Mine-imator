/// tl_update_type_name()
/// @desc Updates the type name (shown in information window)

type_name = text_get("type" + tl_type_name_list[|type])

if (part_of != null)
{
	if (type = e_tl_type.BODYPART)
	{
		if (model_part != null)
			type_name = minecraft_asset_get_name("modelpart", model_part.name)
		else
			type_name = text_get("timelineunusedbodypart")
	}
	else if (type = e_tl_type.SPECIAL_BLOCK)
	{
		if (model_file != null)
			type_name = minecraft_asset_get_name("model", model_file.name)
	}
	else if (type = e_tl_type.BLOCK)
	{
		type_name = minecraft_asset_get_name("block", mc_assets.block_name_map[?block_name].name)
	}
	
	type_name = text_get("timelinepartof", type_name, string_remove_newline(part_of.display_name))
}
else if (temp != null)
	type_name = text_get("timelineinstanceof", temp.display_name)