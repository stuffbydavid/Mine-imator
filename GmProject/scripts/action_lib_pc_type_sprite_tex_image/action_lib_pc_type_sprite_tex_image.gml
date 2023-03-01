/// action_lib_pc_type_sprite_tex_image(image)
/// @arg image

function action_lib_pc_type_sprite_tex_image(image)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_tex_image, ptype_edit.sprite_tex_image, image, false)
	
	with (ptype_edit)
	{
		sprite_tex_image = image
		ptype_update_sprite_vbuffers()
	}
	
	tab_template_editor_particles_preview_restart()
}
