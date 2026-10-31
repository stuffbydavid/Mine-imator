/// @desc Returns the timeline's world bounds as two points, or null if unavailable.

function tl_get_bounds(modelbounds = false)
{
	var halfsize, center, extent, boundslist;
	halfsize = vec3(block_half_size)
	center = world_pos
	boundslist = null

	switch (type)
	{
		case e_tl_type.CHARACTER:
		case e_tl_type.EQUIPMENT:
		case e_tl_type.MODEL:
		case e_tl_type.SPECIAL_BLOCK:
		{
			if (!modelbounds)
				break

			boundslist = []

			// The part list includes every level of the model hierarchy
			if (part_list != null)
			{
				for (var p = 0; p < ds_list_size(part_list); p++)
				{
					var partbounds = null;
					with (part_list[|p])
						partbounds = tl_get_bounds(true)

					array_add(boundslist, partbounds, false)
				}
			}

			// Imported block models render their buffers directly without child parts
			if (type = e_tl_type.MODEL && temp != null && temp.model != null && temp.model.model_format = e_model_format.BLOCK)
			{
				var model = temp.model;
				for (var m = 0; m < array_length(model.block_meshes); m++)
				{
					var mesh = model.block_meshes[m];
					if (mesh = null)
						continue

					for (var v = 0; v < array_length(mesh.block_vbuffer_render_order); v++)
					{
						var index = mesh.block_vbuffer_render_order[v];
						array_add(boundslist, vbuffer_get_bounds(mesh.block_vbuffer[index], matrix_render), false)
					}
				}

				if (model.model_block_map != null)
				{
					var key = ds_map_find_first(model.model_block_map);
					while (!is_undefined(key))
					{
						array_add(boundslist, vbuffer_get_bounds(model.model_block_map[?key], matrix_render), false)
						key = ds_map_find_next(model.model_block_map, key)
					}
				}
			}

			break
		}

		case e_tl_type.MODEL_PART:
		{
			if (!modelbounds)
				break

			if (!render_visible || (value_inherit[e_value.ALPHA] * 1000) = 0)
				return null

			if (model_part = null || model_part.shape_list = null)
				return null

			boundslist = []
			
			tl_update_model_shape_render()

			for (var s = 0; s < ds_list_size(model_part.shape_list); s++)
			{
				var shape, vbuf, mat;
				shape = model_part.shape_list[|s]
				vbuf = model_part_shape_vbuffer[s]

				if (model_part_shape_hidden[s] || (shape.color_alpha * 1000) = 0 || vbuf = null)
					continue

				// Move required to render (piston extension)
				if (shape.move_required && !(abs(value[e_value.POS_X]) > shape.move_required_array[X] &&
					abs(value[e_value.POS_Y]) > shape.move_required_array[Y] &&
					abs(value[e_value.POS_Z]) > shape.move_required_array[Z]))
					continue

				mat = model_part_shape_render_matrix[s]
				if (mat = null)
				{
					mat = matrix_multiply(shape.matrix, matrix_render)
					mat = render_world_get_item_transform(mat, shape.face_camera, shape.item_bounce, false, false, false, false)
				}

				array_add(boundslist, vbuffer_get_bounds(vbuf, mat), false)
			}

			break
		}
		
		case e_tl_type.SCENERY:
		{
			var res, rep, offset, blockmin, blockmax;
			res = (temp != null ? temp.scenery : null)
			if (res = null || !res.ready)
				return null

			rep = temp.block_repeat_enable ? temp.block_repeat : vec3(1)

			if (array_length(block_meshes_edit) > 0)
			{
				blockmin = block_meshes_min_pos
				blockmax = block_meshes_max_pos
			}
			else
			{
				blockmin = vec3(0)
				blockmax = vec3(
					res.scenery_size[X] * max(1, ceil(rep[X])),
					res.scenery_size[Y] * max(1, ceil(rep[Y])),
					res.scenery_size[Z] * max(1, ceil(rep[Z]))
				)
			}

			halfsize = vec3_mul(vec3_sub(blockmax, blockmin), block_half_size)
			offset = vec3_mul(blockmin, block_size)
			center = point3D_mul_matrix(vec3_add(halfsize, offset), matrix_render)
			
			break
		}
	}

	// Calculate final bounds
	if (boundslist != null)
	{
		var minpos, maxpos;
		minpos = null
		maxpos = null
		
		for (var b = 0; b < array_length(boundslist); b++)
		{
			var bounds = boundslist[b];
			if (bounds = null)
				continue

			if (minpos = null)
			{
				minpos = point3D_copy(bounds[0])
				maxpos = point3D_copy(bounds[1])
			}
			else
			{
				for (var a = X; a <= Z; a++)
				{
					minpos[@a] = min(minpos[a], bounds[0][a])
					maxpos[@a] = max(maxpos[a], bounds[1][a])
				}
			}
		}

		if (minpos != null)
			return [ minpos, maxpos ]

		// Empty parts contribute no bounds to the model
		if (type = e_tl_type.MODEL_PART)
			return null
	}

	// Project the size onto the world axes
	var extentmatrix = array_copy_1d(matrix_render);
	for (var i = 0; i < 12; i++)
		extentmatrix[@i] = abs(extentmatrix[@i])

	extent = vec3_mul_matrix(halfsize, extentmatrix)

	return [ point3D_sub(center, extent), point3D_add(center, extent) ]
}
