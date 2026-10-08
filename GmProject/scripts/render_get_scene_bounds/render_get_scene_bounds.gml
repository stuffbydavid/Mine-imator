/// @desc Returns scene bounds as minimum XY followed by maximum XY.

function render_get_scene_bounds()
{
	var minx, miny, maxx, maxy, empty;
	minx = 0
	miny = 0
	maxx = 0
	maxy = 0
	empty = true
	
	for (var i = 0; i < ds_list_size(render_list); i++)
	{
		with (render_list[|i])
		{
			if (hide || !render_visible || (!app.place_tl_render && (placed || parent_is_placed)))
				continue
			
			if (type = e_tl_type.CAMERA_EFFECT || type = e_tl_type.ENVIRONMENT || type = e_tl_type.AUDIO_TRACK)
				continue
				
			var halfwidth, halflength, centerx, centery, extentx, extenty;
			halfwidth = block_size * 0.5
			halflength = halfwidth
			centerx = world_pos[X]
			centery = world_pos[Y]
			
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
				centerx = matrix_render[@ 12] + matrix_render[@ 0] * halfwidth + matrix_render[@ 4] * halflength
				centery = matrix_render[@ 13] + matrix_render[@ 1] * halfwidth + matrix_render[@ 5] * halflength
			}
			
			// Project the footprint onto XY
			extentx = abs(matrix_render[@ 0]) * halfwidth + abs(matrix_render[@ 4]) * halflength
			extenty = abs(matrix_render[@ 1]) * halfwidth + abs(matrix_render[@ 5]) * halflength
			
			if (empty)
			{
				minx = centerx - extentx
				miny = centery - extenty
				maxx = centerx + extentx
				maxy = centery + extenty
				
				empty = false
			}
			else
			{
				minx = min(minx, centerx - extentx)
				miny = min(miny, centery - extenty)
				maxx = max(maxx, centerx + extentx)
				maxy = max(maxy, centery + extenty)
			}
		}
	}
	
	return [ minx, miny, maxx, maxy ]
}
