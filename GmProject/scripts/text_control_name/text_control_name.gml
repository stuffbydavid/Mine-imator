function text_control_name(keybind)
{
	var char, text;
	
	switch (keybind[e_keybind_key.CHAR])
	{
		case vk_nokey:			char = text_get("key/no_key"); break
		case vk_anykey:			char = text_get("key/any_key"); break
		case vk_left:			char = text_get("key/left"); break
		case vk_right:			char = text_get("key/right"); break
		case vk_up:				char = text_get("key/up"); break
		case vk_down:			char = text_get("key/down"); break
		//case vk_return:
		case vk_enter:			char = text_get("key/enter"); break
		case vk_escape:			char = text_get("key/escape"); break
		case vk_space:			char = text_get("key/space"); break
		case vk_shift:			char = text_get("key/shift"); break
		case vk_lshift:			char = text_get("key/left_shift"); break
		case vk_rshift:			char = text_get("key/right_shift"); break
		case vk_alt:			char = text_get("key/alt"); break
		case vk_lalt:			char = text_get("key/left_alt"); break
		case vk_ralt:			char = text_get("key/right_alt"); break
		case vk_control:		char = text_get("key/control"); break
		case vk_lcontrol:		char = text_get("key/left_control"); break
		case vk_rcontrol:		char = text_get("key/right_control"); break
		case vk_backspace:		char = text_get("key/backspace"); break
		case vk_tab:			char = text_get("key/tab"); break
		case vk_home:			char = text_get("key/home"); break
		case vk_end:			char = text_get("key/end"); break
		case vk_delete:			char = text_get("key/delete"); break
		case vk_insert:			char = text_get("key/insert"); break
		case vk_pageup:			char = text_get("key/page_up"); break
		case vk_pagedown:		char = text_get("key/page_down"); break
		case vk_pause:			char = text_get("key/pause"); break
		case vk_printscreen:	char = text_get("key/print_screen"); break
		case vk_f1:				char = "F1"; break
		case vk_f2:				char = "F2"; break
		case vk_f3:				char = "F3"; break
		case vk_f4:				char = "F4"; break
		case vk_f5:				char = "F5"; break
		case vk_f6:				char = "F6"; break
		case vk_f7:				char = "F7"; break
		case vk_f8:				char = "F8"; break
		case vk_f9:				char = "F9"; break
		case vk_f10:			char = "F10"; break
		case vk_f11:			char = "F11"; break
		case vk_f12:			char = "F12"; break
		case vk_numpad0:		char = text_get("key/numpad_key", "0"); break
		case vk_numpad1:		char = text_get("key/numpad_key", "1"); break
		case vk_numpad2:		char = text_get("key/numpad_key", "2"); break
		case vk_numpad3:		char = text_get("key/numpad_key", "3"); break
		case vk_numpad4:		char = text_get("key/numpad_key", "4"); break
		case vk_numpad5:		char = text_get("key/numpad_key", "5"); break
		case vk_numpad6:		char = text_get("key/numpad_key", "6"); break
		case vk_numpad7:		char = text_get("key/numpad_key", "7"); break
		case vk_numpad8:		char = text_get("key/numpad_key", "8"); break
		case vk_numpad9:		char = text_get("key/numpad_key", "9"); break
		case vk_multiply:		char = text_get("key/numpad_key", "*"); break
		case vk_divide:			char = text_get("key/numpad_key", "/"); break
		case vk_add:			char = text_get("key/numpad_key", "+"); break
		case vk_subtract:		char = text_get("key/numpad_key", "-"); break
		case vk_decimal:		char = text_get("key/numpad_key", "."); break
		
		case 12:				char = text_get("key/numpad_key", "5"); break // numpad 5 without numpad lock enabled
		case 20:				char = text_get("key/caps_lock"); break
		case 91:				char = ((platform_get() = e_platform.WINDOWS) ? text_get("key/left_windows") : ((platform_get() = e_platform.MAC_OS) ? text_get("key/left_command") : text_get("key/left_super"))); break
		case 92:				char = ((platform_get() = e_platform.WINDOWS) ? text_get("key/right_windows") : ((platform_get() = e_platform.MAC_OS) ? text_get("key/right_command") : text_get("key/right_super"))); break
		case 93:				char = text_get("key/menu"); break
		case 144:				char = text_get("key/numpad_lock"); break
		case 145:				char = text_get("key/scroll_lock"); break
		case 170:				char = text_get("key/search"); break
		case 173:				char = text_get("key/volume_mute"); break
		case 174:				char = text_get("key/volume_down"); break
		case 175:				char = text_get("key/volume_up"); break
		case 176:				char = text_get("key/next_track"); break
		case 177:				char = text_get("key/prev_track"); break
		case 178:				char = text_get("key/stop_media"); break
		case 179:				char = text_get("key/play_media"); break
		case 186:				char = ";"; break
		case 187:				char = "="; break
		case 188:				char = ","; break
		case 189:				char = "-"; break
		case 190:				char = "."; break
		case 191:				char = "/"; break
		case 192:				char = "`"; break
		case 219:				char = "["; break
		case 220:				char = "\\"; break
		case 221:				char = "]"; break
		case 222:				char = "'"; break
		
		case null:				char = ""; break
		default:				char = chr(keybind[e_keybind_key.CHAR]); break
	}
	
	text = char
	
	if (keybind[e_keybind_key.ALT])
		text = text_get("key/alt") + (text != "" ? (" + " + text) : "")
	
	if (keybind[e_keybind_key.CTRL])
		text = text_get("key/control") + (text != "" ? (" + " + text) : "")
	
	if (keybind[e_keybind_key.SHIFT])
		text = text_get("key/shift") + (text != "" ? (" + " + text) : "")
	
	return text
}
