/// @desc Returns scene bounds as two points.

function render_get_scene_bounds()
{
	var minimum, maximum, empty;
	minimum = point3D(0)
	maximum = point3D(0)
	empty = true
	
	for (var i = 0; i < ds_list_size(render_list); i++)
	{
		with (render_list[|i])
		{
			if (hide || !render_visible || (!app.place_tl_render && (placed || parent_is_placed)))
				continue
			
			if (!type_is_visible(type) || type = e_tl_type.CAMERA || type_is_light(type))
				continue
				
			var halfwidth, halflength, halfheight, center, extent;
			halfwidth = block_size * 0.5
			halflength = halfwidth
			halfheight = halfwidth
			center = point3D(world_pos[X], world_pos[Y], world_pos[Z])
			
			if (type = e_tl_type.SCENERY)
			{
				var res, rep;
				res = temp != null ? temp.scenery : null
				if (res = null || !res.ready)
					continue
				
				rep = temp.block_repeat_enable ? temp.block_repeat : vec3(1)
				
				// Scenery rendering swaps the original width and length
				halfwidth = (res.scenery_size[Y] + res.scenery_size[X] * max(0, ceil(rep[X]) - 1)) * block_size * 0.5
				halflength = (res.scenery_size[X] + res.scenery_size[Y] * max(0, ceil(rep[Y]) - 1)) * block_size * 0.5
				halfheight = res.scenery_size[Z] * max(1, ceil(rep[Z])) * block_size * 0.5
				center = point3D(
					matrix_render[@ 12] + matrix_render[@ 0] * halfwidth + matrix_render[@ 4] * halflength,
					matrix_render[@ 13] + matrix_render[@ 1] * halfwidth + matrix_render[@ 5] * halflength,
					matrix_render[@ 14] + matrix_render[@ 2] * halfwidth + matrix_render[@ 6] * halflength + matrix_render[@ 10] * halfheight
				)
			}
			
			// Project the footprint onto XY
			extent = point3D(
				abs(matrix_render[@ 0]) * halfwidth + abs(matrix_render[@ 4]) * halflength,
				abs(matrix_render[@ 1]) * halfwidth + abs(matrix_render[@ 5]) * halflength,
				abs(matrix_render[@ 2]) * halfwidth + abs(matrix_render[@ 6]) * halflength + abs(matrix_render[@ 10]) * halfheight
			)
			
			if (empty)
			{
				minimum = point3D_sub(center, extent)
				maximum = point3D_add(center, extent)
				
				empty = false
			}
			else
			{
				minimum[@ X] = min(minimum[X], center[X] - extent[X])
				minimum[@ Y] = min(minimum[Y], center[Y] - extent[Y])
				minimum[@ Z] = min(minimum[Z], center[Z] - extent[Z])
				maximum[@ X] = max(maximum[X], center[X] + extent[X])
				maximum[@ Y] = max(maximum[Y], center[Y] + extent[Y])
				maximum[@ Z] = max(maximum[Z], center[Z] + extent[Z])
			}
		}
	}
	
	return [ minimum, maximum ]
}
