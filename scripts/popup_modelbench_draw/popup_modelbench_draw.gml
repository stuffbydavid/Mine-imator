/// popup_modelbench_draw()

// Info
draw_label(string_limit_ext(text_get("modelbenchinfo"), dw, dh), dx + content_width / 2, dy, fa_center, fa_top)

// Screenshot
draw_image(spr_modelbench_ad, 0, dx + content_width / 2 - 300, dy + 32)

// Download
dw = 248
dh = 64
dx = content_x + content_width / 2 - dw / 2
dy = content_y + content_height - 40 - dh
if (draw_button_normal("modelbenchdownload", dx, dy, dw, dh))
{
	open_url(link_modelbench)
	popup_modelbench.hidden = true
	popup_close()
}

// Close options
dw = 120
dh = 32
dx = content_x + content_width / 2 - dw - 4
dy = content_y + content_height - dh

if (draw_button_normal("modelbenchnotnow", dx, dy, dw, dh))
{
	popup_modelbench.not_now = true
	popup_close()
}
	
dx += dw + 8
if (draw_button_normal("modelbenchdontshow", dx, dy, dw, dh))
{
	popup_modelbench.hidden = true
	popup_close()
}