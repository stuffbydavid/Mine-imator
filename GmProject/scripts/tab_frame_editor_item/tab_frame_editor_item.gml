/// tab_frame_editor_item()

function tab_frame_editor_item()
{
	if (tl_edit.temp = null || tl_edit.type != e_tl_type.ITEM)
		return 0
	
	var res = tl_edit.value[e_value.TEXTURE_OBJ];
	
	if (res = null)
		res = tl_edit.temp.item_tex
	
	if (!res_is_ready(res))
		res = mc_res
	
	tab_control_switch()
	draw_button_collapse("itemslot", collapse_map[?"itemslot"], action_tl_frame_custom_item_slot, tl_edit.value[e_value.CUSTOM_ITEM_SLOT], "frameeditoritemcustomitemslot")
	tab_next()
	
	if (tl_edit.value[e_value.CUSTOM_ITEM_SLOT] && collapse_map[?"itemslot"])
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("frameeditoritemitemslot", dx, dy, dragger_width, tl_edit.value[e_value.ITEM_SLOT], .1, 0, no_limit, 0, 1, tab.item.item_slot, action_tl_frame_item_slot)
		tab_next()
		
		var textures, slots, sheetsizes;
		if (res.type = e_res_type.PACK)
		{
			textures = res.item_sheet_texture
			sheetsizes = minecraft_item_sheet_size
			slots = array_create(e_item_sheet.amount)
			for (var sheet = 0; sheet < e_item_sheet.amount; sheet++)
				slots[sheet] = ds_list_size(mc_assets.item_texture_list[sheet])
		}
		else
		{
			textures = [res.item_sheet_texture[e_item_sheet.SIZE16]]
			sheetsizes = [res.item_sheet_size]
			slots = [res.item_sheet_size[X] * res.item_sheet_size[Y]]
		}
		tab_control(216)
		draw_texture_picker(tl_edit.value[e_value.ITEM_SLOT], textures, slots, sheetsizes, dx, dy, dw, 216, tab.item.item_scroll, action_tl_frame_item_slot)
		tab_next()
		
		tab_collapse_end()
	}
}
