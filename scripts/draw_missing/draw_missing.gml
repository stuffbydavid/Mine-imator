/// draw_missing(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function draw_missing(xx, yy, w, h)
{
	draw_box(xx, yy, w, h, false, c_fuchsia, 1)
	draw_box(xx + w / 2, yy, w / 2, h / 2, false, c_black, 1)
	draw_box(xx, yy + h / 2, w / 2, h / 2, false, c_black, 1)
}
