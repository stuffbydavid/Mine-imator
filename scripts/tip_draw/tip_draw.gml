/// tip_draw()

var cx, cy, text;

if (tip_show)
    tip_alpha = min(1, tip_alpha + 0.1 * delta)
else
    tip_alpha = max(0, tip_alpha - 0.1 * delta)

if (mouse_wheel<>0 || mouse_left)
    tip_alpha = 0

if (tip_alpha = 0)
{
    tip_box_x = null
    tip_box_y = null
    return 0
}

// Box
draw_set_alpha(tip_alpha)
draw_set_color(setting_color_tips)
draw_box_rounded(tip_x, tip_y, tip_w, tip_h, setting_color_tips, 1, 
    (!tip_location_x || tip_location_y), 
    (tip_location_x || tip_location_y), 
    (tip_location_x || !tip_location_y), 
    (!tip_location_x || !tip_location_y), 
    4, spr_rounded_4)

// Arrow
if (tip_location_x) // To right
    cx = tip_x
else // To left
    cx = tip_x + tip_w

if (tip_location_y) // Above
    cy = tip_y + tip_h
else // Below
    cy = tip_y
    
render_set_culling(false)
draw_image(spr_tip_arrow, 0, cx, cy, test(tip_location_x, 1, -1), test(tip_location_y, 1, -1), setting_color_tips, 1)
render_set_culling(true)

// Text
draw_set_color(setting_color_tips_text)
draw_text(tip_x + tip_padding, tip_y + tip_padding, tip_text_wrap)
draw_set_alpha(1)

tip_show = false
