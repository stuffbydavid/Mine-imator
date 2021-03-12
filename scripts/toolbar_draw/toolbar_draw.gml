/// toolbar_draw()

content_x = 0
content_y = 0
content_width = window_width
content_height = toolbar_size
content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)

dx = content_x + 10
dy = content_y

// Background
draw_box(content_x, content_y, content_width, content_height, false, c_background, 1)
draw_divide(content_x, content_y + content_height, content_width)
draw_gradient(content_x, content_y + content_height, content_width, shadow_size, c_black, shadow_alpha, shadow_alpha, 0, 0)

var capwid;

draw_set_font(font_value)

capwid = string_width(text_get("toolbarfile")) + 16
toolbar_draw_button("toolbarfile", dx, dy, capwid)
dx += capwid + 8

capwid = string_width(text_get("toolbaredit")) + 16
toolbar_draw_button("toolbaredit", dx, dy, capwid)
dx += capwid + 8

capwid = string_width(text_get("toolbarrender")) + 16
toolbar_draw_button("toolbarrender", dx, dy, capwid)
dx += capwid + 8

capwid = string_width(text_get("toolbarview")) + 16
toolbar_draw_button("toolbarview", dx, dy, capwid)
dx += capwid + 8

capwid = string_width(text_get("toolbarhelp")) + 16
toolbar_draw_button("toolbarhelp", dx, dy, capwid)
dx += capwid + 8

/*
// Side menu
draw_button_sidemenu(dx, dy, 24, 24)
dx += (24 + 12)

// Undo
tip_set_shortcut(setting_key_undo, setting_key_undo_control)
draw_button_icon("toolbarundo", dx, dy, 24, 24, false, icons.UNDO, action_toolbar_undo, (history_pos >= history_amount), "toolbarundotip")
dx += (24 + 8)

// Redo
tip_set_shortcut(setting_key_redo, setting_key_redo_control)
draw_button_icon("toolbarredo", dx, dy, 24, 24, false, icons.REDO, action_toolbar_redo, (history_pos = 0), "toolbarredotip")
*/
