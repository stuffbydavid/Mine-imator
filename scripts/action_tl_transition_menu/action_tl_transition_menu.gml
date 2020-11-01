/// action_tl_transition_menu(value)
/// @desc Shortcut to show the transition menu.

window_busy = "menu"
window_focus = string(menu_scroll_vertical)
app_mouse_clear()
	
menu_name = "timelinetransition"
menu_type = e_menu.TRANSITION_LIST
menu_temp_edit = temp_edit
menu_script = action_tl_frame_transition
menu_value = argument0
menu_ani = 0
menu_ani_type = "show"
menu_flip = false
menu_w = 400
menu_button_h = 0
menu_show_amount = 4
menu_item_w = 60
menu_item_h = 60
menu_x = min(mouse_current_x + 30, window_width - menu_w - 10)
menu_y = min(mouse_current_y - (menu_show_amount * menu_item_h) / 2, window_height - (menu_show_amount * menu_item_h) - 10)
	
menu_clear()
menu_transition_init()
menu_focus_selected()