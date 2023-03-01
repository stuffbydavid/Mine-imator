/// action_lib_pc_type_sprite_frame_height(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_sprite_frame_height(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_frame_height, ptype_edit.sprite_frame_height, ptype_edit.sprite_frame_height * add + val, true)
	
	with (ptype_edit)
	{
		sprite_frame_height = sprite_frame_height * add + val
		ptype_update_sprite_vbuffers()
	}
	
	tab_template_editor_particles_preview_restart()
}
