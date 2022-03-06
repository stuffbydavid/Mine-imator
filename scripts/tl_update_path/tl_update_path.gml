/// tl_update_path()

function tl_update_path()
{
	if (type != e_tl_type.PATH)
		return 0
	
	path_update = false
	
	// Clear
	if (path_vbuffer != null)
	{
		vbuffer_destroy(path_vbuffer)
		path_vbuffer = null
	}
	
	ds_list_clear(path_points_list)
	path_table = []
	
	// Get points from childen points
	for (var i = 0; i < ds_list_size(tree_list); i++)
	{
		var tl = tree_list[|i];
		
		if (tl.type = e_tl_type.PATH_POINT)
			ds_list_add(path_points_list, [tl.value[e_value.POS_X], tl.value[e_value.POS_Y], tl.value[e_value.POS_Z], tl.value[e_value.PATH_POINT_ANGLE], tl.value[e_value.PATH_POINT_SCALE]])
	}
	
	// Update timelines
	with (obj_timeline)
	{
		if (value[e_value.PATH_OBJ] = other.id)
			update_matrix = true
	}
	
	// Not enough points
	if (ds_list_size(path_points_list) < 2)
	{
		with (app)
			tl_update_matrix()
		
		return 0
	}
	
	var detail, splinepoints;
	detail = (ds_list_size(path_points_list) + ((ds_list_size(path_points_list) - 1 + path_closed) * path_detail))
	
	// Subdivide points
	splinepoints = spline_subdivide(ds_list_create_array(path_points_list), path_closed)
	
	// Calculate distance between points
	var points_distance = [];
	var sampleprev, sample;
	path_length = 0
	
	for (var i = 0; i < array_length(splinepoints); i++)
	{
		sampleprev = spline_get_point(i, splinepoints, path_closed)
		points_distance[i] = 0
		
		for (var j = 0; j <= 1; j += 0.05)
		{
			sample = spline_get_point(i + j, splinepoints, path_closed)
			points_distance[i] += point3D_distance(sampleprev, sample)
			sampleprev = sample
		}
		
		path_length += points_distance[i]
	}
	
	if (path_length = 0)
	{
		path_table[0] = [0, 0, 0, 0, 0]
		return 0
	}
	
	// Move along path length and record points
	for (var i = 0; i < detail; i++)
	{
		var length = (i/(detail - 1)) * path_length;
		
		var j = 0;
		while (length > points_distance[j])
		{
			length -= points_distance[j]
			j++
		}
		
		path_table[i] = spline_get_point(j + (length / points_distance[j]), splinepoints, path_closed)
	}
	
	if (path_shape_generate)
		path_vbuffer = vbuffer_create_spline(path_table, path_shape_radius, path_shape_detail, path_closed, !path_shape_tube, path_shape_tex_length)
	
	with (app)
		tl_update_matrix()
}