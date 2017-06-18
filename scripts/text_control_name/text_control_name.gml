/// text_control_name(key, control)
/// @arg key
/// @arg control 

var ctrl = "";
if (argument1)
	ctrl = text_get("keycontrol") + "+"
	
switch (argument0)
{
	case vk_left:			return ctrl + text_get("keyleft")
	case vk_right:			return ctrl + text_get("keyright")
	case vk_up:				return ctrl + text_get("keyup")
	case vk_down:			return ctrl + text_get("keydown")
	case vk_enter:			return ctrl + text_get("keyenter")
	case vk_escape:			return ctrl + text_get("keyescape")
	case vk_space:			return ctrl + text_get("keyspace")
	case vk_lshift:			return ctrl + text_get("keyleftshift")
	case vk_rshift:			return ctrl + text_get("keyrightshift")
	case vk_lalt:			return ctrl + text_get("keyleftalt")
	case vk_ralt:			return ctrl + text_get("keyrightalt")
	case vk_lcontrol:		return ctrl + text_get("keyleftcontrol")
	case vk_rcontrol:		return ctrl + text_get("keyrightcontrol")
	case vk_backspace:		return ctrl + text_get("keybackspace")
	case vk_tab:			return ctrl + text_get("keytab")
	case vk_home:			return ctrl + text_get("keyhome")
	case vk_end:			return ctrl + text_get("keyend")
	case vk_delete:			return ctrl + text_get("keydelete")
	case vk_insert:			return ctrl + text_get("keyinsert")
	case vk_pageup:			return ctrl + text_get("keypageup")
	case vk_pagedown:		return ctrl + text_get("keypagedown")
	case vk_pause:			return ctrl + text_get("keypause")
	case vk_printscreen:	return ctrl + text_get("keyprintscreen")
	case vk_f1:				return ctrl + "F1"
	case vk_f2:				return ctrl + "F2"
	case vk_f3:				return ctrl + "F3"
	case vk_f4:				return ctrl + "F4"
	case vk_f5:				return ctrl + "F5"
	case vk_f6:				return ctrl + "F6"
	case vk_f7:				return ctrl + "F7"
	case vk_f8:				return ctrl + "F8"
	case vk_f9:				return ctrl + "F9"
	case vk_f10:			return ctrl + "F10"
	case vk_f11:			return ctrl + "F11"
	case vk_f12:			return ctrl + "F12"
}

return ctrl + chr(argument0)
