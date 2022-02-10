/// draw_box_selection(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function draw_box_selection(xx, yy, ww, hh)
{
	scissor_start(xx, yy, ww, hh)
	render_set_culling(false)
		
	draw_box(xx, yy, ww, hh, false, c_accent_overlay, a_accent_overlay)
		
	// Top
	for (var i = 1; i < ceil(ww / 64) + 1; i++)
		draw_image(spr_selection_outline, 0, (xx + (64 * i)), yy + 2, 2, 1, c_accent, 1, 90)
			
	// Bottom
	for (var i = 1; i < ceil(ww / 64) + 1; i++)
		draw_image(spr_selection_outline, 0, (xx + ww - (64 * i)), yy + hh - 2, 2, 1, c_accent, 1, -90)
		
	// Right
	for (var i = 0; i < ceil(hh / 64); i++)
		draw_image(spr_selection_outline, 0, xx + ww, yy + (64 * i), 2, 1, c_accent, 1, 180)
		
	// Left
	for (var i = 0; i < ceil(hh / 64); i++)
		draw_image(spr_selection_outline, 0, xx, yy + hh - (64 * i), 2, 1, c_accent, 1)
		
	render_set_culling(true)
	scissor_done()
}
