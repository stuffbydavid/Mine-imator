/// ptype_get_save_ids()

function ptype_get_save_ids()
{
	creator = save_id_get(creator)
	
	if (temp != particle_sheet && temp != particle_template)
		temp = save_id_get(temp)
	
	sprite_tex = save_id_get(sprite_tex)
	sprite_template_tex = save_id_get(sprite_template_tex)
}
