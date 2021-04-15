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
menu_w = 244
menu_button_h = 0
menu_show_amount = 4
menu_floating = true
menu_x = mouse_current_x + 16

if (menu_x + menu_w > window_width)
	menu_x = mouse_current_x - menu_w - 16

menu_y = mouse_current_y
menu_steps = 0

menu_clear()
menu_list = menu_transition_init()
menu_focus_selected()