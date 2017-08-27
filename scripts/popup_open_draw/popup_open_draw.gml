/// popup_open_draw()

// Recent
draw_label(text_get("openrecent") + ":", dx, dy)
draw_recent(dx, dy + 22, dw, dh - 80, popup.recent_scroll)

// Browse
dw = 100
dh = 32
dx = content_x + content_width / 2 - dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("openbrowse", dx, dy, dw, 32))
	project_load()

// Cancel
dx = content_x + content_width / 2 + 4
if (draw_button_normal("opencancel", dx, dy, dw, 32))
	popup_close()
