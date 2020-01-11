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

capwid = text_caption_width("frameeditortextalignment", "frameeditortexthalign", "frameeditortextvalign")

// Alignment
tab_control(15)
draw_label(text_get("frameeditortextalignment") + ":", dx, dy)
tab_next()

// Horizontal
tab_control(24)
draw_button_menu("frameeditortexthalign", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.TEXT_HALIGN], text_get("frameeditortext" + tl_edit.value[e_value.TEXT_HALIGN]), action_tl_frame_text_halign, null, null, capwid)
tab_next()

// Vertical
tab_control(24)
draw_button_menu("frameeditortextvalign", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.TEXT_VALIGN], text_get("frameeditortext" + tl_edit.value[e_value.TEXT_VALIGN]), action_tl_frame_text_valign, null, null, capwid)
tab_next()
	
// Anti-aliasing
tab_control_checkbox()
draw_checkbox("frameeditortextaa", dx, dy, tl_edit.value[e_value.TEXT_AA], action_tl_frame_text_aa)
tab_next()