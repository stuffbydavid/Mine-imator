/// draw_watermark_preview(x, y, width)
/// @arg x
/// @arg y
/// @arg width

function draw_watermark_preview(xx, yy, width)
{
	var preview_surf, preview_scale;
	preview_scale = (width/960)
	preview_surf = surface_create(width, floor(preview_scale * 540))
	
	tab_control(floor(preview_scale * 540))
	
	surface_set_target(preview_surf)
	{
		gpu_set_tex_filter(true)
		draw_image(spr_watermark_preview, 0, 0, 0, preview_scale, preview_scale)
		gpu_set_tex_filter(false)
		
		render_watermark_image(width, floor(preview_scale * 540))
	}
	surface_reset_target()
	
	draw_surface(preview_surf, xx, yy)
	
	surface_free(preview_surf)
	
	tab_next()
}
