/// minecraft_assets_load_place_target(map)
/// @arg map

function minecraft_assets_load_place_target(map)
{
	var newmap, key;
	newmap = ds_map_create()

	// Map keys to parent action arrays with an empty target
	key = ds_map_find_first(map)
	while (!is_undefined(key))
	{
		var partmap = map[?key];
		if (ds_map_valid(partmap))
		{
			var sca = vec3(1);
			if (ds_list_valid(partmap[?"scale"]))
				sca = value_get_point3D(partmap[?"scale"], vec3(1))
			else if (is_real(partmap[?"scale"]))
				sca = vec3(value_get_real(partmap[?"scale"], 1))
			
			newmap[?key] = array(null,
				value_get_real(partmap[?"bend"], true),
				value_get_point3D(partmap[?"position"], vec3(0)),
				value_get_point3D(partmap[?"rotation"], vec3(0)),
				sca,
				value_get_real(partmap[?"lock"], false)
			)
		}
		key = ds_map_find_next(map, key)
	}

	return newmap
}
