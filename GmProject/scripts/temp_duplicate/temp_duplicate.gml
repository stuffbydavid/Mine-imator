/// temp_duplicate()
/// @desc Duplicates the template, returns the new one.

function temp_duplicate()
{
	var temp, copy;
	temp = new_obj(obj_template)
	temp_copy(temp)
	copy = id
	
	with (temp)
	{
		temp_update(true)
		
		if (type = e_temp_type.PARTICLE_SPAWNER)
		{
			pc_type_list = ds_list_create()
			
			for (var t = 0; t < ds_list_size(other.pc_type_list); t++)
			{
				with (other.pc_type_list[|t])
				{
					var ptype = new_obj(obj_particle_type);
					ptype_copy(ptype)
					ptype.creator = temp
					with (ptype)
						ptype_update_sprite_vbuffers()
					ds_list_add(temp.pc_type_list, ptype)
				}
			}
		}
		
		return id
	}
}
