function world_import_go_to_position_draw()
{
	draw_set_font(font_label)
	
	axis_edit = X
	textfield_group_add("world_import/go_to_position_pos/x", world_import_settings_gotoposition_x, 0, world_import_go_to_position_posx, axis_edit, tbx_worldimport_gotoposition_x, null, 0.25)
	axis_edit = Y
	textfield_group_add(setting_z_is_up ? "world_import/go_to_position_pos/y" : "world_import/go_to_position_pos/z", world_import_settings_gotoposition_z, 0, world_import_go_to_position_posz, axis_edit, tbx_worldimport_gotoposition_z, null, 0.25)
	
	tab_control_textfield_group(true)
	draw_textfield_group("world_import/go_to_position_pos", dx, dy, dw, null, -30000000, 30000000, 1, true, true, 1)
	tab_next()
	
	tab_control_button_label()
	if (draw_button_label("world_import/go_to_position", dx, dy, dw, icons.PATH_POINT, e_button.PRIMARY, null, e_anchor.LEFT))
		world_import_go_to_position(world_import_settings_gotoposition_x, world_import_settings_gotoposition_z)
	tab_next()
	
	settings_menu_w = 216
}
