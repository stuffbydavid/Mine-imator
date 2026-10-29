/// @desc Returns scene bounds as two points.

function render_world_get_bounds()
{
	var minpos, maxpos, empty;
	minpos = point3D(0)
	maxpos = point3D(0)
	empty = true
	
	with (obj_timeline)
	{
		if (!render_visible || type = e_tl_type.CAMERA || type_is_light(type))
			continue

		var bounds, lower, upper;
		bounds = tl_get_bounds()
		if (bounds = null)
			continue

		lower = bounds[0]
		upper = bounds[1]

		if (empty)
		{
			minpos = point3D_copy(lower)
			maxpos = point3D_copy(upper)
			empty = false
		}
		else
		{
			minpos[@ X] = min(minpos[X], lower[X])
			minpos[@ Y] = min(minpos[Y], lower[Y])
			minpos[@ Z] = min(minpos[Z], lower[Z])
			maxpos[@ X] = max(maxpos[X], upper[X])
			maxpos[@ Y] = max(maxpos[Y], upper[Y])
			maxpos[@ Z] = max(maxpos[Z], upper[Z])
		}
	}
	
	return [ minpos, maxpos ]
}
