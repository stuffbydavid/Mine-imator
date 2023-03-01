/// action_project_bend_style(value)
/// @arg value

function action_project_bend_style(style)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_bend_style, project_bend_style, style, 1)
	
	project_bend_style = style
	render_samples = -1
	
	// Force update timeline meshes
	with (obj_timeline)
	{
		bend_rot_last = vec3(0)
		tl_update_model_shape_bend()
	}
}
