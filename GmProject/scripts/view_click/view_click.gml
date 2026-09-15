/// view_click(view, camera)
/// @arg view
/// @arg camera

function view_click(view, cam)
{
	var surf = surface_create(content_width, content_height);
	
	render_camera = cam
	render_ratio = content_width / content_height
	
	surface_set_target(surf)
	{
		draw_clear(c_black)
		render_world_start()
		render_world(e_render_mode.CLICK)
		render_world_done()
	}
	surface_reset_target()
	
	var tl = surface_getpixel(surf, mouse_x - content_x, mouse_y - content_y);
	
	if (tl > 0)
	{
		// Find timeline to select
		if (!tl_edit && !keyboard_check(vk_control))
			while (tl.parent != app && !tl.parent.lock && tl_update_list_filter(tl.parent))
				tl = tl.parent
		
		// Select
		action_tl_select(tl)
		
		// Jump in list
		if (setting_timeline_select_jump)
			tl_jump(tl)
	}
	else
		if (!keyboard_check(vk_shift))
			action_tl_deselect_all()
	
	surface_free(surf)
}
