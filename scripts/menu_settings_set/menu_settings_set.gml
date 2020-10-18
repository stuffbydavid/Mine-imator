/// menu_settings_set(x, y, name, buttonheight)
/// @arg x
/// @arg y
/// @arg name
/// @arg buttonheight

var xx, yy, name, buttonheight;
xx = argument0
yy = argument1
name = argument2
buttonheight = argument3

settings_menu_busy_prev = window_busy
window_busy = "settingsmenu"
app_mouse_clear()

settings_menu_name = name
settings_menu_ani = 0
settings_menu_ani_type = "show"

settings_menu_sortlist = ""

// Init
settings_menu_scroll.value_goal = 0
settings_menu_scroll.value = 0
settings_menu_primary = false
settings_menu_x = xx
settings_menu_y = yy

settings_menu_list = list_init(settings_menu_name)
settings_menu_amount = ds_list_size(settings_menu_list.item)
settings_menu_w = settings_menu_list.width

if ((settings_menu_x + (settings_menu_w/2)) > window_width)
	settings_menu_x += window_width - (settings_menu_x + (settings_menu_w/2))

settings_menu_button_h = buttonheight
