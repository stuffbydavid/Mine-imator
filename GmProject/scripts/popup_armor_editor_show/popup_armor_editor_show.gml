/// popup_armor_editor_show(obj)
/// @arg obj

function popup_armor_editor_show(obj)
{
	with (popup_armor_editor)
	{
		with (preview)
		{
			preview_reset_view()
			fov = 25
			xy_lock = true
			zoom = 0.5
			goalzoom = 0.5
		}
		
		armor_edit = obj
		
		preview.select = armor_edit
		preview.last_select = armor_edit
	}
	
	popup_show(popup_armor_editor)
}
