/// view_rotation_begin(axis_world)
/// @arg axis_world

function view_rotation_begin(axis_world)
{
	view_transform_begin(e_value_type.TRANSFORM_ROT)
	if (view_control_transform_mode = e_transform_mode.GIMBAL)
		return 0

	view_control_rotation_axis_world = vec3_normalize(axis_world)
	view_control_rotation_previous_eulers = []
	view_control_rotation_start_world = []
	view_control_rotation_parent = []
	view_control_rotation_parent_selected = []

	with (obj_timeline)
	{
		if (!selected || !value_type[e_value_type.TRANSFORM_ROT])
			continue

		var target_index = array_length(other.view_control_transform_start)
		var start_euler = vec3(value[e_value.ROT_X], value[e_value.ROT_Y], value[e_value.ROT_Z])
		var local_rotation = matrix_build(0, 0, 0, start_euler[X], start_euler[Y], start_euler[Z], 1, 1, 1)

		// Use authored values instead of matrix_render, which may still be from
		// the previous viewport update.
		var parent_rotation = view_rotation_matrix_orthonormal(view_rotation_parent_matrix(id))
		var world_rotation = view_rotation_matrix_orthonormal(matrix_multiply(local_rotation, parent_rotation))
		var selected_parent_rotates = false
		var hierarchy_child = id
		while (hierarchy_child.parent != app)
		{
			if (!hierarchy_child.inherit_rotation)
				break

			hierarchy_child = hierarchy_child.parent
			if (hierarchy_child.selected && hierarchy_child.value_type[e_value_type.TRANSFORM_ROT])
			{
				selected_parent_rotates = true
				break
			}
		}

		var target_save_id = save_id_get(id)

		ds_map_add(other.view_control_transform_target_map, target_save_id, target_index)
		other.view_control_transform_start[target_index] = start_euler
		other.view_control_rotation_previous_eulers[target_index] = start_euler
		other.view_control_rotation_start_world[target_index] = world_rotation
		other.view_control_rotation_parent[target_index] = parent_rotation
		other.view_control_rotation_parent_selected[target_index] = selected_parent_rotates
	}

	return 0
}
