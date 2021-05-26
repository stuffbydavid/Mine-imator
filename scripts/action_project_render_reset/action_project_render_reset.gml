/// action_project_render_reset()

function action_project_render_reset()
{
	if (question(text_get("questionresetrender")))
		project_reset_render()
	
	log("Reset render settings")
}