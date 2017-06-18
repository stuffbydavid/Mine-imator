/// history_restore_bench(save)
/// @arg save

var save = argument0;

with (save)
    temp_copy(app.bench_settings)
    
with (bench_settings)
{
    temp_find_iids()
	
    if (type = "item")
        temp_update_item()
		
    if (type = "block")
        temp_update_block()
		
    if (type_is_shape(type))
        temp_update_shape()
        
    // Restore templates
    temp_creator = app.bench_settings
    for (var t = 0; t < save.temp_amount; t++)
	{
        with (save.temp[t])
		{
            var ntemp = new(obj_template);
            temp_copy(ntemp)
            ntemp.iid = iid
            with (ntemp)
			{
                temp_find_iids()
				
                if (type = "item")
                    temp_update_item()
					
                if (type = "block")
                    temp_update_block()
					
                if (type_is_shape(type))
                    temp_update_shape()
					
                temp_update_rot_point()
                temp_update_display_name()
            }
        }
    }
    iid_current -= save.temp_amount
    temp_creator = app
        
    // Restore particle types
    if (type = "particles") 
	{
        pc_types = 0
        for (var p = 0; p < save.pc_types; p++)
            history_restore_ptype(save.pc_type[p], id)
        iid_current -= pc_types
        temp_particles_restart()
    }
}
