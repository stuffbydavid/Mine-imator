/// tab_object_editor_item()

function tab_object_editor_item()
{
	var res = res_eval(obj_edit.item_tex);
	if (res.item_sheet_texture[e_item_sheet.SIZE16] = null)
	{
		tab_close(tab)
		return 0
	}
			
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
	draw_texture_picker(obj_edit.item_slot, textures, slots, sheetsizes, dx, dy, dw, dh, tab.item_scroll, action_lib_item_slot, mc_assets.item_texture_list, null, null, true)
			
	if (content_mouseon)
		window_scroll_focus = string(tab.item_scroll)
			
}