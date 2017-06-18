/// action_lib_pc_type_add()

var ptype;

if (history_undo)
{
    with (temp_edit)
        temp_particles_type_remove(iid_find(history_data.ptype_iid)) // Remove
}
else
{
    with (temp_edit)
        ptype = temp_particles_type_add()
        
    if (history_redo)
        ptype.iid = history_data.ptype_iid // Restore iid
    else
	{
        var hobj = history_set(action_lib_pc_type_add);
        hobj.ptype_iid = iid_get(ptype)
    }
    
    sortlist_add(ptype_list, ptype)
    ptype_edit = ptype
}

tab_template_editor_particles_preview_restart()
