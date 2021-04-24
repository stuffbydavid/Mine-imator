/// app_update_tl_edit_tabs()

function app_update_tl_edit_tabs()
{
	var showtl, showkf;
	showtl = false
	showkf = false
	
	if (tl_edit_amount > 0)
	{
		showtl = true
		if (tl_edit.type = e_tl_type.AUDIO)
			showkf = (tl_edit.keyframe_select != null)
		else
			showkf = true
	}
	
	if (showtl)
		tab_show(timeline_editor)
	else
		tab_close(timeline_editor)
	
	if (showkf)
		tab_show(frame_editor)
	else
		tab_close(frame_editor)
}
