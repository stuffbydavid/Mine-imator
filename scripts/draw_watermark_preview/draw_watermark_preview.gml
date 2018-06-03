/// draw_watermark_preview(x, y, width)
/// @arg x
/// @arg y
/// @arg width

var xx, yy, width, height;
xx = argument0
yy = argument1
width = argument2

var preview_surf, preview_scale;
preview_scale = (argument2/960)
preview_surf = surface_create(argument2, floor(preview_scale * 540))

tab_control(floor(preview_scale * 540))

surface_set_target(preview_surf)
{
	gpu_set_tex_filter(true)
	draw_image(spr_watermark_preview, 0, 0, 0, preview_scale, preview_scale)
	gpu_set_tex_filter(false)
	
	render_watermark_image(argument2, floor(preview_scale * 540))
}
surface_reset_target()

draw_surface(preview_surf, xx, yy)

surface_free(preview_surf)

tab_next()