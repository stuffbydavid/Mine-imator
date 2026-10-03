/// @arg texture
/// @arg x
/// @arg y
/// @arg left
/// @arg top
/// @arg width
/// @arg height
/// @arg [xscale]
/// @arg [yscale]
/// @arg [color]
/// @arg [alpha]
/// @arg [resettexture]

function draw_texture_part(tex, xx, yy, left, top, w, h, xsca = 1, ysca = 1, color = c_white, alpha = 1, resettex = true)
{
	// Do not apply UI clipping while compositing into an off-screen texture or surface
	if (shader_clip_active && !is_cpp())
	{
		var target = surface_get_target();
		if (target = -1 || target = application_surface)
		{
			render_set_uniform_int("uClipEnabled", 1)
			render_set_uniform("uClipBox", [ shader_clip_x, shader_clip_y, shader_clip_width, shader_clip_height ])
			render_set_uniform("uScreenSize", [ 1, 1 ])
		}
		else
			render_set_uniform_int("uClipEnabled", 0)
	}

	var tw, th;
	tw = texture_width(tex)
	th = texture_height(tex)
	alpha = draw_get_alpha() * alpha
	
	render_set_texture(tex)
	
	draw_primitive_begin(pr_trianglestrip)
	draw_vertex_texture_color(xx, yy, left / tw, top / th, color, alpha)
	draw_vertex_texture_color(xx + w * xsca, yy, (left + w) / tw, top / th, color, alpha)
	draw_vertex_texture_color(xx, yy + h * ysca, left / tw, (top + h) / th, color, alpha)
	draw_vertex_texture_color(xx + w * xsca, yy + h * ysca, (left + w) / tw, (top + h) / th, color, alpha)
	draw_primitive_end()
	
	if (resettex)
		render_set_texture(0)
}
