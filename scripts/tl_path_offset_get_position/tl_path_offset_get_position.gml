/// tl_path_offset_get_position(path, offset)
/// @arg path
/// @arg offset

function tl_path_offset_get_position(path, offset)
{
	var t, points;
	points = array_length(path.path_table) - 1
	t = (offset / path.path_length) * points
	
	return spline_get_point(t, path.path_table, path.path_closed, path.path_closed ? points : 0)
}