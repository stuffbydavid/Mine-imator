/// tab_frame_editor_text()

var capwid = text_caption_width("frameeditortexttext", "frameeditortextfont");

if (tl_edit.temp = null || tl_edit.type != e_tl_type.TEXT)
	return 0
	
// Text
tab_control(110)
tab.text.tbx_text.text = tl_edit.value[e_value.TEXT]
draw_inputbox("frameeditortexttext", dx, dy, dw, tl_edit.text, tab.text.tbx_text, action_tl_frame_text, capwid, 110)
tab_next()

// Font
var text;
if (tl_edit.value[e_value.TEXT_FONT] = null)
	text = text_get("listdefault", tl_edit.temp.text_font.display_name)
else
	text = tl_edit.value[e_value.TEXT_FONT].display_name
tab_control(32)
draw_button_menu("frameeditortextfont", e_menu.LIST, dx, dy, dw, 32, tl_edit.value[e_value.TEXT_FONT], text, action_tl_frame_text_font)
tab_next()