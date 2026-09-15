/// keyframe_update_item_name()
/// @desc Updates ITEM_NAME value

function keyframe_update_item_name()
{
	if (timeline.type != e_tl_type.ITEM)
		return 0
	
	var slot = value[e_value.ITEM_SLOT];
	
	// Uses a custom pack
	if (value[e_value.TEXTURE_OBJ] != null)
	{
		var tex = value[e_value.TEXTURE_OBJ];
				
		if (tex.type = e_res_type.PACK)
		{
			var decodedslot = minecraft_assets_texture_picker_slot_decode(slot, mc_assets.item_texture_list)
			value[e_value.ITEM_NAME] = decodedslot[0] >= 0 ? mc_assets.item_texture_list[decodedslot[0]][|decodedslot[1]] : ""
		}
		else
			value[e_value.ITEM_NAME] = ""
	}
	else if (timeline.temp.item_tex.type = e_res_type.PACK)
	{
		var decodedslot = minecraft_assets_texture_picker_slot_decode(slot, mc_assets.item_texture_list)
		value[e_value.ITEM_NAME] = decodedslot[0] >= 0 ? mc_assets.item_texture_list[decodedslot[0]][|decodedslot[1]] : ""
	}
	else
		value[e_value.ITEM_NAME] = ""
}
