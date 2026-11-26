/// @desc Sets the display name of a timeline (shown in timeline).

function tl_update_display_name()
{
	if (name = "")
	{
		display_name = text_get("type/" + tl_type_name_list[|type])
		
		if (part_of != null)
		{
			if (type = e_tl_type.MODEL_PART)
			{
				if (model_part != null)
					display_name = minecraft_asset_get_name("model/part", model_part.name)
				else
					display_name = text_get("timeline/unused_model_part")
			}
			else if (type = e_tl_type.EQUIPMENT || type = e_tl_type.SPECIAL_BLOCK)
			{
				if (model_name != "")
					display_name = minecraft_asset_get_name("model", model_name)
			}
			else if (type = e_tl_type.BLOCK)
			{
				if (!is_undefined(mc_assets.block_name_map[?block_name]))
					display_name = minecraft_asset_get_name("block", mc_assets.block_name_map[?block_name].name)
			}
		}
		else if (type = e_tl_type.BLOCK && !has_temp)
		{
			if (!is_undefined(mc_assets.block_name_map[?block_name]))
				display_name = minecraft_asset_get_name("block", mc_assets.block_name_map[?block_name].name)
		}
		else if (type = e_tl_type.SPECIAL_BLOCK && !has_temp)
		{
			if (!is_undefined(mc_assets.model_name_map[?model_name]))
				display_name = minecraft_asset_get_name("model", mc_assets.model_name_map[?model_name].name)
		}
		else if (type = e_tl_type.CAMERA_EFFECT)
			display_name = text_get("type/effect", text_get("frame_editor/camera_effect/" + camera_effect_name_list[|camera_effect_type]))
		
		else if (has_temp && temp != null)
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
}
