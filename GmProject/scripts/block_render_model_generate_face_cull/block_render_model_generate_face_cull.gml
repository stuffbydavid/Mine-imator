/// @desc Returns whether the current face should be culled.
/// @arg model
/// @arg element
/// @arg culldirection

function block_render_model_generate_face_cull(model, el, culldir)
{
	if (!el.face_edge[culldir])
		return false

	var depth, full, lower, upper;
	depth = block_face_min_depth[culldir]
	full = block_face_full[culldir]
	lower = block_face_min[culldir]
	upper = block_face_max[culldir]

	// Offset models need neighbors at their own block position
	if (!vec3_equals(model.offset, vec3(0)))
	{
		var pos, minpos, maxpos;
		pos = vec3_add(build_pos, vec3_div(model.offset, block_size))
		pos = vec3_add(pos, dir_get_vec3(culldir))
		minpos = vec3(0)
		maxpos = build_size
		if (build_edit)
		{
			minpos = build_min_pos
			maxpos = build_max_pos
		}

		for (var a = X; a <= Z; a++)
		{
			if (pos[a] < minpos[a] || pos[a] >= maxpos[a])
				return !mc_builder.build_edges && culldir != ZP
		}

		var neighbor = builder_get_render_model(pos[X], pos[Y], pos[Z]);
		if (neighbor = null)
			return false

		var opposite = culldir ^ 1;
		depth = neighbor.face_min_depth[opposite]
		full = neighbor.face_full[opposite]
		lower = neighbor.face_min[opposite]
		upper = neighbor.face_max[opposite]
	}

	if (depth = null || depth > model.face_min_depth[culldir])
		return false
	
	if (block_current != null && block_current.type = "leaves" && depth > e_block_depth.DEPTH0)
		return false

	var axis = (culldir < ZP ? Z : Y);
	return (full || (lower <= el.from[axis] && upper >= el.to[axis]))
}
