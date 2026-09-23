/// history_restore_temp(save)
/// @arg save
/// @desc Adds a previously saved template.

function history_restore_temp(save)
{
	var temp;
	temp = new_obj(obj_template)
	
	with (save)
		temp_copy(temp)
	
	with (temp)
	{
		save_id = save.save_id
		temp_find_save_ids()
		
		temp_update(true)
		
		// Restore particle types
		if (type = e_temp_type.PARTICLE_SPAWNER)
		{
			pc_type_list = ds_list_create()
			
			for (var p = 0; p < save.pc_type_amount; p++)
				history_restore_ptype(save.pc_type_save_obj[p], id)
			
			temp_particles_restart()
		}
		
		// Restore references in particle types
		for (var t = 0; t < save.usage_ptype_temp_amount; t++)
			with (save_id_find(save.usage_ptype_temp_save_id[t]))
				id.temp = temp
		
		// Restore timelines
		for (var t = 0; t < save.usage_tl_amount; t++)
			history_restore_tl(save.usage_tl_save_obj[t])
			
		temp_add_lists()
	}
	
	return temp
}
