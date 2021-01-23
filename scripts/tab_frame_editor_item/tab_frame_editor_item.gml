/// tab_frame_editor_item()

if (tl_edit.temp = null || tl_edit.type != e_tl_type.ITEM)
	return 0

var res = tl_edit.value[e_value.TEXTURE_OBJ];

if (res = null)
	res = tl_edit.temp.item_tex

if (!res.ready)
	res = mc_res

tab_control_switch()
draw_button_collapse("frameeditoritemcustomitemslot", setting_collapse_frameeditor_itemslot, action_collapse_frameeditor_itemslot, !tl_edit.value[e_value.CUSTOM_ITEM_SLOT])
draw_switch("frameeditoritemcustomitemslot", dx, dy, tl_edit.value[e_value.CUSTOM_ITEM_SLOT], action_tl_frame_custom_item_slot, false)
tab_next()

if (tl_edit.value[e_value.CUSTOM_ITEM_SLOT] && setting_collapse_frameeditor_itemslot)
{
	tab_collapse_start()
	
	tab_control_dragger()
	draw_dragger("frameeditoritemitemslot", dx, dy, dragger_width, tl_edit.value[e_value.ITEM_SLOT], .1, 0, no_limit, 0, 1, tab.item.item_slot, action_tl_frame_item_slot)
	tab_next()
	
	var slots = ((res.type = e_res_type.PACK) ? ds_list_size(mc_assets.item_texture_list) : (res.item_sheet_size[X] * res.item_sheet_size[Y]));
	tab_control(200)
	draw_texture_picker(tl_edit.value[e_value.ITEM_SLOT], res.item_sheet_texture, dx, dy, dw, 200, slots, res.item_sheet_size[X], res.item_sheet_size[Y], tab.item.item_scroll, action_tl_frame_item_slot)
	tab_next()
	
	tab_collapse_end()
}

// Image
var tex = res.block_preview_texture;

if (tex = null)
	tex = res.texture

tab_control_menu()
draw_button_menu("frameeditoritemitemtex", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.TEXTURE_OBJ], res.display_name, action_tl_frame_texture_obj, false, tex)
tab_next()