/// app_update_previews()

function app_update_previews()
{
	lib_preview.select = temp_edit
	res_preview.select = res_edit
	bench_settings.preview.select = bench_settings
	
	with (obj_preview)
	{
		if (last_select != select)
		{
			preview_reset_view()
			particle_spawner_clear()
			reset_view = true
		}
		last_select = select
		
		if (instance_exists(select) && select.object_index != obj_resource && select.type = e_temp_type.PARTICLE_SPAWNER)
			particle_spawner_update()
		
		spawn_laststep = current_step
	}
}
