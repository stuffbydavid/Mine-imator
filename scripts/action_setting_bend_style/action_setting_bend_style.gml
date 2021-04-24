/// action_setting_bend_style(value)
/// @arg value

function action_setting_bend_style(style)
{
	setting_bend_style = style
	render_samples = -1
	
	// Force update timeline meshes
	with (obj_timeline)
	{
		bend_rot_last = vec3(0)
		tl_update_model_shape_bend()
	}
}
