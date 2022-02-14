/// menu_event_create()

function menu_event_create()
{
	menu_name = ""
	menu_type = ""
	menu_temp_edit = null
	menu_script = null
	menu_value = null
	menu_ani = 0
	menu_ani_ease = 0
	menu_ani_type = ""
	menu_flip = false
	menu_x = 0
	menu_x_start = 0
	menu_y = 0
	menu_w = 0
	menu_w_start = 0
	menu_button_h = 0
	menu_amount = 0
	menu_show_amount = 0
	menu_item[0] = null
	menu_item_w = 0
	menu_item_h = 0
	menu_include_tl_edit = true
	menu_count = 0
	menu_item_extend = null
	menu_scroll_vertical = new_obj(obj_scrollbar)
	menu_scroll_horizontal = new_obj(obj_scrollbar)
	menu_height = 0
	menu_height_goal = 0
	menu_transition = null
	menu_steps = 0
	menu_floating = false
	menu_list = null
	menu_padding = 4
	
	app.menu_count++
	ds_list_add(app.menu_list, id)
}
