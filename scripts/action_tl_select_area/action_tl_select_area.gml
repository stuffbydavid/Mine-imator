/// action_tl_select_area(starttimeline, endtimeline)
/// @arg starttimeline
/// @arg endtimeline

function action_tl_select_area(stl, etl)
{
	if (history_undo)
	{
		with (history_data)
			history_restore_tl_select()
	}
	else if (history_redo)
	{
		with (history_data)
			history_restore_tl_select_new()
	}
	else
	{
		var hobj, ctrl;
		hobj = history_set(action_tl_select_area)
		ctrl = keyboard_check(vk_control)
		
		with (hobj)
			history_save_tl_select()
		
		for (var t = stl; t <= etl; t++)
		{
			with (tree_visible_list[|t])
			{
				if (!ctrl)
				{
					tl_update_recursive_select()
					tl_select()
				}
				else
					tl_deselect()
			}
		}
		
		with (hobj)
			history_save_tl_select_new()
	}
	
	app_update_tl_edit()
}
