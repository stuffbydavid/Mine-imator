/// @desc Rebuild compact picking IDs from the project timeline list.

function render_place_tl_list_update()
{
	var count = ds_list_size(project_timeline_list);
	render_place_tl_list = array_create(count + 1, 0)
	
	for (var i = 0; i < count; i++)
	{
		var tl = project_timeline_list[|i];
		tl.render_place_id = i + 1
		render_place_tl_list[i + 1] = tl
	}
	
	render_place_tl_list_id++
}
