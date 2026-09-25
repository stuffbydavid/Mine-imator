/// preview_zoom_text(preview, text, resource)
/// @arg preview
/// @arg text
/// @arg resource

function preview_zoom_text(preview, text, resource)
{
	if (preview.view_width <= 0 || preview.view_height <= 0)
		return 0

	var str, res, prevfont, width, height, scale;
	str = (text = "" ? default_text : text)
	res = res_eval(resource)
	prevfont = draw_get_font()
	draw_set_font(res.font)
	width = string_width(str) + 1
	height = string_height_ext(str, string_height(" ") - 2, -1) + 4
	draw_set_font(prevfont)
	scale = res.font_minecraft ? 1 : 8 / 48
	width *= scale
	height *= scale

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
