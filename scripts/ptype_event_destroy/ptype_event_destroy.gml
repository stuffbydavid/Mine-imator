/// ptype_event_destroy()
/// @desc Destroy event of obj_particle_type.

function ptype_event_destroy()
{
	// Remove from creator
	ds_list_delete_value(creator.pc_type_list, id)
	
	if (temp_creator != app.bench_settings)
	{
		sprite_tex.count--
		sprite_template_tex.count--
	}
	
	for (var m = 0; m < sprite_vbuffer_amount; m++)
		vbuffer_destroy(sprite_vbuffer[m])
	
	// Destroy associated particles
	with (obj_particle)
		if (type = other.id)
			instance_destroy()
	
	ptype_edit = sortlist_remove(app.ptype_list, id)
}
