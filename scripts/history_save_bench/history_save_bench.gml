/// history_save_bench()

var save = new(obj_history_save);
save.hobj = id

with (bench_settings)
	temp_copy(save)
	
with (save)
{
	temp_get_save_ids()
	
	// Save particle types
	if (type = "particles")
	{
		for (var p = 0; p < pc_types; p++)
			with (other.id)
				save.pc_type[p] = history_save_ptype(app.bench_settings.pc_type[p])
	}
	
	// Save templates
	temp_amount = 0
	with (obj_template)
	{
		if (creator != app.bench_settings)
			continue
		
		var tsave = new(obj_history_save);
		tsave.hobj = save.hobj
		temp_copy(tsave)
		tsave.iid = iid
		
		with (tsave)
			temp_get_save_ids()
			
		save.temp[save.temp_amount] = tsave
		save.temp_amount++
	}
}

return save
