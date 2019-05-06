/// tab_frame_editor_item()

if (tl_edit.temp = null || tl_edit.type != e_tl_type.ITEM)
	return 0

var res = tl_edit.value[e_value.TEXTURE_OBJ];

if (res = null)
	res = tl_edit.temp.item_tex

if (!res.ready)
	res = mc_res

tab_control_checkbox_expand()
draw_checkbox_expand("frameeditoritemcustomitemslot", dx, dy, tl_edit.value[e_value.CUSTOM_ITEM_SLOT], action_tl_frame_custom_item_slot, checkbox_expand_frameeditor_itemslot, action_checkbox_expand_frameeditor_itemslot)
tab_next()

if (tl_edit.value[e_value.CUSTOM_ITEM_SLOT] && checkbox_expand_frameeditor_itemslot)
{
	dx += 4
	dw -= 4
	
	tab_control_dragger()
	draw_dragger("frameeditoritemitemslot", dx, dy, dw, tl_edit.value[e_value.ITEM_SLOT], .1, 0, no_limit, 0, 1, tab.item.item_slot, action_tl_frame_item_slot)
	tab_next()
		
	var slots = test((res.type = e_res_type.PACK), ds_list_size(mc_assets.item_texture_list), (res.item_sheet_size[X] * res.item_sheet_size[Y]));
	tab_control(200)
	draw_texture_picker(tl_edit.value[e_value.ITEM_SLOT], res.item_sheet_texture, dx, dy, dw, 200, slots, res.item_sheet_size[X], res.item_sheet_size[Y], tab.item.item_scroll, action_tl_frame_item_slot)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Image
var tex = res.block_preview_texture;

if (tex = null)
	tex = res.texture

tab_control(48)
draw_button_menu("frameeditoritemitemtex", e_menu.LIST, dx, dy, dw, 40, tl_edit.value[e_value.TEXTURE_OBJ], res.display_name, action_tl_frame_texture_obj, tex)
tab_next()