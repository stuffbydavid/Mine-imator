/// panel_move_draw()

var boxx, boxy, boxw, boxh, tabsh;
boxx = mouse_x + tab_move_box_x
boxy = mouse_y + tab_move_box_y
boxw = tab_move_box_width
boxh = tab_move_box_height
tabsh = 28

content_x = boxx
content_y = boxy
content_width = boxw
content_height = boxh

draw_box(content_x, content_y, content_width, content_height, false, c_accent, 0.25)

content_y += tabsh
content_width = boxw
content_height -= tabsh

content_mouseon = false
content_tab = tab_move
content_direction = tab_move_direction
