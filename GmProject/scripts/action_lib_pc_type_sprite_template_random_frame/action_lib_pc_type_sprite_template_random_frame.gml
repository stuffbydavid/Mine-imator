/// action_lib_pc_type_sprite_template_random_frame(random_frame)
/// @arg random_frame

function action_lib_pc_type_sprite_template_random_frame(random_frame)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_template_random_frame, ptype_edit.sprite_template_random_frame, random_frame, true)
	
	with (ptype_edit)
	{
		sprite_template_random_frame = random_frame
		ptype_update_sprite_vbuffers()
	}
	
	tab_template_editor_particles_preview_restart()
}
