/// @desc Returns quick scene bounds as two points.

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

		var lx, ly, lz, ux, uy, uz;
		
		// Structures need their mesh extents, other timelines use a block-sized box
		if (type_is_structure(type))
		{
			var bounds = tl_get_bounds();
			if (bounds = null)
				continue
			
			lx = bounds[0][X]
			ly = bounds[0][Y]
			lz = bounds[0][Z]
			ux = bounds[1][X]
			uy = bounds[1][Y]
			uz = bounds[1][Z]
		}
		else
		{
			var ex, ey, ez;
			ex = (abs(matrix_render[@0]) + abs(matrix_render[@4]) + abs(matrix_render[@8])) * block_half_size
			ey = (abs(matrix_render[@1]) + abs(matrix_render[@5]) + abs(matrix_render[@9])) * block_half_size
			ez = (abs(matrix_render[@2]) + abs(matrix_render[@6]) + abs(matrix_render[@10])) * block_half_size
			lx = world_pos[@X] - ex
			ly = world_pos[@Y] - ey
			lz = world_pos[@Z] - ez
			ux = world_pos[@X] + ex
			uy = world_pos[@Y] + ey
			uz = world_pos[@Z] + ez
		}

		if (empty)
		{
			minpos = point3D(lx, ly, lz)
			maxpos = point3D(ux, uy, uz)
			empty = false
		}
		else
		{
			minpos[@X] = min(minpos[@X], lx)
			minpos[@Y] = min(minpos[@Y], ly)
			minpos[@Z] = min(minpos[@Z], lz)
			maxpos[@X] = max(maxpos[@X], ux)
			maxpos[@Y] = max(maxpos[@Y], uy)
			maxpos[@Z] = max(maxpos[@Z], uz)
		}
	}
	
	return [ minpos, maxpos ]
}
