/// action_lib_pc_type_sprite_frame_end(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_sprite_frame_end(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_frame_end, ptype_edit.sprite_frame_end, ptype_edit.sprite_frame_end * add + val, true)
	
	with (ptype_edit)
	{
		sprite_frame_end = sprite_frame_end * add + val
		ptype_update_sprite_vbuffers()
	}
	
	tab_template_editor_particles_preview_restart()
}
