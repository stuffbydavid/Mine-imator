/// tab_properties_library_particles()

function tab_properties_library_particles()
{
	// Advanced mode only
	if (setting_advanced_mode)
	{
		tab_control_button_label()
			
		if (draw_button_label("libraryparticleeditoropen", dx, dy, dw, null, e_button.SECONDARY))
		{
			if (object_editor.show && obj_edit = temp_edit)
				tab_close(object_editor)
			else
			{
				obj_edit = temp_edit
				tab_object_editor_update_ptype_list()
				tab_show(object_editor, true)
			}
		}
			
		if (object_editor.show && obj_edit = temp_edit)
			current_microani.active.value = true
			
		tab_next()
	}
}
