/// temp_select_edit([showtab])
/// Selects the template in the library and opens the tab for editing.

function temp_select_edit(showtab = true)
{
	with (app)
	{
		tab_show(properties, true)
		properties.library.show = true
		action_lib_list(other.id)
		sortlist_view(lib_list, other.id)

		var editortab = false;
		switch (other.type)
		{
			case e_temp_type.CHARACTER:
			case e_temp_type.EQUIPMENT:
			case e_temp_type.SPECIAL_BLOCK:
			case e_temp_type.BLOCK:
			case e_temp_type.ITEM:
			case e_temp_type.PARTICLE_SPAWNER:
				editortab = true
		}
		
		if (editortab && showtab)
		{
			obj_edit = other.id
			tab_object_editor_update_ptype_list()
			tab_show(object_editor, true)
		}
	}
}
