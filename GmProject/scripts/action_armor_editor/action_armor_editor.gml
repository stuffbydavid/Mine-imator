/// action_armor_editor(value)
/// @arg value

function action_armor_editor(value)
{
	var armor, temp;
	
	if (history_undo)
	{
		armor = array_copy_1d(history_data.old_armor)
		temp = history_data.temp
	}
	else if (history_redo)
	{
		armor = array_copy_1d(history_data.new_armor)
		temp = history_data.temp
	}
	else
	{
		temp = popup_armor_editor.armor_edit
		
		if (temp != bench_settings)
		{
			var hobj;
			history_pop()
		
			if (history_amount > 0 && history[0].script = action_armor_editor)
				hobj = history[0]
			else
			{
				history_push()
				hobj = new_history(action_armor_editor)
				hobj.old_armor = array_copy_1d(temp.armor_array)
			}
		
			hobj.temp = temp
			armor = array_copy_1d(temp.armor_array)
			armor[menu_armor_piece + menu_armor_piece_data] = value
			hobj.new_armor = armor
		
			history[0] = hobj
		}
		else
		{
			armor = array_copy_1d(temp.armor_array)
			armor[menu_armor_piece + menu_armor_piece_data] = value
		}
	}
	
	with (temp)
		armor_array = armor
	
	array_add(armor_update, temp)
	lib_preview.update = true
	bench_settings.preview.update = true
}
