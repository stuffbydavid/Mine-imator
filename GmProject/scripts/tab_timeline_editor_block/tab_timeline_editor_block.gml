/// tab_timeline_editor_block()

function tab_timeline_editor_block()
{
	var oldtemp = temp_edit;
	temp_edit = tl_edit.has_temp ? tl_edit.temp : tl_edit
	
	if (temp_edit.type = e_tl_type.BLOCK)
		tab_properties_library_block(tab.block)
	else // Special block model
		tab_properties_library_character()
		
	temp_edit = oldtemp
}
