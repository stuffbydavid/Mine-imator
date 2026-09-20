/// tab_properties_library()

function tab_properties_library()
{
	// Preview selected template
	tab_control(160)
	preview_draw(tab.library.preview, dx, dy, dw, 160)
	tab_next()
	
	// List
	tab_control_sortlist(tab.library.list)
	sortlist_draw(tab.library.list, dx, dy, dw, tab_control_h, temp_edit)
	tab_next()
	
	// Tools
	tab_control(24)
	
	if (draw_button_icon("librarynew", dx, dy, 24, 24, false, icons.ASSET_ADD, null, false, "tooltiptemplatenew"))
		bench_open = true
	
	if (draw_button_icon("libraryanimate", dx + 28, dy, 24, 24, false, icons.ASSET_INSTANCE, null, temp_edit = null, "tooltiptemplateanimate"))
		action_lib_animate()
	
	if (draw_button_icon("libraryduplicate", dx + (28 * 2), dy, 24, 24, false, icons.DUPLICATE, null, temp_edit = null, "tooltiptemplateduplicate"))
		action_lib_duplicate()
	
	if (draw_button_icon("libraryremove", dx + (28 * 3), dy, 24, 24, false, icons.DELETE, null, temp_edit = null, "tooltiptemplateremove"))
		action_lib_remove()
	
	tab_next()
	
	if (temp_edit = null)
		return 0
	
	// Name
	tab_control_textfield(false)
	tab.library.tbx_name.text = temp_edit.name
	draw_textfield("libraryname", dx, dy, dw, 24, tab.library.tbx_name, action_lib_name, temp_edit.display_name, "left")
	tab_next()
	
	switch (temp_edit.type)
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.EQUIPMENT:
		case e_temp_type.SPECIAL_BLOCK:
			tab_properties_library_character()
			break
		
		case e_temp_type.MODEL:
			tab_properties_library_model()
			break	
		
		case e_temp_type.MODEL_PART:
			tab_properties_library_model_part()
			break
		
		case e_temp_type.ITEM:
			tab_properties_library_item()
			break
		
		case e_temp_type.SCENERY:
		case e_temp_type.BLOCK:
			tab_properties_library_block(tab.library)
			break
		
		case e_temp_type.PARTICLE_SPAWNER:
			tab_properties_library_particles()
			break
		
		case e_temp_type.TEXT:
			tab_properties_library_text()
			break
		
		case e_temp_type.CUBE: 
		case e_temp_type.CONE: 
		case e_temp_type.CYLINDER: 
		case e_temp_type.SPHERE: 
		case e_temp_type.SURFACE:
			tab_properties_library_shape()
			break
	}
}
