/// preview_zoom_text(preview, text, font)
/// @arg preview
/// @arg text
/// @arg font

function preview_zoom_text(preview, text, font)
{
	if (preview.view_width <= 0 || preview.view_height <= 0)
		return 0

	var str, prevfont, width, height;
	str = (text = "" ? default_text : text)
	prevfont = draw_get_font()
	draw_set_font(font)
	width = string_width(str) + 1
	height = string_height_ext(str, string_height(" ") - 2, -1) + 4
	draw_set_font(prevfont)

	var halfwidth, halfheight, horizontal, vertical, d, fovtan;
	halfwidth = width / 2
	halfheight = height / 2
	horizontal = halfwidth * abs(dsin(preview.xyangle))
	vertical = halfwidth * abs(dcos(preview.xyangle) * dsin(preview.zangle)) + halfheight * abs(dcos(preview.zangle))
	d = halfwidth * abs(dcos(preview.xyangle) * dcos(preview.zangle)) + halfheight * abs(dsin(preview.zangle))
	fovtan = tan(degtorad(preview.fov / 2))

	preview.zoom = clamp(60 / max(40, (d + max(horizontal / (fovtan * preview.view_width / preview.view_height), vertical / fovtan)) * 1.15), 0.1, 100)
	preview.goalzoom = preview.zoom
	preview.update = true
}
