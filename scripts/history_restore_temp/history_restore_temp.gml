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
		
		if (model != null)
			model.count++
		
		if (model_tex != null)
			model_tex.count++
		
		if (item_tex != null)
			item_tex.count++
		
		if (block_tex != null)
			block_tex.count++
		
		if (block_tex_material != null)
			block_tex_material.count++
		
		if (block_tex_normal != null)
			block_tex_normal.count++
		
		if (scenery != null)
			scenery.count++
		
		if (shape_tex != null && shape_tex.type != e_tl_type.CAMERA)
			shape_tex.count++
		
		if (shape_tex_material != null)
			shape_tex_material.count++
		
		if (shape_tex_normal != null)
			shape_tex_normal.count++
		
		if (text_font != null)
			text_font.count++
		
		temp_update()
		
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
	}
	
	sortlist_add(app.lib_list, temp)
	
	return temp
}
