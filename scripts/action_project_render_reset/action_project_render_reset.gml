/// action_project_render_reset()

function action_project_render_reset()
{
	if (history_undo)
		history_copy_render_settings(history_data.save_obj_old)
	else
	{
		if (!history_redo)
		{
			if (!question(text_get("questionresetrender")))
				return 0
			
			var hobj = history_set(action_project_render_reset);
			hobj.save_obj_old = new_obj(obj_history_save)
			
			with (hobj.save_obj_old)
				history_copy_render_settings(app)
		}
		
		project_reset_render()
	}
}