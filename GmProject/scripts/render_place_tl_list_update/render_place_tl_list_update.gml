/// @desc Rebuild compact picking IDs in render order.

function render_place_tl_list_update()
{
	var count, index;
	count = 1
	for (var depthindex = 0; depthindex < 3; depthindex++)
		count += ds_list_size(render_list[depthindex])
	
	render_place_tl_list = array_create(count, 0)
	index = 1
	for (var depthindex = 0; depthindex < 3; depthindex++)
	{
		var list = render_list[depthindex];
		for (var i = 0; i < ds_list_size(list); i++)
		{
			var tl = list[|i];
			tl.render_place_id = index
			render_place_tl_list[index] = tl
			index++
		}
	}
	
	render_place_tl_list_id++
}
