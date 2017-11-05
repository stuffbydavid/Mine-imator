/// panel_move_draw()

var boxx, boxy, boxw, boxh, tabsh;
boxx = mouse_x + tab_move_box_x
boxy = mouse_y + tab_move_box_y
boxw = tab_move_box_width
boxh = tab_move_box_height
tabsh = 28

draw_set_alpha(0.5)

content_x = boxx
content_y = boxy
content_width = boxw
content_height = boxh

draw_box(boxx + tab_move_x, boxy, tab_move_width, tabsh - 1, false, setting_color_interface, 1)
draw_box(boxx, boxy + tabsh, boxw, boxh - tabsh, false, setting_color_interface, 1)
draw_label(tab_move_name, boxx + tab_move_x + tab_move_width / 2 - 5 * tab_move.closeable, boxy + tabsh / 2, fa_center, fa_middle, null, 1, setting_font_bold)

content_y += tabsh
content_width = boxw
content_height -= tabsh

content_mouseon = false
content_tab = tab_move
content_direction = tab_move_direction
panel_draw_content()

draw_set_alpha(1)
