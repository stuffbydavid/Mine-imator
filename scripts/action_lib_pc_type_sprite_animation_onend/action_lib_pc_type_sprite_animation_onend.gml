/// action_lib_pc_type_sprite_animation_onend(onend)
/// @arg onend

function action_lib_pc_type_sprite_animation_onend(onend)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_animation_onend, ptype_edit.sprite_animation_onend, onend, false)
	
	ptype_edit.sprite_animation_onend = onend
	tab_template_editor_particles_preview_restart()
}
