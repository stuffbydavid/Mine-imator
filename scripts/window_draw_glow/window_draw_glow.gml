/// window_draw_glow()

window_glow_top = max(0, window_glow_top - 0.05 * delta)
window_glow_right = max(0, window_glow_right - 0.05 * delta)
window_glow_bottom = max(0, window_glow_bottom - 0.05 * delta)
window_glow_left = max(0, window_glow_left - 0.05 * delta)

if (window_glow_top > 0)
    draw_gradient(0, 0, window_width, 100, c_yellow, window_glow_top, window_glow_top, 0, 0)

if (window_glow_right > 0)
    draw_gradient(window_width - 100, 0, 100, window_height, c_yellow, 0, window_glow_right, window_glow_right, 0)

if (window_glow_bottom > 0)
    draw_gradient(0, window_height - 100, window_width, 100, c_yellow, 0, 0, window_glow_bottom, window_glow_bottom)

if (window_glow_left > 0)
    draw_gradient(0, 0, 100, window_height, c_yellow, window_glow_left, 0, 0, window_glow_left)
