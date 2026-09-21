/// tab_object_editor()

function tab_object_editor()
{
	if (tab = build_mode && (!place_build || obj_edit != build_settings))
	{
		tab_close(tab)
		return 0
	}

	if (obj_edit = null || !instance_exists(obj_edit))
	{
		obj_edit = null
		tab_close(tab)
		return 0
	}
	
	// Modify draw area
	if (obj_edit.type != e_temp_type.PARTICLE_SPAWNER)
		dh -= 28
	
	switch (obj_edit.type)
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.EQUIPMENT:
		case e_temp_type.SPECIAL_BLOCK:
		case e_temp_type.MODEL_PART:
			tab_object_editor_character()
			break
		
		case e_temp_type.BLOCK:
			tab_object_editor_block()
			break
		
		case e_temp_type.ITEM:
			tab_object_editor_item()
			break
		
		case e_temp_type.PARTICLE_SPAWNER:
			tab_object_editor_particles()
			break
		
		default:
			tab_close(tab)
			break
	}
}
