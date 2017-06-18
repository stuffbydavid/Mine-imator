/// history_restore_temp(save)
/// @arg save
/// @desc Adds a saved template.

var save, temp;
save = argument0
temp = new(obj_template)

with (save)
	temp_copy(temp)
	
with (temp)
{
	iid = save.iid
	temp_find_iids()
	
	if (char_skin)
		char_skin.count++
		
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
		
	if (type = "item")
		temp_update_item()
		
	if (type = "block")
		temp_update_block()
		
	if (type_is_shape(type))
		temp_update_shape()
		
	temp_update_rot_point()
	temp_update_display_name()
	
	// Restore particle types
	if (type = "particles")
	{
		pc_types = 0
		for (var p = 0; p < save.pc_types; p++)
			history_restore_ptype(save.pc_type[p], id)
			
		temp_particles_restart()
	}
	
	// Restore references in particle types
	for (var t = 0; t < save.usage_ptype_temp_amount; t++)
		with (iid_find(save.usage_ptype_temp[t]))
			id.temp = temp
	
	// Restore timelines
	for (var t = 0; t < save.usage_tl_amount; t++)
		history_restore_tl(save.usage_tl[t])
}

sortlist_add(app.lib_list, temp)

return temp
