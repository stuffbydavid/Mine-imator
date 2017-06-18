/// action_tl_hide(timeline)
/// @arg timeline

if (history_undo)
{
	with (history_data)
		for (var t = 0; t < save_var_amount; t++)
			with (iid_find(save_var_obj[t]))
				hide = other.save_var_oldval[t]
}
else if (history_redo)
{
	with (history_data)
		for (var t = 0; t < save_var_amount; t++)
			with (iid_find(save_var_obj[t]))
				hide = other.save_var_newval[t]
}
else
{
	var hobj = history_save_var_start(action_tl_hide, false);
	
	with (argument0)
	{
		with (hobj)
			history_save_var(other.id, other.hide, !other.hide)
			
		hide=!hide
		
		if (type != "audio")
		{
			with (obj_timeline)
			{
				if (tl_has_parent(other.id))
				{
					with (hobj)
						history_save_var(other.id, other.hide, argument0.hide)
					
					hide = argument0.hide
				}
			}
		}
	}
}
