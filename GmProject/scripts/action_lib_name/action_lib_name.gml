function action_lib_name(name)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_name, temp_edit.name, name, true)
	
	with (temp_edit)
	{
		self.name = name
		temp_update_display_name()
	}
}
