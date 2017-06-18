/// app_update_mouse()

window_set_cursor(mouse_cursor)

mouse_cursor = cr_default
mouse_previous_x = mouse_current_x
mouse_previous_y = mouse_current_y
mouse_current_x = mouse_x
mouse_current_y = mouse_y
mouse_dx = mouse_x - mouse_previous_x
mouse_dy = mouse_y - mouse_previous_y
mouse_left_pressed = (!mouse_left && mouse_check_button(mb_left))
mouse_left_released = (mouse_left && !mouse_check_button(mb_left))
mouse_left = mouse_check_button(mb_left)
mouse_right_pressed = (!mouse_right && mouse_check_button(mb_right))
mouse_right_released = (mouse_right && !mouse_check_button(mb_right))
mouse_right = mouse_check_button(mb_right)
mouse_middle_pressed = (!mouse_middle && mouse_check_button(mb_middle))
mouse_middle = mouse_check_button(mb_middle)
mouse_wheel = mouse_wheel_down() - mouse_wheel_up()

if (mouse_left_pressed)
{
    mouse_click_x = mouse_x
    mouse_click_y = mouse_y
}
else if (mouse_left)
    mouse_move = max(abs(mouse_x - mouse_click_x), abs(mouse_y - mouse_click_y))
else
    mouse_move = 0
    
if (mouse_previous_x != mouse_x || mouse_previous_y != mouse_y)
    mouse_still = 0
else
    mouse_still++
