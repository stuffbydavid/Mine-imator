/// keyframe_update_item_name()
/// @desc Updates ITEM_NAME value

if (timeline.type != e_tl_type.ITEM)
	return 0

var slot = value[e_value.ITEM_SLOT];
				
// Uses a custom pack
if (value[e_value.TEXTURE_OBJ] != null)
{
	var tex = value[e_value.TEXTURE_OBJ];
					
	if (tex.type = e_res_type.PACK && slot < ds_list_size(mc_assets.item_texture_list))
		value[e_value.ITEM_NAME] = mc_assets.item_texture_list[|slot]
	else
		value[e_value.ITEM_NAME] = ""
}
else if (timeline.temp.item_tex.type = e_res_type.PACK && slot < ds_list_size(mc_assets.item_texture_list))
{
	value[e_value.ITEM_NAME] = mc_assets.item_texture_list[|slot]
}
else
	value[e_value.ITEM_NAME] = ""