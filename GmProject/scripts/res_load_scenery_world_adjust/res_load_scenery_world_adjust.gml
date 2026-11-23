/// @desc Adjusts block edits and timelines to a reloaded world selection.

function res_load_scenery_world_adjust()
{
	// Local Y runs backwards from the selection's end X
	var offset = point3D(
		world_box_start[Z] - world_box_start_load[Z],
		world_box_end_load[X] - world_box_end[X],
		world_box_start[Y] - world_box_start_load[Y]
	);

	// Later repeats move when the source dimensions change
	var oldsize, sizechange;
	oldsize = scenery_size
	sizechange = vec3_sub(vec3(
		world_box_end_load[Z] - world_box_start_load[Z],
		world_box_end_load[X] - world_box_start_load[X],
		world_box_end_load[Y] - world_box_start_load[Y]
	), oldsize)

	// Keep edits aligned with their original world blocks
	if (!vec3_equals(offset, vec3(0)) || !vec3_equals(sizechange, vec3(0)))
	{
		with (obj_timeline)
		{
			if (type != e_tl_type.SCENERY || temp = null || temp.scenery != other.id)
				continue

			var rep = vec3(1);
			if (temp.block_repeat_enable)
				rep = temp.block_repeat

			for (var b = 0; b < array_length(blocks_added); b++)
			{
				var added, pos;
				added = array_copy_1d(blocks_added[b])
				pos = vec3_add(added[0], offset)
				for (var a = X; a <= Z; a++)
					if (oldsize[a] > 0)
						pos[a] += sizechange[a] * clamp(floor(added[0][a] / oldsize[a]), 0, rep[a] - 1)

				added[0] = pos
				blocks_added[b] = added
			}

			// Move added timelines and their animations with the edited grid
			var root, tree;
			root = id
			tree = [ [ root, vec3(0) ] ]
			
			for (var t = 0; t < array_length(tree); t++)
			{
				var entry = tree[t];
				with (entry[0])
				{
					if (id != root && type_is_structure(type))
						continue

					var moved = entry[1];
					if (!inherit_position)
						moved = vec3(0)

					if (part_of = null && (type = e_tl_type.BLOCK || type = e_tl_type.SPECIAL_BLOCK))
					{
						var parentmatrix, pos, shift, shiftpos;
						if (inherit_rot_point)
							parentmatrix = parent.matrix_render
						else
							parentmatrix = parent.matrix

						// Identify the repeat from the default block position
						pos = tl_value_get_vec3(e_value.POS_X, true)
						if (inherit_position)
							pos = point3D_mul_matrix(pos, parentmatrix)
						
						pos = point3D_mul_matrix(pos, matrix_inverse_ext(root.matrix_render))
						
						if (block_build_name != "")
						{
							var block = mc_assets.block_name_map[?block_build_name];
							if (!is_undefined(block))
							{
								var blockpos = block_get_timeline_position(block, block_get_state_id(block, block_build_state));
								pos = vec3_sub(pos, vec3(blockpos[Y], block_size - blockpos[X], blockpos[Z]))
							}
						}

						shift = array_copy_1d(offset)
						for (var a = X; a <= Z; a++)
							if (oldsize[a] > 0)
								shift[a] += sizechange[a] * clamp(floor(pos[a] / (oldsize[a] * block_size) + 0.000001), 0, rep[a] - 1)

						shiftpos = vec3_mul_matrix(vec3_mul(vec3_sub(shift, moved), block_size), root.matrix_render)
						if (inherit_position)
							shiftpos = vec3_mul_matrix(shiftpos, matrix_inverse_ext(parentmatrix))

						tl_value_set_vec3(e_value.POS_X, vec3_add(tl_value_get_vec3(e_value.POS_X), shiftpos))
						tl_value_set_vec3(e_value.POS_X, vec3_add(tl_value_get_vec3(e_value.POS_X, true), shiftpos), true)
						
						for (var k = 0; k < ds_list_size(keyframe_list); k++)
							with (keyframe_list[|k])
								tl_value_set_vec3(e_value.POS_X, vec3_add(tl_value_get_vec3(e_value.POS_X), shiftpos))

						tl_update_values()
						update_matrix = true
						moved = shift
					}

					// Subtract inherited shifts before moving added children
					for (var c = 0; c < ds_list_size(tree_list); c++)
						array_add(tree, [ tree_list[|c], moved ], false)
				}
			}
		}
	}

	// Commit the selection after a successful world import
	world_box_start = array_copy_1d(world_box_start_load)
	world_box_end = array_copy_1d(world_box_end_load)
}
