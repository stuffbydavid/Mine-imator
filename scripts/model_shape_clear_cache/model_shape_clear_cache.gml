/// model_shape_clear_cache(shape)
/// @desc Deletes bounding box/vbuffer cacha data and clears map

function model_shape_clear_cache(shape)
{
	// Clear bend cache, bendkey contains "X,Y,Z" string paired with an array; [vbuffer, bbox]
	var bendkey = ds_map_find_first(shape.vbuffer_cache);
	while (!is_undefined(bendkey))
	{
		var cache = shape.vbuffer_cache[? bendkey];
		
		if (is_array(cache))
		{
			vbuffer_destroy(cache[0])
			
			if (is_struct(cache[1]))
				delete cache[1]
		}
		
		bendkey = ds_map_find_next(shape.vbuffer_cache, bendkey)
	}
	ds_map_clear(shape.vbuffer_cache)
}
