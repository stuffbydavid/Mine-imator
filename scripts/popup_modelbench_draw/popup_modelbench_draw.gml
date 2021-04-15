/// popup_modelbench_draw()

dy += 8

// Screenshot
draw_image(spr_modelbench_ad, 0, dx + dw / 2, dy)
dy += sprite_get_height(spr_modelbench_ad) + 8

// Info
draw_label(string_limit_ext(text_get("modelbenchinfo"), dw + 24, dh), dx + dw / 2, dy, fa_center, fa_top, c_text_main, a_text_main, font_value)
dy += 34 + 16

draw_set_font(font_button)
var buttonx = string_width(text_get("modelbenchdownload")) + button_padding;

tab_control_button_label()

// Download
if (draw_button_label("modelbenchdownload", dx + dw - buttonx, dy_start + dh - 32))
{
	popup_modelbench.not_now = true
	popup_close()
}

// Not now
buttonx += 12 + (string_width(text_get("modelbenchnotnow")) + button_padding)
if (draw_button_label("modelbenchnotnow", dx + dw - buttonx, dy_start + dh - 32, null, null, e_button.SECONDARY))
{
	popup_modelbench.not_now = true
	popup_close()
}

// Don't show again
if (draw_checkbox("modelbenchdontshow", dx, dy, popup_modelbench.hidden, null))
	popup_modelbench.hidden = !popup_modelbench.hidden

tab_next()
