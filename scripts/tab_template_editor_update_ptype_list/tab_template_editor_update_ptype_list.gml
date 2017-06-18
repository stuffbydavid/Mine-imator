/// tab_template_editor_update_ptype_list()

if (!temp_edit)
    return 0
    
if (temp_edit.type != "particles")
    return 0
    
sortlist_clear(ptype_list)
for (var t = 0; t < temp_edit.pc_types; t++)
    sortlist_add(ptype_list, temp_edit.pc_type[t])
sortlist_sort(ptype_list)

ptype_edit = null
