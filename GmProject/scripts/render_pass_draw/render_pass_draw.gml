/// render_pass_draw(pass, surf, x, y, width, height)
/// @arg pass
/// @arg surf
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function render_pass_draw(pass, surf, xx, yy, width, height)
{
	if (!surface_exists(surf))
		return 0
	
	render_shader_obj = shader_map[?shader_render_pass]
	with (render_shader_obj)
	{
		shader_set(shader)
		render_set_uniform_int("uChannel", 0)
	}
	
	draw_surface_ext(surf, xx, yy, width / surface_get_width(surf), height / surface_get_height(surf), 0, c_white, 1)
	
	with (render_shader_obj)
		shader_clear()
}