/// app_startup_window()

globalvar current_step, minute_steps, delta;
current_step = 0
minute_steps = 60 * 60
delta = 1

log("Windows startup")

window_width = 1
window_height = 1
window_set_focus()
window_set_min_width(100)
window_set_min_height(100)
window_set_caption("Mine-imator")

window_busy = ""
window_focus = ""

window_glow_top = 0
window_glow_right = 0
window_glow_bottom = 0
window_glow_left = 0

window_cover = 1

mouse_cursor = cr_default
mouse_current_x = 0
mouse_current_y = 0
mouse_previous_x = 0
mouse_previous_y = 0
mouse_move = 0
mouse_still = 0
app_mouse_clear()

dragger_drag_value = 0
meter_drag_value = 0
wheel_drag_value = 0
wheel_drag_moon = false

sortlist_resize = null
sortlist_resize_column = 0
sortlist_resize_column_x = 0

content_x = 0
content_y = 0
content_width = 0
content_height = 0
content_mouseon = false
content_tab = null
content_direction = null

dx = 0
dy = 0
dw = 0
dh = 0
dx_start = 0
dy_start = 0
dw_start = 0
dh_start = 0
tab = null
tab_control_h = 0
