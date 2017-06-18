/// block_render_models_get_solid(models)
/// @arg models
/// @desc Returns whether any of the render models is a solid block.

var models = argument0;

for (var m = 0; m < array_length_1d(models); m++)
{
	for (var e = 0; e < models[m].element_amount; e++)
	{
		with (models[m].element[e])
		{
			if (from[X] = 0 && from[Y] = 0 && from[Z] = 0 &&
				to[X] = block_size && to[Y] = block_size && to[Z] = block_size)
			{
				var issolid = true;
	
				for (var d = 0; d < e_dir.amount; d++)
				{
					if (!face_render[d] || face_depth[d] > e_block_depth.DEPTH0)
					{
						issolid = false
						break
					}
				}
			
				if (issolid)
					return true
			}
		}
	}
}

return false