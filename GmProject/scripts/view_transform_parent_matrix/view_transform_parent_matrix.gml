/// view_transform_parent_matrix(timeline)
/// @arg timeline
/// @desc Gets the transform basis of a timeline's parent.

function view_transform_parent_matrix(timeline)
{
	// Position uses the original parent basis, before tl_update_matrix removes
	// inherited scale or rotation from matrix_parent.
	var parent_timeline = timeline.parent

	// Timeline dragging uses a temporary container with no transform of its own.
	// Keep the original parent basis until the item is dropped into its new parent.
	if (parent_timeline = app.timeline_move_obj)
		parent_timeline = timeline.move_parent

	var result = array_copy_1d(MAT_IDENTITY)
	if (parent_timeline != app)
	{
		result = array_copy_1d(timeline.inherit_rot_point ? parent_timeline.matrix_render : parent_timeline.matrix)
		if (parent_timeline.type = e_tl_type.MODEL_PART && timeline.lock_bend && parent_timeline.model_part != null && parent_timeline.model_part.bend_part != null)
		{
			var bend = vec3(parent_timeline.value_inherit[e_value.BEND_ANGLE_X], parent_timeline.value_inherit[e_value.BEND_ANGLE_Y], parent_timeline.value_inherit[e_value.BEND_ANGLE_Z])
			result = matrix_multiply(model_part_get_bend_matrix(parent_timeline.model_part, bend, vec3(0)), result)
		}
	}

	if (timeline.type = e_tl_type.MODEL_PART && timeline.model_part != null)
		result = matrix_multiply(matrix_create(timeline.part_of != null ? timeline.model_part.position : vec3(0), timeline.model_part.rotation, vec3(1)), result)

	return result
}
