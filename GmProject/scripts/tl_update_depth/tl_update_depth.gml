function tl_update_depth()
{
	ds_list_delete_value(render_list, id)
	
	var pos;
	for (pos = 0; pos < ds_list_size(render_list); pos++)
		if (render_list[|pos].depth > depth)
			break
	
	ds_list_insert(render_list, pos, id)
	
	render_list_depth_dirty = true
	render_scene_bounds = null
	
	view_changed()
}
