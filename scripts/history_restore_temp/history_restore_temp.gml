/// history_restore_temp(save)
/// @arg save
/// @desc Adds a previously saved template.

var save, temp;
save = argument0
temp = new(obj_template)

with (save)
	temp_copy(temp)
	
with (temp)
{
	save_id = save.save_id
	temp_find_save_ids()
	
	if (skin)
		skin.count++
		
	if (item_tex)
		item_tex.count++
		
	if (block_tex)
		block_tex.count++
		
	if (scenery)
		scenery.count++
		
	if (shape_tex && shape_tex.type != "camera")
		shape_tex.count++
		
	if (text_font)
		text_font.count++
		
	temp_update()
	
	// Restore particle types
	if (type = "particles")
	{
		for (var p = 0; p < save.pc_type_amount; p++)
			history_restore_ptype(save.pc_type_save_obj[|p], id)
			
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
