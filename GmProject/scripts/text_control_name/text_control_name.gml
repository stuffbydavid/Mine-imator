/// text_control_name(keybind)
/// @arg keybind

function text_control_name(keybind)
{
	var char, text;
	
	switch (keybind[e_keybind_key.CHAR])
	{
		case vk_left:			char = text_get("keyleft"); break;
		case vk_right:			char = text_get("keyright"); break;
		case vk_up:				char = text_get("keyup"); break;
		case vk_down:			char = text_get("keydown"); break;
		//case vk_return:
		case vk_enter:			char = text_get("keyenter"); break;
		case vk_escape:			char = text_get("keyescape"); break;
		case vk_space:			char = text_get("keyspace"); break;
		case vk_shift:			char = text_get("keyshift"); break;
		case vk_lshift:			char = text_get("keyleftshift"); break;
		case vk_rshift:			char = text_get("keyrightshift"); break;
		case vk_alt:			char = text_get("keyalt"); break;
		case vk_lalt:			char = text_get("keyleftalt"); break;
		case vk_ralt:			char = text_get("keyrightalt"); break;
		case vk_control:		char = text_get("keycontrol"); break;
		case vk_lcontrol:		char = text_get("keyleftcontrol"); break;
		case vk_rcontrol:		char = text_get("keyrightcontrol"); break;
		case vk_backspace:		char = text_get("keybackspace"); break;
		case vk_tab:			char = text_get("keytab"); break;
		case vk_home:			char = text_get("keyhome"); break;
		case vk_end:			char = text_get("keyend"); break;
		case vk_delete:			char = text_get("keydelete"); break;
		case vk_insert:			char = text_get("keyinsert"); break;
		case vk_pageup:			char = text_get("keypageup"); break;
		case vk_pagedown:		char = text_get("keypagedown"); break;
		case vk_pause:			char = text_get("keypause"); break;
		case vk_printscreen:	char = text_get("keyprintscreen"); break;
		case vk_f1:				char = "F1"; break;
		case vk_f2:				char = "F2"; break;
		case vk_f3:				char = "F3"; break;
		case vk_f4:				char = "F4"; break;
		case vk_f5:				char = "F5"; break;
		case vk_f6:				char = "F6"; break;
		case vk_f7:				char = "F7"; break;
		case vk_f8:				char = "F8"; break;
		case vk_f9:				char = "F9"; break;
		case vk_f10:			char = "F10"; break;
		case vk_f11:			char = "F11"; break;
		case vk_f12:			char = "F12"; break;
		case vk_numpad0:		char = text_get("keynumpadkey", "0"); break;
		case vk_numpad1:		char = text_get("keynumpadkey", "1"); break;
		case vk_numpad2:		char = text_get("keynumpadkey", "2"); break;
		case vk_numpad3:		char = text_get("keynumpadkey", "3"); break;
		case vk_numpad4:		char = text_get("keynumpadkey", "4"); break;
		case vk_numpad5:		char = text_get("keynumpadkey", "5"); break;
		case vk_numpad6:		char = text_get("keynumpadkey", "6"); break;
		case vk_numpad7:		char = text_get("keynumpadkey", "7"); break;
		case vk_numpad8:		char = text_get("keynumpadkey", "8"); break;
		case vk_numpad9:		char = text_get("keynumpadkey", "9"); break;
		case vk_multiply:		char = text_get("keynumpadkey", "*"); break;
		case vk_divide:			char = text_get("keynumpadkey", "/"); break;
		case vk_add:			char = text_get("keynumpadkey", "+"); break;
		case vk_subtract:		char = text_get("keynumpadkey", "-"); break;
		case vk_decimal:		char = text_get("keynumpadkey", "."); break;
		
		case 12:				char = text_get("keynumpadkey", "5"); break; // numpad 5 without numpad lock enabled
		case 20:				char = text_get("keycapslock"); break;
		case 91:				char = ((platform_get() = e_platform.WINDOWS) ? text_get("keyleftwindows") : ((platform_get() = e_platform.MAC_OS) ? text_get("keyleftcommand") : text_get("keyleftsuper"))); break;
		case 92:				char = ((platform_get() = e_platform.WINDOWS) ? text_get("keyrightwindows") : ((platform_get() = e_platform.MAC_OS) ? text_get("keyrightcommand") : text_get("keyrightsuper"))); break;
		case 93:				char = text_get("keymenu"); break;
		case 144:				char = text_get("keynumpadlock"); break;
		case 145:				char = text_get("keyscrolllock"); break;
		case 170:				char = text_get("keysearch"); break;
		case 173:				char = text_get("keyvolumemute"); break;
		case 174:				char = text_get("keyvolumedown"); break;
		case 175:				char = text_get("keyvolumeup"); break;
		case 176:				char = text_get("keynexttrack"); break;
		case 177:				char = text_get("keyprevtrack"); break;
		case 178:				char = text_get("keystopmedia"); break;
		case 179:				char = text_get("keyplaymedia"); break;
		case 186:				char = ";"; break;
		case 187:				char = "="; break;
		case 188:				char = ","; break;
		case 189:				char = "-"; break;
		case 190:				char = "."; break;
		case 191:				char = "/"; break;
		case 192:				char = "`"; break;
		case 219:				char = "["; break;
		case 220:				char = "\\"; break;
		case 221:				char = "]"; break;
		case 222:				char = "'"; break;
		
		case vk_nokey:
		case vk_anykey:
		case null:				char = ""; break;
		default:				char = chr(keybind[e_keybind_key.CHAR]); break;
	}
	
	text = char
	
	if (keybind[e_keybind_key.ALT])
		text = text_get("keyalt") + (text != "" ? (" + " + text) : "")
	
	if (keybind[e_keybind_key.CTRL])
		text = text_get("keycontrol") + (text != "" ? (" + " + text) : "")
	
	if (keybind[e_keybind_key.SHIFT])
		text = text_get("keyshift") + (text != "" ? (" + " + text) : "")
	
	return text
}