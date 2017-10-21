/// tab_template_editor_update_ptype_list()

if (temp_edit = null || temp_edit.type != e_temp_type.PARTICLE_SPAWNER)
	return 0
	
sortlist_clear(ptype_list)
for (var t = 0; t < ds_list_size(temp_edit.pc_type_list); t++)
	sortlist_add(ptype_list, temp_edit.pc_type_list[|t])
sortlist_update(ptype_list)

ptype_edit = null
