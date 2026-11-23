function spline_subdivide(points, closed)
{
	var arr, amount;
	arr = []
	amount = array_length(points)
	
	// Add point between start and end to connect
	if (closed)
		array_push(arr, point_lerp(points[0], points[amount - 1], .5))

	for (var i = 0; i < array_length(points); i++)
	{
		var next = (closed ? mod_fix(i + 1, amount) : clamp(i + 1, 0, amount - 1));

		array_push(arr, points[i])

		if (i > 0 || closed)
			array_push(arr, point_lerp(points[i], points[next], .5))
	}
	
	return arr
}
