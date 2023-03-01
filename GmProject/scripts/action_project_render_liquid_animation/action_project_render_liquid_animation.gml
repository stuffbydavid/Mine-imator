/// action_project_render_liquid_animation(value)
/// @arg value

function action_project_render_liquid_animation(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_liquid_animation, project_render_liquid_animation, value, 1)
	
	project_render_liquid_animation = value
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}
