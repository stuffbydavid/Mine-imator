/// history_save_temp(template)
/// @arg template
/// @desc Saves a template into memory.

function history_save_temp(temp)
{
	var save = new_obj(obj_history_save);
	save.hobj = id
	
	with (temp)
		temp_copy(save)
	
	with (save)
	{
		save_id = temp.save_id
		temp_get_save_ids()
		
		// Save particle types
		if (type = e_temp_type.PARTICLE_SPAWNER)
		{
			pc_type_amount = ds_list_size(temp.pc_type_list)
			for (var p = 0; p < pc_type_amount; p++)
				with (other.id)
					save.pc_type_save_obj[p] = history_save_ptype(temp.pc_type_list[|p])
		}
		
		// Save references in other particle types
		usage_ptype_temp_amount = 0
		with (obj_particle_type)
		{
			if (id.temp != temp)
				continue
			
			save.usage_ptype_temp_save_id[save.usage_ptype_temp_amount] = save_id
			save.usage_ptype_temp_amount++
		}
	}
	
	save.usage_tl_amount = 0
	history_save_temp_usage_tl(temp, save, app)
	
	return save
}
