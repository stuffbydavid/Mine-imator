/// tab_object_editor_update_ptype_list()

function tab_object_editor_update_ptype_list()
{
	if (obj_edit = null || !instance_exists(obj_edit) || obj_edit.type != e_temp_type.PARTICLE_SPAWNER)
		return 0
	
	sortlist_clear(ptype_list)
	for (var t = 0; t < ds_list_size(obj_edit.pc_type_list); t++)
		sortlist_add(ptype_list, obj_edit.pc_type_list[|t])
	sortlist_update(ptype_list)
	
	ptype_edit = null
}
