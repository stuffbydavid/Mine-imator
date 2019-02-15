/// render_update_item()
/// @desc Updates item timelines

with (obj_timeline)
{
	if (type != e_tl_type.ITEM)
		continue
	
	var slot, res;
	slot = value[e_value.ITEM_SLOT]
	res = value[e_value.TEXTURE_OBJ]
	
	if (!value[e_value.CUSTOM_ITEM_SLOT] && res = null)
	{
		if (item_vbuffer)
		{
			vbuffer_destroy(item_vbuffer)
			item_vbuffer = null
		}
	}
	
	if (!value[e_value.CUSTOM_ITEM_SLOT])
		slot = temp.item_slot
	
	if (res = null)
		res = temp.item_tex
	
	render_generate_item(slot, res, temp.item_3d)
}