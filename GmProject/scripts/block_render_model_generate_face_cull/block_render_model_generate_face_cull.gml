/// @desc Returns whether the current face should be culled.
/// @arg model
/// @arg element
/// @arg culldirection

function block_render_model_generate_face_cull(model, el, culldir)
{
	if (!el.face_edge[culldir] || block_face_min_depth[culldir] = null || block_face_min_depth[culldir] > model.face_min_depth[culldir])
		return false
	
	if (block_current != null && block_current.type = "leaves" && block_face_min_depth[culldir] > e_block_depth.DEPTH0)
		return false

	var axis = (culldir < ZP ? Z : Y);
	return (block_face_full[culldir] || (block_face_min[culldir] <= el.from[axis] && block_face_max[culldir] >= el.to[axis]))
}
