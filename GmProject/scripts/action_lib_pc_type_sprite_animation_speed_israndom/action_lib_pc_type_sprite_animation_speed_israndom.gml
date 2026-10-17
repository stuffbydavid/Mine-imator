function action_lib_pc_type_sprite_animation_speed_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_animation_speed_israndom, ptype_edit.sprite_animation_speed_israndom, enabled, false)
	
	ptype_edit.sprite_animation_speed_israndom = enabled
	tab_object_editor_particles_preview_restart()
}
