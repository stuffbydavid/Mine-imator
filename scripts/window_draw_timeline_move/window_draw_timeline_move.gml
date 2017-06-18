/// window_draw_timeline_move()

if (window_busy != "timelinemove")
    return 0

content_x = 0
content_y = 0
content_width = window_width
content_height = window_height
dx = mouse_x + timeline_move_off_x
dy = mouse_y + timeline_move_off_y
window_draw_timeline_move_tree(timeline_move_obj)
