/// view_click(view, camera)
/// @arg view
/// @arg camera

var view, cam, surf;
view = argument0
cam = argument1

surface_depth_disable(false)
surf = surface_create(content_width, content_height)
surface_depth_disable(true)

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
		while (tl.parent != app && !tl.parent.lock)
			tl = tl.parent
			
	// Select
	action_tl_select(tl)
	
	// Jump in list
	if (setting_timeline_select_jump)
	{
		// Find pos
		var pos;
		for (pos = 0; pos < ds_list_size(tree_visible_list); pos++)
			if (tree_visible_list[|pos] = tl)
				break
				
		if (pos < timeline_list_first || pos >= timeline_list_first + timeline_list_visible)
		{
			// Set scrollbar
			var newval = pos - floor(timeline_list_visible / 2);
			newval = min(newval, ds_list_size(tree_visible_list) - timeline_list_visible)
			newval = max(0, newval)
			timeline.ver_scroll.value = newval * timeline.ver_scroll.snap_value
		}
	}
}
else
	if (!keyboard_check(vk_shift))
		action_tl_deselect_all()
	
surface_free(surf)
