/// model_shape_clear_cache(cachelist, [destroy])
/// @arg cachelist
/// @arg [destroy]
/// @desc Deletes bounding box/vbuffer cacha data and clears map

function model_shape_clear_cache(cachelist, destroy = false)
{
	for (var i = 0; i < ds_list_size(cachelist); i++)
	{
		var map = cachelist[|i];
		
		// Clear bend cache, bendkey contains "X,Y,Z" string paired with an array; [vbuffer, bbox]
		var bendkey = ds_map_find_first(map);
		while (!is_undefined(bendkey))
		{
			var cache = map[? bendkey];
			
			if (is_array(cache))
			{
				vbuffer_destroy(cache[0])
			
				if (is_struct(cache[1]))
					delete cache[1]
				
				show_debug_message("ye")
			}
			
			bendkey = ds_map_find_next(map, bendkey)
		}
		
		if (destroy)
			ds_map_destroy(map)
		else
			ds_map_clear(map)
	}
	
	if (destroy)
		ds_list_destroy(cachelist)
}
