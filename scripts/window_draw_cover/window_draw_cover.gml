/// window_draw_cover()

function window_draw_cover()
{
	if (popup_block_ani > 0)
		draw_box(0, 0, window_width, window_height, false, c_black, ease(popup_block_ani_ease, popup_block_ani) * 0.45)
}
