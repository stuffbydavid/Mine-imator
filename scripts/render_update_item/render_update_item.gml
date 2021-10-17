/// render_update_item()
/// @desc Updates item timelines

function render_update_item()
{
	with (obj_timeline)
	{
		if (type != e_tl_type.ITEM)
			continue
		
		var slot, res, matres, norres;
		slot = value[e_value.ITEM_SLOT]
		res = value[e_value.TEXTURE_OBJ]
		matres = value[e_value.TEXTURE_MATERIAL_OBJ]
		norres = value[e_value.TEXTURE_NORMAL_OBJ]
		
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
		
		if (matres = null)
			matres = temp.item_material_tex
		
		if (norres = null)
			norres = temp.item_normal_tex
		
		render_generate_item(slot, [res, matres, norres], temp.item_3d)
	}
}
