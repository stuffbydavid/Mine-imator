function tl_update_depth()
{
	for (var depthindex = 0; depthindex < 3; depthindex++)
		ds_list_delete_value(render_list[depthindex], id)
	
	var list, pos;
	list = render_list[sign(depth) + 1]
	for (pos = 0; pos < ds_list_size(list); pos++)
		if (list[|pos].depth > depth)
			break
	
	ds_list_insert(list, pos, id)
	
	render_place_tl_list = null
	render_scene_bounds = null
	
	view_changed()
}
