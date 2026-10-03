function action_lib_pc_type_sprite_animation_speed_random_min(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_min * add + value, true)
	
	ptype_edit.sprite_animation_speed_random_min = ptype_edit.sprite_animation_speed_random_min * add + value
	tab_object_editor_particles_preview_restart()
}
