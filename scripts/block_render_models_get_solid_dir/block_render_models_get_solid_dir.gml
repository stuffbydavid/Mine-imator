/// block_render_models_get_solid_dir(models, direction)
/// @arg models
/// @arg direction
/// @desc Returns whether any of the render models are solid when looking in a direction.

var models, dir, diropp, minz, maxz;
models = argument0
dir = argument1
diropp = dir_get_opposite(dir)
minz = block_size
maxz = 0
		
for (var m = 0; m < array_length_1d(models); m++)
{
	for (var e = 0; e < models[m].element_amount; e++)
	{
		with (models[m].element[e])
		{
			// Face must not be rotated, invisible or transparent
			if (rotated || !rot_face_render[diropp] || rot_face_depth[diropp] > e_block_depth.DEPTH0)
				continue
				
			// Check if it touches the edge
			var touch = false;
			switch (dir)
			{
				case e_dir.EAST:	touch = (rot_from[X] = 0		&& rot_from[Y] = 0 && rot_to[Y] = block_size);	break
				case e_dir.WEST:	touch = (rot_to[X] = block_size && rot_from[Y] = 0 && rot_to[Y] = block_size);	break
				case e_dir.SOUTH:	touch = (rot_from[Y] = 0		&& rot_from[X] = 0 && rot_to[X] = block_size);	break
				case e_dir.NORTH:	touch = (rot_to[Y] = block_size && rot_from[X] = 0 && rot_to[X] = block_size);	break
			}
				
			if (touch)
			{
				minz = min(minz, rot_from[Z])
				maxz = max(maxz, rot_to[Z])
				if (minz = 0 && maxz = block_size) // Fully covered
					return true
			}
		}
	}
}

return false