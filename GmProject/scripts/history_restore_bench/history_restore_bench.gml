/// history_restore_bench(save)
/// @arg save

function history_restore_bench(save)
{
	with (save)
		temp_copy(app.bench_settings)
	
	with (bench_settings)
	{
		temp_find_save_ids()
		temp_update(true)
		
		// Restore templates
		temp_creator = app.bench_settings
		for (var t = 0; t < save.temp_amount; t++)
		{
			with (save.temp_save_obj[t])
			{
				var ntemp = new_obj(obj_template);
				temp_copy(ntemp)
				with (ntemp)
				{
					save_id = other.save_id
					temp_find_save_ids()
					temp_update()
				}
			}
		}
		temp_creator = app
		
		// Restore particle types
		if (type = e_temp_type.PARTICLE_SPAWNER) 
		{
			temp_particles_type_clear()
			
			for (var p = 0; p < save.pc_type_amount; p++)
				history_restore_ptype(save.pc_type_save_obj[p], id)
			temp_particles_restart()
		}
	}
}
