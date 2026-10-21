function action_lib_pc_type_sprite_template_reverse(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_template_reverse, ptype_edit.sprite_template_reverse, enabled, true)
	
	with (ptype_edit)
	{
		sprite_template_reverse = enabled
		ptype_update_sprite_vbuffers()
	}
	
	tab_object_editor_particles_preview_restart()
}
