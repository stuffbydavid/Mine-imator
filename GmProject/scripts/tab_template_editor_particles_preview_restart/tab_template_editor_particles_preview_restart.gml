/// tab_template_editor_particles_preview_restart()

function tab_template_editor_particles_preview_restart()
{
	if (ptype_edit)
	{
		particle_editor_preview_start = current_step
		particle_editor_preview_speed = value_random(ptype_edit.sprite_animation_speed, ptype_edit.sprite_animation_speed_israndom, ptype_edit.sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_max)
	}
}
