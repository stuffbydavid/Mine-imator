/// history_save_temp(template)
/// @arg template
/// @desc Saves a template in memory.

var temp, save;
temp = argument0
save = new(obj_history_save)
save.hobj = id

with (temp)
    temp_copy(save)
    
with (save)
{
    iid = temp.iid
    temp_get_iids()
    
    // Save particle types
    if (type = "particles")
	{
        for (var p = 0; p < pc_types; p++)
            with (other.id)
                save.pc_type[p] = history_save_ptype(temp.pc_type[p])
    }
    
    // Save references in particle types
    usage_ptype_temp_amount = 0
    with (obj_particle_type)
	{
        if (id.temp != temp)
            continue
        save.usage_ptype_temp[save.usage_ptype_temp_amount] = iid
        save.usage_ptype_temp_amount++
    }
}

save.usage_tl_amount = 0
history_save_temp_usage_tl(temp, save, app)

return save
